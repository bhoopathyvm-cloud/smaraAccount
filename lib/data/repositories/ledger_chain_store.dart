import 'package:drift/drift.dart';

import '../../domain/models/signing_identity.dart';
import '../database/app_database.dart';
import '../database/tables/entry_verification_cache_table.dart';
import '../database/tables/ledger_chain_state_table.dart';

/// Shared trusted-tip and verification-cache persistence for posting and
/// identity. Talks only to [AppDatabase] so Identity → Account → Ledger
/// stays acyclic (extract-ledger-chain-store).
class LedgerChainStore {
  LedgerChainStore(this._db);

  final AppDatabase _db;

  /// Singleton chain-state row, inserting genesis state if missing.
  Future<ChainStateRow> loadState() async {
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

  Future<void> updateState({
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

  Future<void> upsertVerificationCache({
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

  /// Rebuilds the cache from a full verify pass (delete + insert).
  Future<void> replaceVerificationCache(
    Iterable<
      ({String entryId, bool isVerified, VerificationBreakReason? breakReason})
    >
    rows,
  ) async {
    await _db.delete(_db.entryVerificationCache).go();
    final now = DateTime.now();
    for (final row in rows) {
      await _db
          .into(_db.entryVerificationCache)
          .insert(
            EntryVerificationCacheCompanion.insert(
              entryId: row.entryId,
              isVerified: row.isVerified,
              breakReason: Value(row.breakReason),
              checkedAt: now,
            ),
          );
    }
  }

  /// Active (non-superseded) signing identity, or null before first setup.
  /// Read-only db lookup so posting never imports [IdentityRepository].
  Future<SigningIdentity?> currentSigningIdentity() async {
    final row =
        await (_db.select(_db.signingIdentities)
              ..where((t) => t.supersededAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return SigningIdentity(
      identityId: row.identityId,
      publicKey: row.publicKey,
      createdAt: row.createdAt,
      supersedesIdentityId: row.supersedesIdentityId,
      supersededAt: row.supersededAt,
      acknowledgedAt: row.acknowledgedAt,
    );
  }
}
