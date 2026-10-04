import '../linked_devices/device_certificate_store.dart';
import '../linked_devices/local_network_reachability.dart';
import 'claim_sync_payloads.dart';
import 'sync_payloads.dart';
import 'sync_transport.dart';

/// Local ledger surface used by [PeerSyncSession] to decide what is missing
/// and to apply received batches. Real DB merge lives in [SyncMergeEngine].
abstract class SyncLedgerView {
  /// Next `deviceChainSequence` per signing identity (tip + 1), or the highest
  /// known sequence + 1 when present.
  Future<Map<String, int>> nextSequenceByIdentity();

  /// Entries signed by [identityId] with `deviceChainSequence >= minSequence`.
  Future<List<SyncJournalEntry>> entriesFrom({
    required String identityId,
    required int minSequence,
  });

  /// Applies a verified peer batch (insert-only). Returns how many rows were
  /// newly inserted (duplicates skipped).
  Future<int> applyEntryBatch(EntryBatch batch, {required String fromDeviceId});

  /// Pending metadata ops to send to peers (categories, accounts, settings…).
  Future<List<MetadataOperation>> pendingMetadataOperations() async => const [];

  /// Applies peer metadata ops (LWW). Returns how many ops were considered.
  Future<int> applyPeerMetadataOps(MetadataOps ops) async => 0;

  /// Claims (with items/decisions) to send to a peer.
  Future<ClaimBatch> pendingClaimBatch() async => const ClaimBatch(claims: []);

  /// Upserts peer claims by LWW on [SyncClaim.updatedAt].
  Future<int> applyPeerClaimBatch(ClaimBatch batch) async => 0;
}

/// Outcome of one Sync now / automatic catch-up attempt.
class SyncSessionResult {
  const SyncSessionResult({
    required this.connected,
    required this.entriesSent,
    required this.entriesReceived,
    this.refusedReason,
  });

  final bool connected;
  final int entriesSent;
  final int entriesReceived;
  final String? refusedReason;

  static const remoteNetwork = SyncSessionResult(
    connected: false,
    entriesSent: 0,
    entriesReceived: 0,
    refusedReason:
        'Devices must be on the same Wi-Fi. Sync never uses the '
        'internet or a relay.',
  );
}

/// Optional Claimant-scoped outbound filter + erase-ack hooks supplied by
/// [PeerSyncService] from membership.
class PeerSyncSessionHooks {
  const PeerSyncSessionHooks({
    this.filterOutboundEntries,
    this.filterOutboundClaims,
    this.filterOutboundMetadata,
    this.afterPeerMetadataApplied,
  });

  final Future<EntryBatch> Function(EntryBatch batch, String remoteDeviceId)?
  filterOutboundEntries;
  final Future<ClaimBatch> Function(ClaimBatch batch, String remoteDeviceId)?
  filterOutboundClaims;
  final Future<List<MetadataOperation>> Function(
    List<MetadataOperation> ops,
    String remoteDeviceId,
  )?
  filterOutboundMetadata;

  /// Called after peer metadata is applied (erase-on-contact). May return
  /// extra metadata ops (e.g. erasedAt ack) to exchange in a follow-up round.
  final Future<List<MetadataOperation>> Function()? afterPeerMetadataApplied;
}

/// Orchestrates a LAN-only sync session (tasks 5.3). Never uses an internet
/// relay — [LocalNetworkReachability] gates connect.
class PeerSyncSession {
  PeerSyncSession({
    required SyncTransport transport,
    required SyncLedgerView ledger,
    required LocalNetworkReachability reachability,
    required SyncPeerIdentity localIdentity,
    required Set<String> pinnedFingerprints,
    List<DeviceCertificate> pinnedCertificates = const [],
    PeerSyncSessionHooks hooks = const PeerSyncSessionHooks(),
  }) : _transport = transport,
       _ledger = ledger,
       _reachability = reachability,
       _localIdentity = localIdentity,
       _pinnedFingerprints = pinnedFingerprints,
       _pinnedCertificates = pinnedCertificates,
       _hooks = hooks;

  final SyncTransport _transport;
  final SyncLedgerView _ledger;
  final LocalNetworkReachability _reachability;
  final SyncPeerIdentity _localIdentity;
  final Set<String> _pinnedFingerprints;
  final List<DeviceCertificate> _pinnedCertificates;
  final PeerSyncSessionHooks _hooks;

  /// Optional diagnostic sink (company-sync harness).
  static void Function(String message)? debugLog;

  /// Runs Sync now against [remote]. Refuses when peers are not on the local
  /// network.
  Future<SyncSessionResult> syncNow({
    required SyncPeerIdentity remote,
    String peerHint = '',
  }) async {
    final onLan = await _reachability.arePeersOnLocalNetwork(
      peerHint: peerHint.isEmpty ? remote.deviceId : peerHint,
    );
    if (!onLan) {
      return SyncSessionResult.remoteNetwork;
    }

    final connection = await _transport.connect(
      local: _localIdentity,
      remote: remote,
      pinnedFingerprints: _pinnedFingerprints,
      pinnedCertificates: _pinnedCertificates,
    );

    try {
      return await _exchange(connection);
    } catch (e, st) {
      debugLog?.call('outbound exchange failed: $e\n$st');
      rethrow;
    } finally {
      await connection.close();
    }
  }

  /// Serves inbound sync sessions while the app is open.
  Future<void> startListening({
    required void Function(SyncSessionResult result)? onCompleted,
    int? bindPort,
    void Function(int port)? onBound,
  }) {
    return _transport.listen(
      local: _localIdentity,
      pinnedFingerprints: _pinnedFingerprints,
      pinnedCertificates: _pinnedCertificates,
      bindPort: bindPort,
      onBound: onBound,
      onSession: (connection) async {
        try {
          final result = await _exchange(connection);
          onCompleted?.call(result);
        } catch (e, st) {
          // Never let inbound exchange failures escape the accept loop —
          // they abort Flutter integration tests and strand the peer.
          debugLog?.call('inbound exchange failed: $e\n$st');
        } finally {
          await connection.close();
        }
      },
    );
  }

  Future<void> stopListening() => _transport.stopListening();

  Future<SyncSessionResult> _exchange(SyncConnection connection) async {
    final localTips = await _ledger.nextSequenceByIdentity();
    await connection.send({
      'kind': 'tipState',
      'nextSequenceByIdentity': localTips,
    });

    final remoteTipMessage = await connection.receive();
    if (remoteTipMessage['kind'] != 'tipState') {
      throw StateError('Expected tipState from peer.');
    }
    final remoteTipsRaw = remoteTipMessage['nextSequenceByIdentity'];
    if (remoteTipsRaw is! Map) {
      throw StateError('Invalid tipState payload.');
    }
    final remoteTips = <String, int>{
      for (final e in remoteTipsRaw.entries)
        e.key.toString(): (e.value as num).toInt(),
    };

    final missingForRemote = <SyncJournalEntry>[];
    for (final entry in localTips.entries) {
      final identityId = entry.key;
      final localNext = entry.value;
      // Sequences start at 0; unknown remote identity → send from the start.
      final remoteNext = remoteTips[identityId] ?? 0;
      if (localNext > remoteNext) {
        missingForRemote.addAll(
          await _ledger.entriesFrom(
            identityId: identityId,
            minSequence: remoteNext,
          ),
        );
      }
    }

    var batch = EntryBatch(entries: missingForRemote);
    final filterEntries = _hooks.filterOutboundEntries;
    if (filterEntries != null) {
      batch = await filterEntries(batch, connection.remote.deviceId);
    }
    debugLog?.call(
      'exchange tips local=${localTips.length} remote=${remoteTips.length} '
      'sendingEntries=${batch.entries.length} '
      'anchors=${batch.scopeAnchors.length} '
      'to=${connection.remote.deviceId}',
    );
    await connection.send(batch.toJson());

    final peerBatchMessage = await connection.receive();
    final peerBatch = EntryBatch.fromJson(peerBatchMessage);
    debugLog?.call(
      'exchange receivedEntries=${peerBatch.entries.length} '
      'anchors=${peerBatch.scopeAnchors.length} '
      'from=${connection.remote.deviceId}',
    );
    final received = await _ledger.applyEntryBatch(
      peerBatch,
      fromDeviceId: connection.remote.deviceId,
    );

    // Metadata ops (categories, accounts, books settings) — required by
    // peer-sync spec; without this a Claimant never receives allowlisted
    // expense categories after join.
    var localMeta = await _ledger.pendingMetadataOperations();
    final filterMeta = _hooks.filterOutboundMetadata;
    if (filterMeta != null) {
      localMeta = await filterMeta(localMeta, connection.remote.deviceId);
    }
    await connection.send(MetadataOps(operations: localMeta).toJson());
    final peerMetaMessage = await connection.receive();
    final peerMeta = MetadataOps.fromJson(peerMetaMessage);
    await _ledger.applyPeerMetadataOps(peerMeta);

    // Erase-on-contact may produce an erasedAt ack; exchange a follow-up
    // metadata round so the Owner learns before the removed device wipes.
    final afterMeta = _hooks.afterPeerMetadataApplied;
    var eraseAck = afterMeta == null
        ? const <MetadataOperation>[]
        : await afterMeta();
    await connection.send(MetadataOps(operations: eraseAck).toJson());
    final peerEraseMessage = await connection.receive();
    final peerErase = MetadataOps.fromJson(peerEraseMessage);
    if (peerErase.operations.isNotEmpty) {
      await _ledger.applyPeerMetadataOps(peerErase);
    }

    // Claims live off-ledger until approval; exchange ClaimBatch so an
    // Approver sees submitted claims after Sync now (expense-claims peer-sync).
    var localClaims = await _ledger.pendingClaimBatch();
    final filterClaims = _hooks.filterOutboundClaims;
    if (filterClaims != null) {
      localClaims = await filterClaims(localClaims, connection.remote.deviceId);
    }
    await connection.send(localClaims.toJson());
    final peerClaimsMessage = await connection.receive();
    final peerClaims = ClaimBatch.fromJson(peerClaimsMessage);
    final claimsReceived = await _ledger.applyPeerClaimBatch(peerClaims);

    return SyncSessionResult(
      connected: true,
      entriesSent: batch.entries.length + localClaims.claims.length,
      entriesReceived: received + claimsReceived,
    );
  }
}

/// In-memory ledger for transport/session tests (no Drift).
class FakeSyncLedgerView implements SyncLedgerView {
  final Map<String, List<SyncJournalEntry>> entriesByIdentity = {};

  void seed(SyncJournalEntry entry) {
    entriesByIdentity
        .putIfAbsent(entry.signedByIdentityId, () => [])
        .add(entry);
    entriesByIdentity[entry.signedByIdentityId]!.sort(
      (a, b) => a.deviceChainSequence.compareTo(b.deviceChainSequence),
    );
  }

  @override
  Future<Map<String, int>> nextSequenceByIdentity() async {
    final result = <String, int>{};
    for (final entry in entriesByIdentity.entries) {
      if (entry.value.isEmpty) {
        result[entry.key] = 0;
      } else {
        result[entry.key] = entry.value.last.deviceChainSequence + 1;
      }
    }
    return result;
  }

  @override
  Future<List<SyncJournalEntry>> entriesFrom({
    required String identityId,
    required int minSequence,
  }) async {
    final list = entriesByIdentity[identityId] ?? const [];
    return list.where((e) => e.deviceChainSequence >= minSequence).toList();
  }

  @override
  Future<int> applyEntryBatch(
    EntryBatch batch, {
    required String fromDeviceId,
  }) async {
    var inserted = 0;
    for (final entry in batch.entries) {
      final list = entriesByIdentity.putIfAbsent(
        entry.signedByIdentityId,
        () => [],
      );
      final duplicate = list.any(
        (e) =>
            e.signedByIdentityId == entry.signedByIdentityId &&
            e.deviceChainSequence == entry.deviceChainSequence,
      );
      if (duplicate) continue;
      list.add(entry);
      list.sort(
        (a, b) => a.deviceChainSequence.compareTo(b.deviceChainSequence),
      );
      inserted++;
    }
    return inserted;
  }

  final List<MetadataOperation> metadataOps = [];

  @override
  Future<List<MetadataOperation>> pendingMetadataOperations() async =>
      List.of(metadataOps);

  @override
  Future<int> applyPeerMetadataOps(MetadataOps ops) async {
    metadataOps.addAll(ops.operations);
    return ops.operations.length;
  }

  final List<SyncClaim> claims = [];

  @override
  Future<ClaimBatch> pendingClaimBatch() async => ClaimBatch(claims: claims);

  @override
  Future<int> applyPeerClaimBatch(ClaimBatch batch) async {
    var applied = 0;
    for (final claim in batch.claims) {
      final idx = claims.indexWhere((c) => c.id == claim.id);
      if (idx < 0) {
        claims.add(claim);
        applied++;
        continue;
      }
      if (claims[idx].updatedAt.isBefore(claim.updatedAt)) {
        claims[idx] = claim;
        applied++;
      }
    }
    return applied;
  }
}
