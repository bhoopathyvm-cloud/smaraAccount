import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/crypto/entry_canonical_hash.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../../domain/exceptions.dart';
import '../../domain/models/integrity_event.dart';
import '../../domain/models/signing_identity.dart';
import '../database/app_database.dart';
import '../database/tables/entry_verification_cache_table.dart';
import 'account_repository.dart';
import 'ledger_chain_store.dart';
import 'repository_date_utils.dart';

/// Device signing-identity lifecycle, chain verification, and keystore
/// export. Split out of `LedgerRepository` (architecture-deepening
/// design.md D1). Depends on optional [AccountRepository] only to seed
/// starter books in [confirmFirstIdentity]; omitted for
/// [LedgerBackupRepository]'s throwaway temp-file instance (design.md D2).
///
/// Chain tip, verification-cache, and current-identity reads go through
/// [LedgerChainStore] so posting can share them without importing this
/// class (Identity → Account → Ledger stays acyclic).
class IdentityRepository {
  IdentityRepository({
    required AppDatabase database,
    AccountRepository? accountRepository,
    SigningKeyService? signingKeyService,
    LedgerChainStore? chain,
  }) : _db = database,
       _accountRepository = accountRepository,
       _signingKeyService = signingKeyService ?? SigningKeyService(),
       _chain = chain ?? LedgerChainStore(database);

  final AppDatabase _db;
  final AccountRepository? _accountRepository;
  final SigningKeyService _signingKeyService;
  final LedgerChainStore _chain;

  AccountRepository _requireAccountRepository() {
    final accounts = _accountRepository;
    if (accounts == null) {
      throw StateError(
        'IdentityRepository.confirmFirstIdentity requires AccountRepository.',
      );
    }
    return accounts;
  }

  /// The active (non-superseded) signing identity, or null if none has
  /// been generated/confirmed yet - the true-first-launch state.
  Future<SigningIdentity?> currentIdentity() => _chain.currentSigningIdentity();

  /// Whether this device's secure storage currently holds the private key
  /// matching [identity]. False means either no key is stored at all, or
  /// (very unusually) a different key is stored - both are the
  /// "existing database file, no matching key" reinstall scenario the
  /// caller should route to a restore flow for, never silently regenerate.
  Future<bool> hasMatchingStoredKey(SigningIdentity identity) async {
    final stored = await _signingKeyService.loadStoredKeyMaterial();
    if (stored == null) return false;
    return bytesEqual(stored.publicKey, identity.publicKey);
  }

  /// Generates a new recovery phrase and its key pair, storing the private
  /// key immediately. Does *not* write a `signing_identities` row - call
  /// [confirmFirstIdentity] only after the user has confirmed possession
  /// of the phrase, so the ledger stays unusable (no identity to sign
  /// against) until that mandatory acknowledgment is complete (spec:
  /// "Onboarding blocks until recovery phrase is acknowledged").
  Future<GeneratedIdentity> generateFirstIdentity() {
    return _signingKeyService.generateNewIdentity();
  }

  /// Stashes the just-generated phrase's words so they survive an app kill
  /// before acknowledgment completes (deferred-onboarding-first-entry).
  Future<void> stashPendingPhraseWords(List<String> words) {
    return _signingKeyService.stashPendingPhraseWords(words);
  }

  /// Reconstructs the pending (committed-but-unacknowledged) identity's
  /// [GeneratedIdentity] from words stashed by [stashPendingPhraseWords],
  /// for redisplay after an app kill. Null if there's nothing pending.
  Future<GeneratedIdentity?> resumePendingIdentity() {
    return _signingKeyService.resumePendingIdentity();
  }

  /// Persists [generated] as this device's signing identity, seeds the
  /// chain state, and seeds the starter financial account/categories.
  /// Call only after the user has confirmed the recovery phrase.
  ///
  /// Starter accounts are seeded here rather than at database creation
  /// (core-ledger-single-account's original approach) because spec
  /// ("Device Signing Identity") requires the signing identity to exist
  /// before any starter account or journal entry does.
  ///
  /// [currency] (ISO 4217, e.g. 'USD') is chosen by the user during a
  /// dedicated onboarding step before this runs (multi-currency-support
  /// design.md addendum) and applied to all four starter groups - a fresh
  /// install never has a group with a null currency, unlike a database
  /// migrated from schemaVersion 3 (see
  /// [AccountRepository.needsCurrencyBackfill]).
  Future<SigningIdentity> confirmFirstIdentity(
    GeneratedIdentity generated, {
    required String currency,
  }) async {
    late IdentityRow row;
    await _db.transaction(() async {
      row = await _db
          .into(_db.signingIdentities)
          .insertReturning(
            SigningIdentitiesCompanion.insert(
              publicKey: Uint8List.fromList(generated.keyMaterial.publicKey),
            ),
          );
      await _chain.loadState();
      await _requireAccountRepository().seedOnboardingBooks(currency: currency);
    });
    return _toDomainIdentity(row);
  }

  /// Re-derives this device's private key from a recovery phrase or
  /// keystore file and matches it to a signing identity already in the
  /// database. Never re-signs or alters any entry.
  Future<SigningIdentity> restoreIdentity({
    List<String>? recoveryPhraseWords,
    String? keystoreFileContents,
    String? keystorePassphrase,
  }) async {
    final material = recoveryPhraseWords != null
        ? await _signingKeyService.restoreFromRecoveryPhrase(
            recoveryPhraseWords,
          )
        : await _signingKeyService.restoreFromKeystoreFile(
            fileContents: keystoreFileContents!,
            passphrase: keystorePassphrase!,
          );

    final candidates = await _db.select(_db.signingIdentities).get();
    IdentityRow? match;
    for (final row in candidates) {
      if (bytesEqual(row.publicKey, material.publicKey)) {
        match = row;
        break;
      }
    }
    if (match == null) {
      throw SigningIdentityMismatchException(
        'This recovery phrase or keystore file does not match any signing '
        'identity in this database.',
      );
    }
    return _toDomainIdentity(match);
  }

  /// Disaster-recovery path for true key loss (spec: "True Key-Loss
  /// Migration"). Generates a brand-new identity, re-creates every
  /// currently-active entry as a new, signed entry under it (preserving
  /// content, referencing the legacy entry via [JournalEntry.migratedFromEntryId]),
  /// and records a `KEY_MIGRATION_CONFIRMED` integrity event. The new
  /// chain starts fresh from genesis - it does not, and cannot, inherit
  /// cryptographic trust from the unrecoverable old chain.
  ///
  /// Callers must have already shown the required plain-language
  /// confirmation that this does not retroactively prove pre-migration
  /// entries were untampered (spec) before calling this.
  Future<GeneratedIdentity> migrateToNewIdentityAfterKeyLoss() async {
    final previousIdentity = await currentIdentity();
    final generated = await _signingKeyService.generateNewIdentity();

    await _db.transaction(() async {
      final newIdentityRow = await _db
          .into(_db.signingIdentities)
          .insertReturning(
            SigningIdentitiesCompanion.insert(
              publicKey: Uint8List.fromList(generated.keyMaterial.publicKey),
              supersedesIdentityId: Value(previousIdentity?.identityId),
              // This migration flow has its own explicit "I confirm the
              // current ledger is valid" acknowledgment (spec: "True
              // Key-Loss Migration") and never shows a new recovery
              // phrase to re-acknowledge - mark it acknowledged
              // immediately so the router doesn't also send the user
              // through deferred-onboarding-first-entry's acknowledgment
              // screens for a phrase this flow never generated.
              acknowledgedAt: Value(DateTime.now()),
            ),
          );

      if (previousIdentity != null) {
        await (_db.update(_db.signingIdentities)
              ..where((t) => t.identityId.equals(previousIdentity.identityId)))
            .write(
              SigningIdentitiesCompanion(supersededAt: Value(DateTime.now())),
            );
      }

      final activeEntries = await _activeEntriesForMigration();
      // device_chain_sequence is UNIQUE across the whole table (design.md),
      // not scoped per identity - legacy entries keep their old sequence
      // numbers forever, so a migration continues the *same* monotonic
      // counter rather than restarting at 0. Only the hash chain itself
      // (previousHash below) resets to genesis: that's the actual fresh
      // trust root a migration establishes.
      final priorChainState = await _chain.loadState();
      var sequence = priorChainState.nextDeviceChainSequence;
      Uint8List previousHash = Uint8List.fromList(genesisPreviousEntryHash);
      String? lastInsertedId;

      for (final legacy in activeEntries) {
        final legacyPostings = await (_db.select(
          _db.postings,
        )..where((p) => p.entryId.equals(legacy.id))).get();

        final newId = const Uuid().v4();
        final recordedAt = truncateToStoredPrecision(DateTime.now());
        final canonicalPostings = legacyPostings
            .map(
              (p) => CanonicalPosting(
                lineNumber: p.lineNumber,
                accountId: p.accountId,
                amountMinor: p.amountMinor,
              ),
            )
            .toList();

        final bytes = canonicalEntryBytes(
          previousEntryHash: previousHash,
          id: newId,
          deviceChainSequence: sequence,
          transactionDate: legacy.transactionDate,
          recordedAt: recordedAt,
          description: legacy.description,
          reversesEntryId: legacy.reversesEntryId,
          signedByIdentityId: newIdentityRow.identityId,
          postings: canonicalPostings,
        );
        final entryHash = await hashCanonicalEntry(bytes);
        final signature = await _signingKeyService.sign(entryHash);

        await _db
            .into(_db.journalEntries)
            .insert(
              JournalEntriesCompanion.insert(
                id: Value(newId),
                transactionDate: legacy.transactionDate,
                recordedAt: recordedAt,
                description: Value(legacy.description),
                reversesEntryId: Value(legacy.reversesEntryId),
                deviceChainSequence: sequence,
                previousEntryHash: previousHash,
                entryHash: entryHash,
                signedByIdentityId: newIdentityRow.identityId,
                signature: signature,
                migratedFromEntryId: Value(legacy.id),
              ),
            );

        for (final p in legacyPostings) {
          await _db
              .into(_db.postings)
              .insert(
                PostingsCompanion.insert(
                  entryId: newId,
                  accountId: p.accountId,
                  amountMinor: p.amountMinor,
                  lineNumber: p.lineNumber,
                ),
              );
        }

        await _chain.upsertVerificationCache(
          entryId: newId,
          isVerified: true,
          breakReason: null,
        );

        previousHash = entryHash;
        lastInsertedId = newId;
        sequence += 1;
      }

      await _chain.updateState(
        trustedTipEntryId: lastInsertedId,
        trustedTipHash: activeEntries.isEmpty ? null : previousHash,
        nextDeviceChainSequence: sequence,
      );

      await _db
          .into(_db.integrityEvents)
          .insert(
            IntegrityEventsCompanion.insert(
              eventType: IntegrityEventType.keyMigrationConfirmed,
              relatedIdentityId: Value(newIdentityRow.identityId),
              detail: Value(
                'Migrated ${activeEntries.length} entries to new identity '
                '${newIdentityRow.identityId} after confirmed key loss.',
              ),
            ),
          );
    });

    return generated;
  }

  /// Entries not already superseded by an earlier migration - the set
  /// re-created by [migrateToNewIdentityAfterKeyLoss].
  Future<List<JournalEntryRow>> _activeEntriesForMigration() async {
    final all = await (_db.select(
      _db.journalEntries,
    )..orderBy([(e) => OrderingTerm.asc(e.deviceChainSequence)])).get();
    final supersededIds = all
        .where((e) => e.migratedFromEntryId != null)
        .map((e) => e.migratedFromEntryId!)
        .toSet();
    return all.where((e) => !supersededIds.contains(e.id)).toList();
  }

  SigningIdentity _toDomainIdentity(IdentityRow row) {
    return SigningIdentity(
      identityId: row.identityId,
      publicKey: row.publicKey,
      createdAt: row.createdAt,
      supersedesIdentityId: row.supersedesIdentityId,
      supersededAt: row.supersededAt,
      acknowledgedAt: row.acknowledgedAt,
    );
  }

  /// Marks the current (latest, non-superseded) identity as having
  /// completed the mandatory recovery-phrase acknowledgment, and clears
  /// the phrase words temporarily held in secure storage for
  /// crash-recovery re-display (deferred-onboarding-first-entry). Throws
  /// [StateError] if there is no current identity.
  Future<void> acknowledgeIdentity() async {
    final identity = await currentIdentity();
    if (identity == null) {
      throw StateError('No signing identity to acknowledge.');
    }
    await (_db.update(
      _db.signingIdentities,
    )..where((t) => t.identityId.equals(identity.identityId))).write(
      SigningIdentitiesCompanion(acknowledgedAt: Value(DateTime.now())),
    );
    await _signingKeyService.clearPendingPhraseWords();
  }

  /// Walks the entire chain, recomputing hashes and checking signatures
  /// and linkage, and rebuilds `entry_verification_cache` from scratch
  /// (design.md: "recomputed in full on every app startup"). If the break
  /// point has moved since the last check, updates
  /// `ledger_chain_state.trusted_tip_*` to the last verified entry before
  /// it and records a `CHAIN_BREAK_DETECTED` integrity event.
  Future<ChainVerificationResult> verifyChain() async {
    return _db.transaction(() async {
      final entries = await (_db.select(
        _db.journalEntries,
      )..orderBy([(e) => OrderingTerm.asc(e.deviceChainSequence)])).get();
      final identities = await _db.select(_db.signingIdentities).get();
      final publicKeyById = {
        for (final i in identities) i.identityId: i.publicKey,
      };

      String? breakEntryId;
      var breakReason = VerificationBreakReason.hashMismatch;
      final results =
          <String, ({bool isVerified, VerificationBreakReason? reason})>{};
      Uint8List expectedPreviousHash = Uint8List.fromList(
        genesisPreviousEntryHash,
      );

      for (final entry in entries) {
        if (breakEntryId != null) {
          results[entry.id] = (
            isVerified: false,
            reason: VerificationBreakReason.excludedAfterBreak,
          );
          continue;
        }

        final postings = await (_db.select(
          _db.postings,
        )..where((p) => p.entryId.equals(entry.id))).get();
        final canonicalPostings = postings
            .map(
              (p) => CanonicalPosting(
                lineNumber: p.lineNumber,
                accountId: p.accountId,
                amountMinor: p.amountMinor,
              ),
            )
            .toList();

        // A migration-created entry (migratedFromEntryId set) deliberately
        // starts a fresh hash-chain root under its new identity - it does
        // not, and cannot, chain onto the unrecoverable old identity's
        // last hash (migrateToNewIdentityAfterKeyLoss docs why). Without
        // this, every post-migration entry would wrongly read as a chain
        // break purely because device_chain_sequence keeps incrementing
        // across the migration boundary while the hash chain resets.
        final requiredPreviousHash = entry.migratedFromEntryId != null
            ? Uint8List.fromList(genesisPreviousEntryHash)
            : expectedPreviousHash;
        if (!bytesEqual(entry.previousEntryHash, requiredPreviousHash)) {
          breakEntryId = entry.id;
          breakReason = VerificationBreakReason.chainLinkBroken;
          results[entry.id] = (isVerified: false, reason: breakReason);
          continue;
        }

        final bytes = canonicalEntryBytes(
          previousEntryHash: entry.previousEntryHash,
          id: entry.id,
          deviceChainSequence: entry.deviceChainSequence,
          transactionDate: entry.transactionDate,
          recordedAt: entry.recordedAt,
          description: entry.description,
          reversesEntryId: entry.reversesEntryId,
          signedByIdentityId: entry.signedByIdentityId,
          postings: canonicalPostings,
        );
        final recomputedHash = await hashCanonicalEntry(bytes);
        if (!bytesEqual(recomputedHash, entry.entryHash)) {
          breakEntryId = entry.id;
          breakReason = VerificationBreakReason.hashMismatch;
          results[entry.id] = (isVerified: false, reason: breakReason);
          continue;
        }

        final publicKey = publicKeyById[entry.signedByIdentityId];
        final signatureValid =
            publicKey != null &&
            await _signingKeyService.verify(
              recomputedHash,
              signature: entry.signature,
              publicKey: publicKey,
            );
        if (!signatureValid) {
          breakEntryId = entry.id;
          breakReason = VerificationBreakReason.signatureInvalid;
          results[entry.id] = (isVerified: false, reason: breakReason);
          continue;
        }

        results[entry.id] = (isVerified: true, reason: null);
        expectedPreviousHash = recomputedHash;
      }

      await _chain.replaceVerificationCache([
        for (final entry in entries)
          (
            entryId: entry.id,
            isVerified: results[entry.id]!.isVerified,
            breakReason: results[entry.id]!.reason,
          ),
      ]);

      final priorChainState = await _chain.loadState();
      final isNewBreak =
          breakEntryId != null && priorChainState.trustedTipHash != null
          ? !bytesEqual(priorChainState.trustedTipHash!, expectedPreviousHash)
          : breakEntryId != null;

      if (breakEntryId != null) {
        final lastVerifiedIndex =
            entries.indexWhere((e) => e.id == breakEntryId) - 1;
        final lastVerifiedEntry = lastVerifiedIndex >= 0
            ? entries[lastVerifiedIndex]
            : null;
        await _chain.updateState(
          trustedTipEntryId: lastVerifiedEntry?.id,
          trustedTipHash: lastVerifiedEntry?.entryHash,
          nextDeviceChainSequence: priorChainState.nextDeviceChainSequence,
        );

        if (isNewBreak) {
          await _db
              .into(_db.integrityEvents)
              .insert(
                IntegrityEventsCompanion.insert(
                  eventType: IntegrityEventType.chainBreakDetected,
                  relatedEntryId: Value(breakEntryId),
                  detail: Value(
                    'Break detected at entry $breakEntryId (${breakReason.name}); '
                    'reanchoring onto ${lastVerifiedEntry?.id ?? "genesis"}.',
                  ),
                ),
              );
        }
      } else if (entries.isNotEmpty) {
        final tip = entries.last;
        await _chain.updateState(
          trustedTipEntryId: tip.id,
          trustedTipHash: tip.entryHash,
          nextDeviceChainSequence: priorChainState.nextDeviceChainSequence,
        );
      }

      return ChainVerificationResult(
        totalEntries: entries.length,
        breakEntryId: breakEntryId,
        breakReason: breakEntryId != null ? breakReason : null,
      );
    });
  }

  /// Encrypted keystore file export of the device's current signing key
  /// (spec: "Optional keystore file export"). Passthrough to
  /// [SigningKeyService] - the only place private key bytes are ever
  /// touched.
  Future<String> exportKeystoreFile({required String passphrase}) {
    return _signingKeyService.exportKeystoreFile(passphrase: passphrase);
  }
}

/// Result of one [IdentityRepository.verifyChain] pass.
class ChainVerificationResult {
  const ChainVerificationResult({
    required this.totalEntries,
    required this.breakEntryId,
    required this.breakReason,
  });

  final int totalEntries;
  final String? breakEntryId;
  final VerificationBreakReason? breakReason;

  bool get isFullyVerified => breakEntryId == null;
}
