import 'package:drift/drift.dart';

import '../../domain/models/signing_identity.dart';
import '../database/app_database.dart';
import '../database/tables/entry_verification_cache_table.dart';
import '../database/tables/ledger_chain_state_table.dart';

/// Shared trusted-tip and verification-cache persistence for posting and
/// identity. Talks only to [AppDatabase] so Identity → Account → Ledger
/// stays acyclic (extract-ledger-chain-store).
///
/// Per-identity tips live in [ledgerIdentityChainTips] (linked-devices
/// multi-chain). The singleton [ledgerChainState] remains the local write
/// tip mirror used by existing callers and stays aligned with the local
/// signing identity's tip row.
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

  /// Tip row for one signing identity, or null when never written.
  Future<IdentityChainTipRow?> loadIdentityTip(String identityId) {
    return (_db.select(
      _db.ledgerIdentityChainTips,
    )..where((t) => t.identityId.equals(identityId))).getSingleOrNull();
  }

  /// Ensures a tip row exists for [identityId] (genesis sequence 0).
  Future<IdentityChainTipRow> ensureIdentityTip(String identityId) async {
    final existing = await loadIdentityTip(identityId);
    if (existing != null) return existing;
    return _db
        .into(_db.ledgerIdentityChainTips)
        .insertReturning(
          LedgerIdentityChainTipsCompanion.insert(
            identityId: identityId,
            nextDeviceChainSequence: 0,
          ),
        );
  }

  Future<void> updateIdentityTip({
    required String identityId,
    required String? trustedTipEntryId,
    required Uint8List? trustedTipHash,
    required int nextDeviceChainSequence,
  }) {
    return _db
        .into(_db.ledgerIdentityChainTips)
        .insertOnConflictUpdate(
          LedgerIdentityChainTipsCompanion(
            identityId: Value(identityId),
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

  /// Active (non-superseded, non-continued) signing identities, newest first.
  Future<List<SigningIdentity>> activeSigningIdentities() async {
    final rows =
        await (_db.select(_db.signingIdentities)
              ..where((t) => t.supersededAt.isNull() & t.continuedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map(_toDomain).toList();
  }

  /// Active signing identity matching [publicKey], or the newest active
  /// identity when [publicKey] is null / unmatched (single-device fallback).
  Future<SigningIdentity?> currentSigningIdentity({
    List<int>? matchingPublicKey,
  }) async {
    final active = await activeSigningIdentities();
    if (active.isEmpty) return null;
    if (matchingPublicKey != null) {
      for (final identity in active) {
        if (_bytesEqual(identity.publicKey, matchingPublicKey)) {
          return identity;
        }
      }
    }
    return active.first;
  }

  SigningIdentity _toDomain(IdentityRow row) {
    return SigningIdentity(
      identityId: row.identityId,
      publicKey: row.publicKey,
      createdAt: row.createdAt,
      supersedesIdentityId: row.supersedesIdentityId,
      supersededAt: row.supersededAt,
      continuesIdentityId: row.continuesIdentityId,
      continuedAt: row.continuedAt,
      acknowledgedAt: row.acknowledgedAt,
    );
  }

  bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
