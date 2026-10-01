import '../linked_devices/local_network_reachability.dart';
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

/// Orchestrates a LAN-only sync session (tasks 5.3). Never uses an internet
/// relay — [LocalNetworkReachability] gates connect.
class PeerSyncSession {
  PeerSyncSession({
    required SyncTransport transport,
    required SyncLedgerView ledger,
    required LocalNetworkReachability reachability,
    required SyncPeerIdentity localIdentity,
    required Set<String> pinnedFingerprints,
    this.allowAndroidBackgroundSync = true,
  }) : _transport = transport,
       _ledger = ledger,
       _reachability = reachability,
       _localIdentity = localIdentity,
       _pinnedFingerprints = pinnedFingerprints;

  final SyncTransport _transport;
  final SyncLedgerView _ledger;
  final LocalNetworkReachability _reachability;
  final SyncPeerIdentity _localIdentity;
  final Set<String> _pinnedFingerprints;

  /// Android may sync briefly while backgrounded where the OS allows
  /// (peer-sync spec). Other platforms ignore this flag.
  final bool allowAndroidBackgroundSync;

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
    );

    try {
      return await _exchange(connection);
    } finally {
      await connection.close();
    }
  }

  /// Serves inbound sync sessions while the app is open (and briefly in the
  /// Android background when [allowAndroidBackgroundSync] is true).
  Future<void> startListening({
    required void Function(SyncSessionResult result)? onCompleted,
  }) {
    return _transport.listen(
      local: _localIdentity,
      pinnedFingerprints: _pinnedFingerprints,
      onSession: (connection) async {
        try {
          final result = await _exchange(connection);
          onCompleted?.call(result);
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
      final remoteNext = remoteTips[identityId] ?? 1;
      if (localNext > remoteNext) {
        missingForRemote.addAll(
          await _ledger.entriesFrom(
            identityId: identityId,
            minSequence: remoteNext,
          ),
        );
      }
    }

    final batch = EntryBatch(entries: missingForRemote);
    await connection.send(batch.toJson());

    final peerBatchMessage = await connection.receive();
    final peerBatch = EntryBatch.fromJson(peerBatchMessage);
    final received = await _ledger.applyEntryBatch(
      peerBatch,
      fromDeviceId: connection.remote.deviceId,
    );

    return SyncSessionResult(
      connected: true,
      entriesSent: missingForRemote.length,
      entriesReceived: received,
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
        result[entry.key] = 1;
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
}
