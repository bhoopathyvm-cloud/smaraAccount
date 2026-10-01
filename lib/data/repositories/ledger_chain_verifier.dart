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
///
/// Walks each [signedByIdentityId] hash chain independently (linked-devices
/// design Decision 3). A break quarantines only that identity's damaged
/// tail; other identities' verified entries stay trusted.
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

  /// Walks every identity's chain, recomputing hashes and checking
  /// signatures and linkage, and rebuilds `entry_verification_cache` from
  /// scratch. Updates per-identity tip rows and mirrors the local signing
  /// identity's tip onto the singleton `ledger_chain_state` row.
  Future<ChainVerificationResult> verifyChain() async {
    return _db.transaction(() async {
      final entries = await (_db.select(
        _db.journalEntries,
      )..orderBy([(e) => OrderingTerm.asc(e.deviceChainSequence)])).get();
      final identities = await _db.select(_db.signingIdentities).get();
      final publicKeyById = {
        for (final i in identities) i.identityId: i.publicKey,
      };
      final continuesById = {
        for (final i in identities) i.identityId: i.continuesIdentityId,
      };

      final results =
          <String, ({bool isVerified, VerificationBreakReason? reason})>{};
      String? firstBreakEntryId;
      VerificationBreakReason? firstBreakReason;

      final byIdentity = <String, List<JournalEntryRow>>{};
      for (final entry in entries) {
        byIdentity.putIfAbsent(entry.signedByIdentityId, () => []).add(entry);
      }

      final tipByIdentity = <String, ({String? entryId, Uint8List? hash})>{};

      // Process continued-from identities before their successors so a
      // Continuation's first expected previous hash can read the prior tip.
      final identityOrder = byIdentity.keys.toList()
        ..sort((a, b) {
          final aContinues = continuesById[a];
          final bContinues = continuesById[b];
          if (aContinues == b) return 1;
          if (bContinues == a) return -1;
          return a.compareTo(b);
        });

      for (final identityId in identityOrder) {
        final chain = byIdentity[identityId]!;
        chain.sort(
          (a, b) => a.deviceChainSequence.compareTo(b.deviceChainSequence),
        );

        String? breakEntryId;
        var breakReason = VerificationBreakReason.hashMismatch;
        // Continuation: first entry chains onto the continued identity's
        // tip. Linked peers (no continuesIdentityId) start at genesis.
        final continuedFrom = continuesById[identityId];
        Uint8List expectedPreviousHash;
        if (continuedFrom != null) {
          final priorTip = tipByIdentity[continuedFrom];
          expectedPreviousHash =
              priorTip?.hash ?? Uint8List.fromList(genesisPreviousEntryHash);
        } else {
          expectedPreviousHash = Uint8List.fromList(genesisPreviousEntryHash);
        }
        String? lastVerifiedId;
        Uint8List? lastVerifiedHash;

        for (final entry in chain) {
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

          // Migration-created entries start a fresh hash-chain root under
          // the new identity (see migrateToNewIdentityAfterKeyLoss).
          final requiredPreviousHash = entry.migratedFromEntryId != null
              ? Uint8List.fromList(genesisPreviousEntryHash)
              : expectedPreviousHash;
          if (!bytesEqual(entry.previousEntryHash, requiredPreviousHash)) {
            breakEntryId = entry.id;
            breakReason = VerificationBreakReason.chainLinkBroken;
            results[entry.id] = (isVerified: false, reason: breakReason);
            firstBreakEntryId ??= breakEntryId;
            firstBreakReason ??= breakReason;
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
            firstBreakEntryId ??= breakEntryId;
            firstBreakReason ??= breakReason;
            continue;
          }

          final publicKey = publicKeyById[entry.signedByIdentityId];
          if (publicKey == null) {
            // Missing public key fails closed (ledger-chain-verifier spec).
            breakEntryId = entry.id;
            breakReason = VerificationBreakReason.signatureInvalid;
            results[entry.id] = (isVerified: false, reason: breakReason);
            firstBreakEntryId ??= breakEntryId;
            firstBreakReason ??= breakReason;
            continue;
          }
          final signatureValid = await _signingKeyService.verify(
            recomputedHash,
            signature: entry.signature,
            publicKey: publicKey,
          );
          if (!signatureValid) {
            breakEntryId = entry.id;
            breakReason = VerificationBreakReason.signatureInvalid;
            results[entry.id] = (isVerified: false, reason: breakReason);
            firstBreakEntryId ??= breakEntryId;
            firstBreakReason ??= breakReason;
            continue;
          }

          results[entry.id] = (isVerified: true, reason: null);
          expectedPreviousHash = recomputedHash;
          lastVerifiedId = entry.id;
          lastVerifiedHash = recomputedHash;
        }

        tipByIdentity[identityId] = (
          entryId: lastVerifiedId,
          hash: lastVerifiedHash,
        );

        // Skip tip persistence when the signing identity row is gone
        // (missing public key fails closed — no tip to trust).
        if (!publicKeyById.containsKey(identityId)) {
          continue;
        }

        final priorTip = await _chain.loadIdentityTip(identityId);
        final nextSequence =
            priorTip?.nextDeviceChainSequence ??
            (chain.isEmpty
                ? 0
                : chain
                          .map((e) => e.deviceChainSequence)
                          .reduce((a, b) => a > b ? a : b) +
                      1);
        await _chain.updateIdentityTip(
          identityId: identityId,
          trustedTipEntryId: lastVerifiedId,
          trustedTipHash: lastVerifiedHash,
          nextDeviceChainSequence: nextSequence,
        );

        if (breakEntryId != null) {
          final priorHash = priorTip?.trustedTipHash;
          final isNewBreak =
              priorHash == null ||
              lastVerifiedHash == null ||
              !bytesEqual(priorHash, lastVerifiedHash);
          if (isNewBreak) {
            await _db
                .into(_db.integrityEvents)
                .insert(
                  IntegrityEventsCompanion.insert(
                    eventType: IntegrityEventType.chainBreakDetected,
                    relatedEntryId: Value(breakEntryId),
                    detail: Value(
                      'Break detected at entry $breakEntryId '
                      '(${breakReason.name}) on identity $identityId; '
                      'reanchoring onto ${lastVerifiedId ?? "genesis"}.',
                    ),
                  ),
                );
          }
        }
      }

      // Identities with no entries still get a tip row when present.
      for (final identity in identities) {
        if (byIdentity.containsKey(identity.identityId)) continue;
        await _chain.ensureIdentityTip(identity.identityId);
      }

      await _chain.replaceVerificationCache([
        for (final entry in entries)
          (
            entryId: entry.id,
            isVerified: results[entry.id]!.isVerified,
            breakReason: results[entry.id]!.reason,
          ),
      ]);

      // Mirror the local (key-matching) identity tip onto the singleton
      // write tip so posting keeps a coherent fallback.
      final priorChainState = await _chain.loadState();
      final stored = await _signingKeyService.loadStoredKeyMaterial();
      final localIdentity = await _chain.currentSigningIdentity(
        matchingPublicKey: stored?.publicKey,
      );
      if (localIdentity != null) {
        final localTip = tipByIdentity[localIdentity.identityId];
        final existingTip = await _chain.loadIdentityTip(
          localIdentity.identityId,
        );
        await _chain.updateState(
          trustedTipEntryId:
              localTip?.entryId ?? existingTip?.trustedTipEntryId,
          trustedTipHash: localTip?.hash ?? existingTip?.trustedTipHash,
          nextDeviceChainSequence:
              existingTip?.nextDeviceChainSequence ??
              priorChainState.nextDeviceChainSequence,
        );
      } else if (entries.isNotEmpty && firstBreakEntryId == null) {
        final tip = entries.last;
        await _chain.updateState(
          trustedTipEntryId: tip.id,
          trustedTipHash: tip.entryHash,
          nextDeviceChainSequence: priorChainState.nextDeviceChainSequence,
        );
      } else if (firstBreakEntryId != null) {
        // No local identity; keep singleton next-sequence, clear tip if
        // the only chains broke before any verified entry.
        await _chain.updateState(
          trustedTipEntryId: priorChainState.trustedTipEntryId,
          trustedTipHash: priorChainState.trustedTipHash,
          nextDeviceChainSequence: priorChainState.nextDeviceChainSequence,
        );
      }

      return ChainVerificationResult(
        totalEntries: entries.length,
        breakEntryId: firstBreakEntryId,
        breakReason: firstBreakReason,
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
