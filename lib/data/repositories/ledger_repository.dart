import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/crypto/entry_canonical_hash.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../../domain/exceptions.dart';
import '../../domain/models/account.dart';
import '../../domain/models/account_group.dart';
import '../../domain/models/home_overview.dart';
import '../../domain/models/integrity_event.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/models/pending_transfer.dart';
import '../../domain/models/posting.dart';
import '../../domain/models/signing_identity.dart';
import '../../domain/models/summary.dart';
import '../../domain/models/transaction_direction.dart';
import '../database/app_database.dart';
import '../database/tables/account_groups_table.dart';
import '../database/tables/accounts_table.dart';
import '../database/tables/ledger_chain_state_table.dart';

/// The only layer that talks to Drift. Exposes domain models, never
/// Drift's generated row classes (smara-tech-guidelines.md). Every write
/// path (recordTransaction, reverseEntry) writes an entry and its postings
/// in a single Drift transaction. No updateEntry/deleteEntry method exists
/// anywhere on this class - immutability is enforced by omission
/// (Golden Rule #7).
///
/// Since ledger-integrity-signing, every posted entry is also hashed,
/// chained onto the device's trusted tip, and signed with the current
/// [SigningIdentity]'s private key (via [SigningKeyService], which never
/// exposes the key material itself to this class - only signatures).
class LedgerRepository {
  LedgerRepository({
    required AppDatabase database,
    SigningKeyService? signingKeyService,
  }) : _db = database,
       _signingKeyService = signingKeyService ?? SigningKeyService();

  final AppDatabase _db;
  final SigningKeyService _signingKeyService;

  // ---------------------------------------------------------------------
  // Signing identity lifecycle (spec: "Device Signing Identity",
  // "Mandatory Recovery Phrase Acknowledgment", "Recoverable Reinstall or
  // Device Migration").
  // ---------------------------------------------------------------------

  /// The active (non-superseded) signing identity, or null if none has
  /// been generated/confirmed yet - the true-first-launch state.
  Future<SigningIdentity?> currentIdentity() async {
    final row =
        await (_db.select(_db.signingIdentities)
              ..where((t) => t.supersededAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _toDomainIdentity(row);
  }

  /// Whether this device's secure storage currently holds the private key
  /// matching [identity]. False means either no key is stored at all, or
  /// (very unusually) a different key is stored - both are the
  /// "existing database file, no matching key" reinstall scenario the
  /// caller should route to a restore flow for, never silently regenerate.
  Future<bool> hasMatchingStoredKey(SigningIdentity identity) async {
    final stored = await _signingKeyService.loadStoredKeyMaterial();
    if (stored == null) return false;
    return _bytesEqual(stored.publicKey, identity.publicKey);
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
  /// migrated from schemaVersion 3 (see [needsCurrencyBackfill]).
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
      await _db
          .into(_db.ledgerChainState)
          .insertOnConflictUpdate(
            LedgerChainStateCompanion.insert(
              id: ledgerChainStateSingletonId,
              nextDeviceChainSequence: 0,
            ),
          );
      await _seedSystemGroupsEquityAndClearing(currency: currency);
      await _db
          .into(_db.accounts)
          .insert(
            AccountsCompanion.insert(
              name: financialAccountName,
              type: AccountType.asset,
              groupId: const Value(groupCashEquivalentsId),
            ),
          );
      for (final name in starterIncomeCategories) {
        await _db
            .into(_db.accounts)
            .insert(
              AccountsCompanion.insert(name: name, type: AccountType.income),
            );
      }
      for (final name in starterExpenseCategories) {
        await _db
            .into(_db.accounts)
            .insert(
              AccountsCompanion.insert(name: name, type: AccountType.expense),
            );
      }
    });
    return _toDomainIdentity(row);
  }

  Future<void> _seedSystemGroupsEquityAndClearing({
    required String currency,
  }) async {
    final seeds = <(String id, String name, AccountGroupKind kind, int order)>[
      (
        groupCashEquivalentsId,
        'Cash & cash equivalents',
        AccountGroupKind.assetGroup,
        0,
      ),
      (
        groupPensionRetirementId,
        'Pension & retirement',
        AccountGroupKind.assetGroup,
        1,
      ),
      (
        groupCreditShortTermId,
        'Credit & short-term debt',
        AccountGroupKind.liabilityGroup,
        2,
      ),
      (
        groupLoansMortgagesId,
        'Loans & mortgages',
        AccountGroupKind.liabilityGroup,
        3,
      ),
    ];
    for (final (id, name, kind, order) in seeds) {
      await _db
          .into(_db.accountGroups)
          .insertOnConflictUpdate(
            AccountGroupsCompanion.insert(
              id: Value(id),
              name: name,
              kind: kind,
              sortOrder: order,
              isSystem: true,
              currency: Value(currency),
            ),
          );
    }
    await _db
        .into(_db.accounts)
        .insertOnConflictUpdate(
          AccountsCompanion.insert(
            id: const Value(openingBalanceEquityAccountId),
            name: openingBalanceEquityAccountName,
            type: AccountType.equity,
          ),
        );
    await _db
        .into(_db.accounts)
        .insertOnConflictUpdate(
          AccountsCompanion.insert(
            id: const Value(transfersInTransitAccountId),
            name: transfersInTransitAccountName,
            type: AccountType.clearing,
          ),
        );
  }

  /// Whether any `account_groups` row still has no currency - the signal
  /// for a database migrated from schemaVersion 3 that needs the one-time
  /// currency-backfill prompt before the app is otherwise usable
  /// (multi-currency-support design.md Migration Plan step 3). Always
  /// false for a fresh schemaVersion-4 install, since
  /// [confirmFirstIdentity] seeds every group with a currency already.
  Future<bool> needsCurrencyBackfill() async {
    final row =
        await (_db.select(_db.accountGroups)
              ..where((g) => g.currency.isNull())
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  /// Applies [currency] to every account group that doesn't have one yet.
  /// A one-time action for a database migrated from schemaVersion 3 - see
  /// [needsCurrencyBackfill].
  Future<void> backfillGroupCurrencies(String currency) async {
    await (_db.update(_db.accountGroups)..where((g) => g.currency.isNull()))
        .write(AccountGroupsCompanion(currency: Value(currency)));
  }

  /// Re-derives key material from a recovery phrase or keystore file and,
  /// if it matches an identity already on record, stores it as the
  /// device's active private key (spec: "Recoverable Reinstall or Device
  /// Migration"). Exactly one of [recoveryPhraseWords] or
  /// [keystoreFileContents] (with [keystorePassphrase]) must be given.
  /// Throws [SigningIdentityMismatchException] if the derived key doesn't
  /// match any known identity - the phrase/file doesn't belong to this
  /// database.
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
      if (_bytesEqual(row.publicKey, material.publicKey)) {
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
      final priorChainState = await _chainState();
      var sequence = priorChainState.nextDeviceChainSequence;
      Uint8List previousHash = Uint8List.fromList(genesisPreviousEntryHash);
      String? lastInsertedId;

      for (final legacy in activeEntries) {
        final legacyPostings = await (_db.select(
          _db.postings,
        )..where((p) => p.entryId.equals(legacy.id))).get();

        final newId = const Uuid().v4();
        final recordedAt = _truncateToStoredPrecision(DateTime.now());
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

        await _upsertVerificationCache(
          entryId: newId,
          isVerified: true,
          breakReason: null,
        );

        previousHash = entryHash;
        lastInsertedId = newId;
        sequence += 1;
      }

      await _updateChainState(
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
    );
  }

  // ---------------------------------------------------------------------
  // Startup verification (spec: "Startup Integrity Verification",
  // "Quarantine of Entries After a Break", "Re-anchoring After a Break").
  // ---------------------------------------------------------------------

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
        if (!_bytesEqual(entry.previousEntryHash, requiredPreviousHash)) {
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
        if (!_bytesEqual(recomputedHash, entry.entryHash)) {
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

      await _db.delete(_db.entryVerificationCache).go();
      final now = DateTime.now();
      for (final entry in entries) {
        final result = results[entry.id]!;
        await _db
            .into(_db.entryVerificationCache)
            .insert(
              EntryVerificationCacheCompanion.insert(
                entryId: entry.id,
                isVerified: result.isVerified,
                breakReason: Value(result.reason),
                checkedAt: now,
              ),
            );
      }

      final priorChainState = await _chainState();
      final isNewBreak =
          breakEntryId != null && priorChainState.trustedTipHash != null
          ? !_bytesEqual(priorChainState.trustedTipHash!, expectedPreviousHash)
          : breakEntryId != null;

      if (breakEntryId != null) {
        final lastVerifiedIndex =
            entries.indexWhere((e) => e.id == breakEntryId) - 1;
        final lastVerifiedEntry = lastVerifiedIndex >= 0
            ? entries[lastVerifiedIndex]
            : null;
        await _updateChainState(
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
        await _updateChainState(
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

  // ---------------------------------------------------------------------
  // Register / summary reads.
  // ---------------------------------------------------------------------

  /// Reactive stream of the register: every posted entry with its
  /// postings, ordered chronologically by transaction date. Includes each
  /// entry's current verification status from `entry_verification_cache`
  /// (spec: "Quarantine of Entries After a Break").
  Stream<List<JournalEntry>> watchEntries() {
    final query =
        _db.select(_db.journalEntries).join([
          leftOuterJoin(
            _db.postings,
            _db.postings.entryId.equalsExp(_db.journalEntries.id),
          ),
          leftOuterJoin(
            _db.entryVerificationCache,
            _db.entryVerificationCache.entryId.equalsExp(_db.journalEntries.id),
          ),
        ])..orderBy([
          OrderingTerm.asc(_db.journalEntries.transactionDate),
          OrderingTerm.asc(_db.journalEntries.createdAt),
          OrderingTerm.asc(_db.postings.lineNumber),
        ]);

    return query.watch().map(_groupIntoEntries);
  }

  List<JournalEntry> _groupIntoEntries(List<TypedResult> rows) {
    final entryRows = <String, JournalEntryRow>{};
    final postingsByEntry = <String, List<PostingRow>>{};
    final verificationByEntry = <String, EntryVerificationRow>{};

    for (final row in rows) {
      final entry = row.readTable(_db.journalEntries);
      entryRows[entry.id] = entry;
      final posting = row.readTableOrNull(_db.postings);
      if (posting != null) {
        postingsByEntry.putIfAbsent(entry.id, () => []).add(posting);
      }
      final verification = row.readTableOrNull(_db.entryVerificationCache);
      if (verification != null) {
        verificationByEntry[entry.id] = verification;
      }
    }

    final supersededEntryIds = <String>{
      for (final entry in entryRows.values) ?entry.migratedFromEntryId,
    };

    return entryRows.values
        .map(
          (entry) => _toDomainEntry(
            entry,
            postingsByEntry[entry.id] ?? const [],
            verificationByEntry[entry.id],
            supersededEntryIds.contains(entry.id),
          ),
        )
        .toList();
  }

  JournalEntry _toDomainEntry(
    JournalEntryRow entry,
    List<PostingRow> postings,
    EntryVerificationRow? verification,
    bool isSupersededByMigration,
  ) {
    return JournalEntry(
      id: entry.id,
      transactionDate: DateTime.parse(entry.transactionDate),
      recordedAt: entry.recordedAt,
      description: entry.description,
      reversesEntryId: entry.reversesEntryId,
      postings: postings.map(_toDomainPosting).toList(),
      deviceChainSequence: entry.deviceChainSequence,
      entryHash: entry.entryHash,
      signedByIdentityId: entry.signedByIdentityId,
      signature: entry.signature,
      migratedFromEntryId: entry.migratedFromEntryId,
      // No cache row yet (e.g. immediately after insert, before the next
      // verification pass populates it) defaults to verified - matches
      // the immediate cache write recordTransaction/reverseEntry already
      // perform for the entry they just created.
      isVerified: verification?.isVerified ?? true,
      breakReason: verification?.breakReason,
      isSupersededByMigration: isSupersededByMigration,
    );
  }

  Posting _toDomainPosting(PostingRow row) {
    return Posting(
      id: row.id,
      entryId: row.entryId,
      accountId: row.accountId,
      amountMinor: row.amountMinor,
      lineNumber: row.lineNumber,
    );
  }

  /// Categories for pickers ([includeArchived] false, the default) or
  /// historical views ([includeArchived] true). Allowlist: income/expense
  /// only — never liability/equity/asset.
  Stream<List<Account>> watchCategories({bool includeArchived = false}) {
    final query = _db.select(_db.accounts)
      ..where(
        (a) =>
            a.type.equalsValue(AccountType.income) |
            a.type.equalsValue(AccountType.expense),
      )
      ..orderBy([(a) => OrderingTerm.asc(a.name)]);
    if (!includeArchived) {
      query.where((a) => a.archivedAt.isNull());
    }
    return query.watch().map((rows) => rows.map(_toDomainAccount).toList());
  }

  /// Active financial accounts only (`asset` / `liability` allowlist).
  Stream<List<Account>> watchFinancialAccounts({bool includeArchived = false}) {
    final query = _db.select(_db.accounts)
      ..where(
        (a) =>
            a.type.equalsValue(AccountType.asset) |
            a.type.equalsValue(AccountType.liability),
      )
      ..orderBy([
        (a) => OrderingTerm.asc(a.sortOrder),
        (a) => OrderingTerm.asc(a.name),
      ]);
    if (!includeArchived) {
      query.where((a) => a.archivedAt.isNull());
    }
    return query.watch().map((rows) => rows.map(_toDomainAccount).toList());
  }

  /// Account-group pickers ([includeArchived] false, the default) or
  /// callers resolving an existing account's own group, which may since
  /// have been archived ([includeArchived] true) - mirrors
  /// [watchFinancialAccounts]'s convention.
  Stream<List<AccountGroup>> watchAccountGroups({
    bool includeArchived = false,
  }) {
    final query = _db.select(_db.accountGroups)
      ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]);
    if (!includeArchived) {
      query.where((g) => g.archivedAt.isNull());
    }
    return query.watch().map((rows) => rows.map(_toDomainGroup).toList());
  }

  Account _toDomainAccount(AccountRow row) {
    return Account(
      id: row.id,
      name: row.name,
      type: row.type,
      archived: row.archivedAt != null,
      groupId: row.groupId,
      sortOrder: row.sortOrder,
    );
  }

  AccountGroup _toDomainGroup(AccountGroupRow row) {
    return AccountGroup(
      id: row.id,
      name: row.name,
      kind: row.kind,
      sortOrder: row.sortOrder,
      isSystem: row.isSystem,
      currency: row.currency,
      archived: row.archivedAt != null,
    );
  }

  /// Used by [recordTransaction], [recordTransfer], and
  /// [archiveFinancialAccount] - throws [AccountGroupException] (not
  /// [InvalidTransferException], which is reserved for transfer-specific
  /// validation like same-account/non-positive-amount) so every caller's
  /// existing catch clause for "not a valid financial account" applies
  /// uniformly.
  Future<AccountRow> _requireActiveFinancialAccount(String id) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null ||
        (row.type != AccountType.asset && row.type != AccountType.liability)) {
      throw AccountGroupException('Account $id is not a financial account.');
    }
    if (row.archivedAt != null) {
      throw AccountGroupException('Account $id is archived.');
    }
    return row;
  }

  /// Sibling of [_requireActiveFinancialAccount] for the one write that
  /// *must* start from an archived account: closeout of its remaining
  /// display balance (spec: "Closeout of an Archived Account with a
  /// Remaining Balance"). A boolean on the active helper would let any
  /// caller silently loosen both sides of a transfer.
  Future<AccountRow> _requireCloseoutEligibleFinancialAccount(String id) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null ||
        (row.type != AccountType.asset && row.type != AccountType.liability)) {
      throw AccountGroupException('Account $id is not a financial account.');
    }
    if (row.archivedAt == null) {
      throw AccountGroupException('Account $id is not archived.');
    }
    final balance = await displayBalanceMinor(id);
    if (balance <= 0) {
      throw AccountGroupException(
        'Account $id has no positive display balance to close out.',
      );
    }
    return row;
  }

  /// The ISO 4217 currency of [accountRow]'s group - never null in
  /// practice for a reachable financial account (the currency-backfill
  /// gate runs before any account-creation UI, and group assignment is
  /// mandatory), but defensively rejected rather than silently treating a
  /// backfill-pending group as some default currency.
  Future<String> _groupCurrencyFor(AccountRow accountRow) async {
    final groupId = accountRow.groupId;
    if (groupId == null) {
      throw AccountGroupException(
        'Account ${accountRow.id} has no group assigned.',
      );
    }
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(groupId))).getSingleOrNull();
    final currency = group?.currency;
    if (currency == null) {
      throw AccountGroupException(
        'Account group $groupId has no currency set yet.',
      );
    }
    return currency;
  }

  /// Creates a financial account. [openingBalanceMinor] if supplied must be
  /// positive; for liabilities it means amount owed.
  Future<Account> createFinancialAccount({
    required String name,
    required AccountType type,
    required String groupId,
    int? openingBalanceMinor,
  }) async {
    if (type != AccountType.asset && type != AccountType.liability) {
      throw ArgumentError.value(type, 'type', 'must be asset or liability');
    }
    if (openingBalanceMinor != null && openingBalanceMinor <= 0) {
      throw InvalidOpeningBalanceException(
        'Opening balance must be positive and non-zero when supplied, '
        'got $openingBalanceMinor.',
      );
    }
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(groupId))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException('Account group $groupId not found.');
    }
    final expectedKind = type == AccountType.asset
        ? AccountGroupKind.assetGroup
        : AccountGroupKind.liabilityGroup;
    if (group.kind != expectedKind) {
      throw AccountGroupException(
        'Account type $type does not match group kind ${group.kind}.',
      );
    }
    // Defensive: the app-level currency-backfill gate (needsCurrencyBackfill)
    // should always run before any account-creation UI is reachable, so
    // this should never actually trigger - but a null currency here would
    // otherwise propagate silently into every downstream currency label.
    if (group.currency == null) {
      throw AccountGroupException(
        'Account group $groupId has no currency set yet.',
      );
    }

    late AccountRow created;
    await _db.transaction(() async {
      created = await _db
          .into(_db.accounts)
          .insertReturning(
            AccountsCompanion.insert(
              name: name,
              type: type,
              groupId: Value(groupId),
            ),
          );
    });

    if (openingBalanceMinor != null) {
      await _postOpeningBalance(
        account: created,
        openingBalanceMinor: openingBalanceMinor,
      );
    }
    return _toDomainAccount(created);
  }

  Future<void> _postOpeningBalance({
    required AccountRow account,
    required int openingBalanceMinor,
  }) async {
    // Option A: asset +O / equity −O; liability −O / equity +O.
    final (financialAmount, equityAmount) = account.type == AccountType.asset
        ? (openingBalanceMinor, -openingBalanceMinor)
        : (-openingBalanceMinor, openingBalanceMinor);

    await _appendSignedEntry(
      transactionDate: _dateOnly(DateTime.now()),
      description: 'Opening balance',
      reversesEntryId: null,
      postings: [
        (accountId: account.id, amountMinor: financialAmount, lineNumber: 1),
        (
          accountId: openingBalanceEquityAccountId,
          amountMinor: equityAmount,
          lineNumber: 2,
        ),
      ],
    );
  }

  Future<void> renameFinancialAccount({
    required String id,
    required String newName,
  }) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null ||
        (row.type != AccountType.asset && row.type != AccountType.liability)) {
      throw AccountGroupException('Account $id is not a financial account.');
    }
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(name: Value(newName)),
    );
  }

  Future<void> reassignFinancialAccountGroup({
    required String id,
    required String groupId,
  }) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (account == null ||
        (account.type != AccountType.asset &&
            account.type != AccountType.liability)) {
      throw AccountGroupException('Account $id is not a financial account.');
    }
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(groupId))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException('Account group $groupId not found.');
    }
    final expectedKind = account.type == AccountType.asset
        ? AccountGroupKind.assetGroup
        : AccountGroupKind.liabilityGroup;
    if (group.kind != expectedKind) {
      throw AccountGroupException(
        'Account type ${account.type} does not match group kind ${group.kind}.',
      );
    }
    // multi-currency-support: reassigning across currencies would silently
    // reinterpret the account's entire historical balance in a new
    // currency - rejected regardless of whether the account has any
    // postings yet (design.md Decision 1).
    if (account.groupId != null) {
      final currentGroup = await (_db.select(
        _db.accountGroups,
      )..where((g) => g.id.equals(account.groupId!))).getSingleOrNull();
      if (currentGroup != null && currentGroup.currency != group.currency) {
        throw AccountGroupException(
          'Cannot reassign to a group with a different currency '
          '(${currentGroup.currency} -> ${group.currency}).',
        );
      }
    }
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(groupId: Value(groupId)),
    );
  }

  /// Changes an account group's currency. Rejected while the group has at
  /// least one active financial account, since that would retroactively
  /// reinterpret its members' historical balances (multi-currency-support
  /// design.md Open Questions).
  Future<void> changeAccountGroupCurrency({
    required String groupId,
    required String currency,
  }) async {
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(groupId))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException('Account group $groupId not found.');
    }
    final activeMembers =
        await (_db.select(_db.accounts)..where(
              (a) =>
                  a.groupId.equals(groupId) &
                  (a.type.equalsValue(AccountType.asset) |
                      a.type.equalsValue(AccountType.liability)) &
                  a.archivedAt.isNull(),
            ))
            .get();
    if (activeMembers.isNotEmpty) {
      throw AccountGroupException(
        'Cannot change currency while the group has active financial accounts.',
      );
    }
    await (_db.update(_db.accountGroups)..where((g) => g.id.equals(groupId)))
        .write(AccountGroupsCompanion(currency: Value(currency)));
  }

  Future<void> archiveFinancialAccount(String id) async {
    await _requireActiveFinancialAccount(id);
    final activeCount =
        await (_db.select(_db.accounts)..where(
              (a) =>
                  (a.type.equalsValue(AccountType.asset) |
                      a.type.equalsValue(AccountType.liability)) &
                  a.archivedAt.isNull(),
            ))
            .get();
    if (activeCount.length <= 1) {
      throw LastActiveAccountException(
        'Cannot archive the last active financial account.',
      );
    }
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(archivedAt: Value(DateTime.now())),
    );
  }

  Future<void> renameAccountGroup({
    required String id,
    required String newName,
  }) async {
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException('Account group $id not found.');
    }
    await (_db.update(_db.accountGroups)..where((g) => g.id.equals(id))).write(
      AccountGroupsCompanion(name: Value(newName)),
    );
  }

  /// Creates a user-created account group (custom-account-groups
  /// design.md Decision 5). [currency] must be non-blank - the first
  /// repository-level currency check in this codebase, since every other
  /// currency value today only ever reaches the Repository after a UI
  /// screen's own regex already validated it. `sortOrder` is always `(max
  /// existing sortOrder) + 1`, so a new group sorts after every existing
  /// one.
  Future<AccountGroup> createAccountGroup({
    required String name,
    required AccountGroupKind kind,
    required String currency,
  }) async {
    if (currency.trim().isEmpty) {
      throw AccountGroupException('Currency is required to create a group.');
    }
    final existing = await _db.select(_db.accountGroups).get();
    final nextSortOrder =
        existing.fold<int>(
          -1,
          (max, g) => g.sortOrder > max ? g.sortOrder : max,
        ) +
        1;
    final created = await _db
        .into(_db.accountGroups)
        .insertReturning(
          AccountGroupsCompanion.insert(
            name: name,
            kind: kind,
            sortOrder: nextSortOrder,
            isSystem: false,
            currency: Value(currency),
          ),
        );
    return _toDomainGroup(created);
  }

  /// Archives a user-created account group once it has zero active member
  /// financial accounts (custom-account-groups design.md Decision 3). A
  /// system group ([AccountGroupRow.isSystem]) is rejected outright,
  /// before even checking membership - "System Account Groups Are
  /// Permanent and Renameable" requires they SHALL NOT be archived.
  /// Archiving is not idempotent, mirroring [archiveFinancialAccount]'s
  /// existing "must currently be active" precondition.
  Future<void> archiveAccountGroup(String id) async {
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException('Account group $id not found.');
    }
    if (group.isSystem) {
      throw AccountGroupException('System account groups cannot be archived.');
    }
    if (group.archivedAt != null) {
      throw AccountGroupException('Account group $id is already archived.');
    }
    final activeMembers =
        await (_db.select(_db.accounts)..where(
              (a) =>
                  a.groupId.equals(id) &
                  (a.type.equalsValue(AccountType.asset) |
                      a.type.equalsValue(AccountType.liability)) &
                  a.archivedAt.isNull(),
            ))
            .get();
    if (activeMembers.isNotEmpty) {
      throw AccountGroupException(
        'Cannot archive a group with active financial accounts.',
      );
    }
    await (_db.update(_db.accountGroups)..where((g) => g.id.equals(id))).write(
      AccountGroupsCompanion(archivedAt: Value(DateTime.now())),
    );
  }

  /// No account group - system or user-created, archived or not - can be
  /// permanently deleted (custom-account-groups design.md Non-Goals):
  /// archiving via [archiveAccountGroup] is the only lifecycle action.
  Future<void> deleteAccountGroup(String id) async {
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException('Account group $id not found.');
    }
    throw AccountGroupException('Account groups cannot be deleted.');
  }

  /// Validates `amountMinor > 0`, derives the two postings, stamps
  /// recorded_at automatically via DateTime.now() (never user-supplied),
  /// hashes/chains/signs the entry (ledger-integrity-signing), and writes
  /// everything in one Drift transaction.
  ///
  /// Option A sign table: money in → financial `+amount`; money out →
  /// financial `−amount` (same for asset and liability).
  ///
  /// If [nativeCurrency] differs from the financial account's group
  /// currency, this is a foreign-currency transaction
  /// (multi-currency-support design.md Decisions 6-7): the category leg
  /// always posts [amountMinor] immediately in [nativeCurrency] (it's
  /// already certain). If [accountCurrencyAmountMinor] is supplied (the
  /// rate/fee was known upfront), a single complete entry posts both legs
  /// now. If it's null, the account leg posts provisionally against the
  /// Transfers-in-transit account instead, pending a later
  /// [settlePendingTransfer] call once the real charged amount is known.
  /// When [nativeCurrency] is null or matches the account's own currency,
  /// this is an ordinary same-currency transaction and
  /// [accountCurrencyAmountMinor] must not be supplied.
  Future<String> recordTransaction({
    required int amountMinor,
    required TransactionDirection direction,
    required String categoryId,
    required String financialAccountId,
    required DateTime transactionDate,
    String? description,
    String? nativeCurrency,
    int? accountCurrencyAmountMinor,
  }) async {
    if (amountMinor <= 0) {
      throw InvalidTransactionAmountException(
        'Transaction amount must be positive and non-zero, got $amountMinor.',
      );
    }

    final account = await _requireActiveFinancialAccount(financialAccountId);
    final accountCurrency = await _groupCurrencyFor(account);
    final isForeignCurrency =
        nativeCurrency != null && nativeCurrency != accountCurrency;

    if (!isForeignCurrency && accountCurrencyAmountMinor != null) {
      throw InvalidTransactionAmountException(
        'accountCurrencyAmountMinor must not be supplied for a '
        'same-currency transaction.',
      );
    }

    final (categorySign, clearingOrFinancialSign) = switch (direction) {
      TransactionDirection.moneyIn => (-1, 1),
      TransactionDirection.moneyOut => (1, -1),
    };

    if (!isForeignCurrency) {
      return _appendSignedEntry(
        transactionDate: _dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: [
          (
            accountId: financialAccountId,
            amountMinor: clearingOrFinancialSign * amountMinor,
            lineNumber: 1,
          ),
          (
            accountId: categoryId,
            amountMinor: categorySign * amountMinor,
            lineNumber: 2,
          ),
        ],
      );
    }

    if (accountCurrencyAmountMinor != null) {
      if (accountCurrencyAmountMinor <= 0) {
        throw InvalidTransactionAmountException(
          'Account-currency amount must be positive and non-zero, '
          'got $accountCurrencyAmountMinor.',
        );
      }
      return _appendSignedEntry(
        transactionDate: _dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: [
          (
            accountId: financialAccountId,
            amountMinor: clearingOrFinancialSign * accountCurrencyAmountMinor,
            lineNumber: 1,
          ),
          (
            accountId: categoryId,
            amountMinor: categorySign * amountMinor,
            lineNumber: 2,
          ),
        ],
      );
    }

    return _postProvisionalEntry(
      kind: PendingTransferKind.foreignTransaction,
      sourceAccountId: financialAccountId,
      currency: nativeCurrency,
      categoryId: categoryId,
      clearingAmountMinor: clearingOrFinancialSign * amountMinor,
      otherLeg: (
        accountId: categoryId,
        amountMinor: categorySign * amountMinor,
      ),
      transactionDate: transactionDate,
      description: description,
    );
  }

  /// Same-currency transfer (unchanged single-entry behavior) when both
  /// accounts' groups share a currency. Otherwise a cross-currency
  /// transfer (multi-currency-support design.md Decisions 4/6): if
  /// [destinationAmountMinor] is supplied (the rate was known upfront), a
  /// single complete entry posts both currencies now; if it's null, the
  /// source leg posts provisionally against the Transfers-in-transit
  /// account, pending a later [settlePendingTransfer] call.
  Future<void> recordTransfer({
    required String fromAccountId,
    required String toAccountId,
    required int amountMinor,
    required DateTime transactionDate,
    String? description,
    int? destinationAmountMinor,
  }) async {
    if (amountMinor <= 0) {
      throw InvalidTransferException(
        'Transfer amount must be positive and non-zero, got $amountMinor.',
      );
    }
    if (fromAccountId == toAccountId) {
      throw InvalidTransferException(
        'Source and destination accounts must be distinct.',
      );
    }
    final fromAccount = await _requireActiveFinancialAccount(fromAccountId);
    final toAccount = await _requireActiveFinancialAccount(toAccountId);
    await _postTransfer(
      fromAccount: fromAccount,
      toAccount: toAccount,
      amountMinor: amountMinor,
      transactionDate: transactionDate,
      description: description,
      destinationAmountMinor: destinationAmountMinor,
    );
  }

  /// One outbound transfer of an archived financial account's full current
  /// display balance to a different, active account (spec: "Closeout of an
  /// Archived Account with a Remaining Balance"). The source amount is
  /// always [displayBalanceMinor] at submit time, never a caller-supplied
  /// figure. Cross-currency closeout requires [destinationAmountMinor] so
  /// the posting is a single complete entry — never a pending transfer on
  /// an account the user is retiring.
  Future<void> recordArchivedAccountCloseoutTransfer({
    required String fromAccountId,
    required String toAccountId,
    required DateTime transactionDate,
    String? description,
    int? destinationAmountMinor,
  }) async {
    if (fromAccountId == toAccountId) {
      throw InvalidTransferException(
        'Source and destination accounts must be distinct.',
      );
    }
    final fromAccount = await _requireCloseoutEligibleFinancialAccount(
      fromAccountId,
    );
    final toAccount = await _requireActiveFinancialAccount(toAccountId);
    final amountMinor = await displayBalanceMinor(fromAccountId);
    final fromCurrency = await _groupCurrencyFor(fromAccount);
    final toCurrency = await _groupCurrencyFor(toAccount);
    if (fromCurrency != toCurrency &&
        (destinationAmountMinor == null || destinationAmountMinor <= 0)) {
      throw InvalidTransferException(
        'A cross-currency closeout requires a known destination amount; '
        'a pending transfer is not allowed on an archived account.',
      );
    }
    await _postTransfer(
      fromAccount: fromAccount,
      toAccount: toAccount,
      amountMinor: amountMinor,
      transactionDate: transactionDate,
      description: description,
      destinationAmountMinor: destinationAmountMinor,
    );
  }

  /// Shared posting for [recordTransfer] and
  /// [recordArchivedAccountCloseoutTransfer]. Callers have already
  /// resolved and validated both accounts.
  Future<void> _postTransfer({
    required AccountRow fromAccount,
    required AccountRow toAccount,
    required int amountMinor,
    required DateTime transactionDate,
    String? description,
    int? destinationAmountMinor,
  }) async {
    final fromCurrency = await _groupCurrencyFor(fromAccount);
    final toCurrency = await _groupCurrencyFor(toAccount);
    final isCrossCurrency = fromCurrency != toCurrency;

    if (!isCrossCurrency) {
      if (destinationAmountMinor != null) {
        throw InvalidTransferException(
          'destinationAmountMinor must not be supplied for a '
          'same-currency transfer.',
        );
      }
      await _appendSignedEntry(
        transactionDate: _dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: [
          (accountId: fromAccount.id, amountMinor: -amountMinor, lineNumber: 1),
          (accountId: toAccount.id, amountMinor: amountMinor, lineNumber: 2),
        ],
      );
      return;
    }

    if (destinationAmountMinor != null) {
      if (destinationAmountMinor <= 0) {
        throw InvalidTransferException(
          'Destination amount must be positive and non-zero, '
          'got $destinationAmountMinor.',
        );
      }
      await _appendSignedEntry(
        transactionDate: _dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: [
          (accountId: fromAccount.id, amountMinor: -amountMinor, lineNumber: 1),
          (
            accountId: toAccount.id,
            amountMinor: destinationAmountMinor,
            lineNumber: 2,
          ),
        ],
      );
      return;
    }

    await _postProvisionalEntry(
      kind: PendingTransferKind.transfer,
      sourceAccountId: fromAccount.id,
      currency: fromCurrency,
      destinationAccountId: toAccount.id,
      clearingAmountMinor: amountMinor,
      otherLeg: (accountId: fromAccount.id, amountMinor: -amountMinor),
      transactionDate: transactionDate,
      description: description,
    );
  }

  /// Posts the provisional entry (the known leg + the Transfers-in-transit
  /// leg) and the matching `pending_transfers` row atomically - Drift
  /// nests the inner [_appendSignedEntry] transaction inside this one, so
  /// either both writes land or neither does (multi-currency-support
  /// design.md Decision 4).
  Future<String> _postProvisionalEntry({
    required PendingTransferKind kind,
    required String sourceAccountId,
    required String currency,
    String? categoryId,
    String? destinationAccountId,
    required int clearingAmountMinor,
    required ({String accountId, int amountMinor}) otherLeg,
    required DateTime transactionDate,
    String? description,
  }) async {
    return _db.transaction(() async {
      final entryId = await _appendSignedEntry(
        transactionDate: _dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: [
          (
            accountId: transfersInTransitAccountId,
            amountMinor: clearingAmountMinor,
            lineNumber: 1,
          ),
          (
            accountId: otherLeg.accountId,
            amountMinor: otherLeg.amountMinor,
            lineNumber: 2,
          ),
        ],
      );
      await _db
          .into(_db.pendingTransfers)
          .insert(
            PendingTransfersCompanion.insert(
              kind: kind,
              sourceAccountId: sourceAccountId,
              currency: currency,
              categoryId: Value(categoryId),
              destinationAccountId: Value(destinationAccountId),
              provisionalEntryId: entryId,
              status: PendingTransferStatus.pending,
              initiatedAt: DateTime.now(),
            ),
          );
      return entryId;
    });
  }

  /// Inserts a new entry with swapped posting amounts, referencing
  /// [entryId] via reverses_entry_id, as an independent action with no
  /// required follow-up. The original entry is never modified.
  ///
  /// The reversal's transaction date is today (when the correction is
  /// actually performed), never backdated to the original entry's date -
  /// an auditable ledger should reflect when a correction really
  /// happened, not disguise it as having occurred earlier.
  ///
  /// Rejected if [entryId] is still the open provisional leg of an
  /// unsettled pending transfer (multi-currency-support design.md
  /// Decision 4) - settle it instead, which achieves the same economic
  /// outcome without leaving `pending_transfers` pointing at a reversed
  /// entry while still reporting status pending.
  Future<void> reverseEntry(String entryId) async {
    final stillPending =
        await (_db.select(_db.pendingTransfers)..where(
              (p) =>
                  p.provisionalEntryId.equals(entryId) &
                  p.status.equalsValue(PendingTransferStatus.pending),
            ))
            .getSingleOrNull();
    if (stillPending != null) {
      throw PendingTransferException(
        'Cannot reverse a provisional entry while its pending transfer is '
        'still unsettled. Settle it instead.',
      );
    }

    final original = await (_db.select(
      _db.journalEntries,
    )..where((e) => e.id.equals(entryId))).getSingle();
    final originalPostings = await (_db.select(
      _db.postings,
    )..where((p) => p.entryId.equals(entryId))).get();

    await _appendSignedEntry(
      transactionDate: _dateOnly(DateTime.now()),
      reversesEntryId: original.id,
      postings: [
        for (final p in originalPostings)
          (
            accountId: p.accountId,
            amountMinor: -p.amountMinor,
            lineNumber: p.lineNumber,
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Pending transfers / foreign-currency settlement (multi-currency-support).
  // ---------------------------------------------------------------------

  /// One row per unsettled pending transfer or foreign-currency
  /// transaction, ordered by initiation time - the Home overview's
  /// "Pending transfers" section (design.md Decision 4).
  Stream<List<PendingTransfer>> watchPendingTransfers() {
    final query = _db.select(_db.pendingTransfers)
      ..where((p) => p.status.equalsValue(PendingTransferStatus.pending))
      ..orderBy([(p) => OrderingTerm.asc(p.initiatedAt)]);
    return query.watch().map(
      (rows) => rows.map(_toDomainPendingTransfer).toList(),
    );
  }

  PendingTransfer _toDomainPendingTransfer(PendingTransferRow row) {
    return PendingTransfer(
      id: row.id,
      kind: row.kind,
      sourceAccountId: row.sourceAccountId,
      currency: row.currency,
      categoryId: row.categoryId,
      destinationAccountId: row.destinationAccountId,
      provisionalEntryId: row.provisionalEntryId,
      status: row.status,
      settlementEntryId: row.settlementEntryId,
      feeEntryId: row.feeEntryId,
      initiatedAt: row.initiatedAt,
      settledAt: row.settledAt,
    );
  }

  Future<void> _requireActiveExpenseCategory(String id) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null || row.type != AccountType.expense) {
      throw PendingTransferException('$id is not an active Expense category.');
    }
    if (row.archivedAt != null) {
      throw PendingTransferException('$id is not an active Expense category.');
    }
  }

  /// Settles a pending transfer or foreign-currency transaction
  /// (multi-currency-support design.md Decision 5).
  ///
  /// For `kind = transfer`, [settledToAccountId] must be the pending
  /// transfer's own source or destination account. Settling to the
  /// **source** (the transfer bounced/returned) compares [settledAmountMinor]
  /// to the provisional amount - both in the source currency - and posts
  /// any shortfall as a fee/loss entry against [feeCategoryId]. Settling
  /// to the **destination** (normal delivery) posts [settledAmountMinor]
  /// alone in the destination currency, with no shortfall comparison
  /// (there is nothing in that currency to compare it against) and
  /// [feeCategoryId] must not be supplied.
  ///
  /// For `kind = foreignTransaction`, [settledToAccountId] is ignored -
  /// settlement always resolves to the pending transfer's own
  /// `sourceAccountId` (the financial account the transaction was against)
  /// - and always follows the no-shortfall path, the same as settling a
  /// transfer to its destination: the provisional entry's clearing leg was
  /// posted in the transaction's native currency, while settlement is in
  /// the account's own currency, so there is no shared-currency figure to
  /// compare a shortfall against (corrected during apply - an earlier pass
  /// of this design wrongly described this as shortfall-comparable).
  Future<void> settlePendingTransfer({
    required String pendingTransferId,
    required String settledToAccountId,
    required int settledAmountMinor,
    String? feeCategoryId,
  }) async {
    if (settledAmountMinor < 0) {
      throw PendingTransferException(
        'Settled amount must not be negative, got $settledAmountMinor.',
      );
    }

    final pending = await (_db.select(
      _db.pendingTransfers,
    )..where((p) => p.id.equals(pendingTransferId))).getSingleOrNull();
    if (pending == null) {
      throw PendingTransferException(
        'Pending transfer $pendingTransferId not found.',
      );
    }
    if (pending.status == PendingTransferStatus.settled) {
      throw PendingTransferException(
        'Pending transfer $pendingTransferId is already settled.',
      );
    }

    final resolvedTarget =
        pending.kind == PendingTransferKind.foreignTransaction
        ? pending.sourceAccountId
        : settledToAccountId;
    if (pending.kind == PendingTransferKind.transfer &&
        resolvedTarget != pending.sourceAccountId &&
        resolvedTarget != pending.destinationAccountId) {
      throw PendingTransferException(
        'settledToAccountId must be the pending transfer\'s own source or '
        'destination account.',
      );
    }

    // Shortfall comparison only applies to a transfer settling back to its
    // own source - never a transfer settling to its destination, and never
    // a foreignTransaction (see method doc for why).
    final isShortfallComparable =
        pending.kind == PendingTransferKind.transfer &&
        resolvedTarget == pending.sourceAccountId;

    if (!isShortfallComparable && feeCategoryId != null) {
      throw PendingTransferException(
        'feeCategoryId is only applicable when settling a transfer back to '
        'its own source account.',
      );
    }
    // The destination-delivery / foreignTransaction path has no fee
    // mechanism to close a shortfall with - a settlement of exactly zero
    // would post no entry at all (guarded below) and permanently leave the
    // Transfers-in-transit position for this item unclosed even though
    // status flips to settled. A genuine total loss is a shortfall-path
    // concept (settle back to the source for 0, which the fee entry
    // covers in full) - reject zero here instead of silently no-opping.
    if (!isShortfallComparable && settledAmountMinor == 0) {
      throw PendingTransferException(
        'Settled amount must be positive when settling to the destination '
        'or a foreign-currency transaction - use the source-account path '
        'for a total loss.',
      );
    }

    final provisionalPostings = await (_db.select(
      _db.postings,
    )..where((p) => p.entryId.equals(pending.provisionalEntryId))).get();
    final clearingPosting = provisionalPostings.firstWhere(
      (p) => p.accountId == transfersInTransitAccountId,
    );
    final clearingPhase1Sign = clearingPosting.amountMinor < 0 ? -1 : 1;
    final provisionalAmountAbs = clearingPosting.amountMinor.abs();

    if (isShortfallComparable && settledAmountMinor > provisionalAmountAbs) {
      throw PendingTransferException(
        'Settled amount ($settledAmountMinor) cannot exceed the provisional '
        'amount ($provisionalAmountAbs) when settling back to the source '
        'account.',
      );
    }

    final shortfall = isShortfallComparable
        ? provisionalAmountAbs - settledAmountMinor
        : 0;
    if (shortfall > 0 && feeCategoryId == null) {
      throw PendingTransferException(
        'feeCategoryId is required when the settled amount is less than '
        'the provisional amount.',
      );
    }
    if (feeCategoryId != null) {
      await _requireActiveExpenseCategory(feeCategoryId);
    }

    await _db.transaction(() async {
      String? settlementEntryId;
      if (settledAmountMinor > 0) {
        settlementEntryId = await _appendSignedEntry(
          transactionDate: _dateOnly(DateTime.now()),
          description: 'Settlement',
          reversesEntryId: null,
          postings: [
            (
              accountId: resolvedTarget,
              amountMinor: clearingPhase1Sign * settledAmountMinor,
              lineNumber: 1,
            ),
            (
              accountId: transfersInTransitAccountId,
              amountMinor: -clearingPhase1Sign * settledAmountMinor,
              lineNumber: 2,
            ),
          ],
        );
      }

      String? feeEntryId;
      if (shortfall > 0) {
        feeEntryId = await _appendSignedEntry(
          transactionDate: _dateOnly(DateTime.now()),
          description: 'Transfer fee / shortfall',
          reversesEntryId: null,
          postings: [
            (
              accountId: feeCategoryId!,
              amountMinor: clearingPhase1Sign * shortfall,
              lineNumber: 1,
            ),
            (
              accountId: transfersInTransitAccountId,
              amountMinor: -clearingPhase1Sign * shortfall,
              lineNumber: 2,
            ),
          ],
        );
      }

      await (_db.update(
        _db.pendingTransfers,
      )..where((p) => p.id.equals(pendingTransferId))).write(
        PendingTransfersCompanion(
          status: const Value(PendingTransferStatus.settled),
          settlementEntryId: Value(settlementEntryId),
          feeEntryId: Value(feeEntryId),
          settledAt: Value(DateTime.now()),
        ),
      );
    });
  }

  /// Shared by [recordTransaction] and [reverseEntry]: computes the
  /// canonical hash, signs it, chains onto the current trusted tip, and
  /// writes the entry + postings + an immediate "verified" cache row in
  /// one transaction. If the trusted tip currently lags behind the
  /// physically last-inserted entry (a chain break was detected and not
  /// yet re-anchored by new activity), this is the re-anchor moment and a
  /// `CHAIN_REANCHORED` integrity event is recorded (spec: "Re-anchoring
  /// After a Break"). Returns the new entry's id.
  Future<String> _appendSignedEntry({
    required String transactionDate,
    String? description,
    String? reversesEntryId,
    required List<({String accountId, int amountMinor, int lineNumber})>
    postings,
  }) async {
    final identity = await currentIdentity();
    if (identity == null) {
      throw StateError(
        'No signing identity is set up on this device - '
        'confirmFirstIdentity/restoreIdentity must run before recording a transaction.',
      );
    }

    return _db.transaction(() async {
      final chainState = await _chainState();
      final priorLastEntry =
          await (_db.select(_db.journalEntries)
                ..orderBy([(e) => OrderingTerm.desc(e.deviceChainSequence)])
                ..limit(1))
              .getSingleOrNull();
      final isReanchor =
          priorLastEntry != null &&
          priorLastEntry.id != chainState.trustedTipEntryId;

      final previousHash =
          chainState.trustedTipHash ??
          Uint8List.fromList(genesisPreviousEntryHash);
      final sequence = chainState.nextDeviceChainSequence;
      final id = const Uuid().v4();
      final recordedAt = _truncateToStoredPrecision(DateTime.now());

      final canonicalPostings = postings
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
        id: id,
        deviceChainSequence: sequence,
        transactionDate: transactionDate,
        recordedAt: recordedAt,
        description: description,
        reversesEntryId: reversesEntryId,
        signedByIdentityId: identity.identityId,
        postings: canonicalPostings,
      );
      final entryHash = await hashCanonicalEntry(bytes);
      final signature = await _signingKeyService.sign(entryHash);

      await _db
          .into(_db.journalEntries)
          .insert(
            JournalEntriesCompanion.insert(
              id: Value(id),
              transactionDate: transactionDate,
              recordedAt: recordedAt,
              description: Value(description),
              reversesEntryId: Value(reversesEntryId),
              deviceChainSequence: sequence,
              previousEntryHash: previousHash,
              entryHash: entryHash,
              signedByIdentityId: identity.identityId,
              signature: signature,
            ),
          );

      for (final p in postings) {
        await _db
            .into(_db.postings)
            .insert(
              PostingsCompanion.insert(
                entryId: id,
                accountId: p.accountId,
                amountMinor: p.amountMinor,
                lineNumber: p.lineNumber,
              ),
            );
      }

      await _upsertVerificationCache(
        entryId: id,
        isVerified: true,
        breakReason: null,
      );

      if (isReanchor) {
        await _db
            .into(_db.integrityEvents)
            .insert(
              IntegrityEventsCompanion.insert(
                eventType: IntegrityEventType.chainReanchored,
                relatedEntryId: Value(id),
                detail: Value(
                  'Re-anchored onto ${chainState.trustedTipEntryId ?? "genesis"} '
                  'after a chain break; entry $id is the first post-break entry.',
                ),
              ),
            );
      }

      await _updateChainState(
        trustedTipEntryId: id,
        trustedTipHash: entryHash,
        nextDeviceChainSequence: sequence + 1,
      );

      return id;
    });
  }

  Future<ChainStateRow> _chainState() async {
    final existing =
        await (_db.select(_db.ledgerChainState)
              ..where((t) => t.id.equals(ledgerChainStateSingletonId)))
            .getSingleOrNull();
    if (existing != null) return existing;
    return _db
        .into(_db.ledgerChainState)
        .insertReturning(
          LedgerChainStateCompanion.insert(
            id: ledgerChainStateSingletonId,
            nextDeviceChainSequence: 0,
          ),
        );
  }

  Future<void> _updateChainState({
    required String? trustedTipEntryId,
    required Uint8List? trustedTipHash,
    required int nextDeviceChainSequence,
  }) {
    return _db
        .into(_db.ledgerChainState)
        .insertOnConflictUpdate(
          LedgerChainStateCompanion(
            id: const Value(ledgerChainStateSingletonId),
            trustedTipEntryId: Value(trustedTipEntryId),
            trustedTipHash: Value(trustedTipHash),
            nextDeviceChainSequence: Value(nextDeviceChainSequence),
          ),
        );
  }

  Future<void> _upsertVerificationCache({
    required String entryId,
    required bool isVerified,
    required VerificationBreakReason? breakReason,
  }) {
    return _db
        .into(_db.entryVerificationCache)
        .insertOnConflictUpdate(
          EntryVerificationCacheCompanion.insert(
            entryId: entryId,
            isVerified: isVerified,
            breakReason: Value(breakReason),
            checkedAt: DateTime.now(),
          ),
        );
  }

  /// [type] must be [AccountType.income] or [AccountType.expense].
  Future<void> addCategory({
    required String name,
    required AccountType type,
  }) async {
    if (type != AccountType.income && type != AccountType.expense) {
      throw ArgumentError.value(type, 'type', 'must be income or expense');
    }
    await _db
        .into(_db.accounts)
        .insert(AccountsCompanion.insert(name: name, type: type));
  }

  Future<void> renameCategory({
    required String id,
    required String newName,
  }) async {
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(name: Value(newName)),
    );
  }

  Future<void> archiveCategory(String id) async {
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(archivedAt: Value(DateTime.now())),
    );
  }

  /// Reactive stream of entries that post to [financialAccountId], ordered
  /// chronologically. Includes verification status; running balance should
  /// be computed by the ViewModel using [displayBalanceDeltaFor].
  Stream<List<JournalEntry>> watchEntriesForAccount(String financialAccountId) {
    return watchEntries().map(
      (entries) => entries
          .where(
            (e) => e.postings.any((p) => p.accountId == financialAccountId),
          )
          .toList(),
    );
  }

  /// Display-balance contribution of one posting on a financial account.
  /// Asset: raw amount. Liability owed: negated amount (Option A).
  static int displayBalanceDeltaFor({
    required AccountType accountType,
    required int postingAmountMinor,
  }) {
    return switch (accountType) {
      AccountType.asset => postingAmountMinor,
      AccountType.liability => -postingAmountMinor,
      AccountType.equity ||
      AccountType.clearing ||
      AccountType.income ||
      AccountType.expense => 0,
    };
  }

  /// Current display balance for a financial account (quarantine/supersession
  /// exclusions applied).
  Future<int> displayBalanceMinor(String financialAccountId) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(financialAccountId))).getSingle();
    final entries = await watchEntriesForAccount(financialAccountId).first;
    var balance = 0;
    for (final entry in entries) {
      if (!entry.isVerified || entry.isSupersededByMigration) continue;
      for (final posting in entry.postings) {
        if (posting.accountId != financialAccountId) continue;
        balance += displayBalanceDeltaFor(
          accountType: account.type,
          postingAmountMinor: posting.amountMinor,
        );
      }
    }
    return balance;
  }

  Stream<HomeOverview> watchHomeOverview() {
    return watchEntries().asyncMap((_) => _buildHomeOverview());
  }

  Future<HomeOverview> _buildHomeOverview() async {
    final groups = await watchAccountGroups(includeArchived: true).first;
    final accounts = await watchFinancialAccounts(includeArchived: true).first;
    final entries = await watchEntries().first;
    final pendingRows = await (_db.select(
      _db.pendingTransfers,
    )..where((p) => p.status.equalsValue(PendingTransferStatus.pending))).get();

    final rawSumByAccount = <String, int>{};
    for (final entry in entries) {
      if (!entry.isVerified || entry.isSupersededByMigration) continue;
      for (final posting in entry.postings) {
        rawSumByAccount[posting.accountId] =
            (rawSumByAccount[posting.accountId] ?? 0) + posting.amountMinor;
      }
    }

    int displayFor(Account account) {
      final raw = rawSumByAccount[account.id] ?? 0;
      return displayBalanceDeltaFor(
        accountType: account.type,
        postingAmountMinor: raw,
      );
    }

    final assetsByCurrency = <String, int>{};
    final liabilitiesByCurrency = <String, int>{};
    final sections = <AccountGroupSection>[];

    for (final group in groups) {
      final members = accounts.where((a) => a.groupId == group.id).toList()
        ..sort((a, b) {
          final byOrder = a.sortOrder.compareTo(b.sortOrder);
          return byOrder != 0 ? byOrder : a.name.compareTo(b.name);
        });
      if (members.isEmpty) continue;

      final currency = group.currency;
      final balances = <AccountBalance>[];
      var groupTotal = 0;
      for (final account in members) {
        final display = displayFor(account);
        balances.add(
          AccountBalance(account: account, displayBalanceMinor: display),
        );
        groupTotal += display;
        if (currency != null) {
          if (account.type == AccountType.asset) {
            assetsByCurrency[currency] =
                (assetsByCurrency[currency] ?? 0) + display;
          } else if (account.type == AccountType.liability) {
            liabilitiesByCurrency[currency] =
                (liabilitiesByCurrency[currency] ?? 0) + display;
          }
        }
      }
      sections.add(
        AccountGroupSection(
          group: group,
          accounts: balances,
          totalDisplayBalanceMinor: groupTotal,
        ),
      );
    }

    // Pending transfers: shown as their own line items, and their
    // provisional amount counts toward their source currency's net
    // position while unsettled - unless the provisional entry itself is
    // quarantined or migration-superseded, in which case it's excluded
    // from the totals but still listed for review (multi-currency-support
    // design.md Decision 2 / spec "A quarantined or superseded provisional
    // entry does not distort net worth").
    final entryById = {for (final e in entries) e.id: e};
    final allAccountRows = await _db.select(_db.accounts).get();
    final nameById = {for (final a in allAccountRows) a.id: a.name};
    final pendingSummaries = <PendingTransferSummary>[];

    for (final row in pendingRows) {
      final provisionalEntry = entryById[row.provisionalEntryId];
      if (provisionalEntry == null) continue;
      final clearingPosting = provisionalEntry.postings.firstWhere(
        (p) => p.accountId == transfersInTransitAccountId,
        orElse: () => provisionalEntry.postings.first,
      );
      final amountAbs = clearingPosting.amountMinor.abs();
      // The currency the clearing leg was actually posted in - the source
      // account's own currency for a transfer, but the transaction's
      // *native* currency for a foreignTransaction, which can differ from
      // the financial account's own group currency (never re-derive this
      // from the source account's group - that mislabels a
      // foreignTransaction's amount with the wrong currency).
      final currency = row.currency;
      final destinationLabel =
          nameById[row.destinationAccountId] ?? nameById[row.categoryId];

      pendingSummaries.add(
        PendingTransferSummary(
          pendingTransfer: _toDomainPendingTransfer(row),
          sourceAccountName:
              nameById[row.sourceAccountId] ?? row.sourceAccountId,
          destinationLabel: destinationLabel,
          currency: currency,
          amountMinor: amountAbs,
        ),
      );

      final isExcluded =
          !provisionalEntry.isVerified ||
          provisionalEntry.isSupersededByMigration;
      if (!isExcluded) {
        assetsByCurrency[currency] =
            (assetsByCurrency[currency] ?? 0) + amountAbs;
      }
    }

    final currencies = {
      ...assetsByCurrency.keys,
      ...liabilitiesByCurrency.keys,
    }.toList()..sort();
    final netPositions = currencies
        .map(
          (currency) => CurrencyNetPosition(
            currency: currency,
            totalAssetsMinor: assetsByCurrency[currency] ?? 0,
            totalLiabilitiesMinor: liabilitiesByCurrency[currency] ?? 0,
          ),
        )
        .toList();

    return HomeOverview(
      sections: sections,
      netPositionsByCurrency: netPositions,
      pendingTransfers: pendingSummaries,
    );
  }

  /// Total income and total expense posted within [start]..[end]
  /// (inclusive), based on transaction date. Both totals are positive
  /// magnitudes; a reversed entry's postings net out automatically since
  /// they carry opposite signs to the original. Postings belonging to a
  /// quarantined (unverified) entry are excluded (spec: "Quarantine of
  /// Entries After a Break"). Transfers and opening balances are excluded
  /// because only income/expense account types accumulate. Optional
  /// [financialAccountId] filters to entries that affect that account.
  Stream<LedgerSummary> watchSummary({
    required DateTime start,
    required DateTime end,
    String? financialAccountId,
  }) {
    final startDate = _dateOnly(start);
    final endDate = _dateOnly(end);

    final query =
        _db.select(_db.postings).join([
          innerJoin(
            _db.journalEntries,
            _db.journalEntries.id.equalsExp(_db.postings.entryId),
          ),
          innerJoin(
            _db.accounts,
            _db.accounts.id.equalsExp(_db.postings.accountId),
          ),
          leftOuterJoin(
            _db.entryVerificationCache,
            _db.entryVerificationCache.entryId.equalsExp(_db.postings.entryId),
          ),
        ])..where(
          _db.journalEntries.transactionDate.isBiggerOrEqualValue(startDate) &
              _db.journalEntries.transactionDate.isSmallerOrEqualValue(endDate),
        );

    return query.watch().asyncMap((rows) async {
      final supersededEntryIds = <String>{
        for (final row in rows)
          ?row.readTable(_db.journalEntries).migratedFromEntryId,
      };

      Set<String>? entryIdsTouchingAccount;
      if (financialAccountId != null) {
        entryIdsTouchingAccount = {
          for (final row in rows)
            if (row.readTable(_db.postings).accountId == financialAccountId)
              row.readTable(_db.journalEntries).id,
        };
      }

      var totalIncomeMinor = 0;
      var totalExpenseMinor = 0;
      for (final row in rows) {
        final entry = row.readTable(_db.journalEntries);
        if (supersededEntryIds.contains(entry.id)) continue;
        if (entryIdsTouchingAccount != null &&
            !entryIdsTouchingAccount.contains(entry.id)) {
          continue;
        }

        final verification = row.readTableOrNull(_db.entryVerificationCache);
        if (verification != null && !verification.isVerified) continue;

        final account = row.readTable(_db.accounts);
        final posting = row.readTable(_db.postings);
        switch (account.type) {
          case AccountType.income:
            totalIncomeMinor -= posting.amountMinor;
          case AccountType.expense:
            totalExpenseMinor += posting.amountMinor;
          case AccountType.asset:
          case AccountType.liability:
          case AccountType.equity:
          case AccountType.clearing:
            break;
        }
      }
      return LedgerSummary(
        totalIncomeMinor: totalIncomeMinor,
        totalExpenseMinor: totalExpenseMinor,
      );
    });
  }

  /// The append-only audit log of chain breaks, re-anchors, and key
  /// migrations, newest first.
  Stream<List<IntegrityEvent>> watchIntegrityEvents() {
    final query = _db.select(_db.integrityEvents)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => IntegrityEvent(
              eventId: row.eventId,
              eventType: row.eventType,
              occurredAt: row.occurredAt,
              relatedEntryId: row.relatedEntryId,
              relatedIdentityId: row.relatedIdentityId,
              detail: row.detail,
            ),
          )
          .toList(),
    );
  }

  /// Encrypted keystore file export of the device's current signing key
  /// (spec: "Optional keystore file export"). Passthrough to
  /// [SigningKeyService] - the only place private key bytes are ever
  /// touched.
  Future<String> exportKeystoreFile({required String passphrase}) {
    return _signingKeyService.exportKeystoreFile(passphrase: passphrase);
  }
}

/// Result of one [LedgerRepository.verifyChain] pass.
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

/// Drift's `DateTimeColumn` stores values as whole-second unix timestamps
/// by default, so a value hashed at write time with millisecond precision
/// would never match what verifyChain recomputes after reading the same
/// value back from the database. Truncating before hashing (and before
/// storing) keeps the two in sync.
DateTime _truncateToStoredPrecision(DateTime dateTime) {
  final seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
  return DateTime.fromMillisecondsSinceEpoch(
    seconds * 1000,
    isUtc: dateTime.isUtc,
  );
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

String _dateOnly(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
