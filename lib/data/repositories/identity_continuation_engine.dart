import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/crypto/signing_key_service.dart';
import '../../domain/models/integrity_event.dart';
import '../../domain/models/signing_identity.dart';
import '../database/app_database.dart';
import 'ledger_chain_store.dart';
import 'ledger_chain_verifier.dart';

/// Continues books under a new this-device-only Signing Identity without
/// rewriting any entry (ADR 0004 / books-copy-and-continuation).
///
/// Leaf engine: [AppDatabase], [LedgerChainStore], [LedgerChainVerifier],
/// [SigningKeyService] only — stays below [IdentityRepository] and closes
/// no construction cycle (ADR 0002).
class IdentityContinuationEngine {
  IdentityContinuationEngine({
    required AppDatabase database,
    required LedgerChainStore chain,
    required LedgerChainVerifier chainVerifier,
    SigningKeyService? signingKeyService,
  }) : _db = database,
       _chain = chain,
       _chainVerifier = chainVerifier,
       _signingKeyService = signingKeyService ?? SigningKeyService();

  final AppDatabase _db;
  final LedgerChainStore _chain;
  final LedgerChainVerifier _chainVerifier;
  final SigningKeyService _signingKeyService;

  /// Continues the current books under a new identity. Returns the new
  /// identity. When the stored key already matches the active identity,
  /// returns that identity without creating a Continuation.
  Future<SigningIdentity> continueBooks({DateTime? copySavedAt}) async {
    final previous = await _chain.currentSigningIdentity();
    if (previous == null) {
      throw StateError(
        'Cannot continue books without an active signing identity.',
      );
    }

    final stored = await _signingKeyService.loadStoredKeyMaterial();
    if (stored != null && _bytesEqual(stored.publicKey, previous.publicKey)) {
      // Restoring a copy onto the phone that still holds its key: no
      // Continuation (design Decision 4 edge case).
      return previous;
    }

    final verification = await _chainVerifier.verifyChain();
    final generated = await _signingKeyService.generateNewIdentity();
    final continuedAt = DateTime.now();

    late IdentityRow newRow;
    await _db.transaction(() async {
      newRow = await _db
          .into(_db.signingIdentities)
          .insertReturning(
            SigningIdentitiesCompanion.insert(
              publicKey: Uint8List.fromList(generated.keyMaterial.publicKey),
              continuesIdentityId: Value(previous.identityId),
              acknowledgedAt: Value(continuedAt),
            ),
          );

      await (_db.update(_db.signingIdentities)
            ..where((t) => t.identityId.equals(previous.identityId)))
          .write(SigningIdentitiesCompanion(continuedAt: Value(continuedAt)));

      final chainState = await _chain.loadState();
      // Tip already points at the trusted (last verified) entry after
      // verifyChain; keep sequence counter and tip so the next entry
      // chains there.
      await _chain.updateState(
        trustedTipEntryId: chainState.trustedTipEntryId,
        trustedTipHash: chainState.trustedTipHash,
        nextDeviceChainSequence: chainState.nextDeviceChainSequence,
      );

      final detail = jsonEncode({
        'newId': newRow.identityId,
        'previousId': previous.identityId,
        'continuationEntryHash': chainState.trustedTipHash == null
            ? null
            : base64Encode(chainState.trustedTipHash!),
        'copySavedAt': copySavedAt?.toUtc().toIso8601String(),
        'breakEntryId': verification.breakEntryId,
      });

      await _db
          .into(_db.integrityEvents)
          .insert(
            IntegrityEventsCompanion.insert(
              eventType: IntegrityEventType.identityContinued,
              relatedIdentityId: Value(newRow.identityId),
              relatedEntryId: Value(chainState.trustedTipEntryId),
              detail: Value(detail),
            ),
          );
    });

    return SigningIdentity(
      identityId: newRow.identityId,
      publicKey: newRow.publicKey,
      createdAt: newRow.createdAt,
      supersedesIdentityId: newRow.supersedesIdentityId,
      supersededAt: newRow.supersededAt,
      continuesIdentityId: newRow.continuesIdentityId,
      continuedAt: newRow.continuedAt,
      acknowledgedAt: newRow.acknowledgedAt,
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
