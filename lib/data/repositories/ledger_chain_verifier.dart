import 'package:drift/drift.dart';

import '../../domain/crypto/entry_canonical_hash.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../../domain/models/integrity_event.dart';
import '../database/app_database.dart';
import '../database/tables/entry_verification_cache_table.dart';
import 'ledger_chain_store.dart';
import 'repository_date_utils.dart';

/// Full-chain hash/signature/link verification and tip/cache rebuild.
/// Leaf module: [AppDatabase] + [SigningKeyService] + [LedgerChainStore]
/// only — no Identity/Account/Ledger posting deps (ADR 0002).
class LedgerChainVerifier {
  LedgerChainVerifier({
    required AppDatabase database,
    SigningKeyService? signingKeyService,
    LedgerChainStore? chain,
  }) : _db = database,
       _signingKeyService = signingKeyService ?? SigningKeyService(),
       _chain = chain ?? LedgerChainStore(database);

  final AppDatabase _db;
  final SigningKeyService _signingKeyService;
  final LedgerChainStore _chain;

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
}

/// Result of one [LedgerChainVerifier.verifyChain] pass.
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
