import '../models/join_qr_payload.dart';
import '../peer_sync/sync_payloads.dart';

/// Result of finishing join-by-code after both sides confirm check codes:
/// the QR-equivalent payload plus optional host metadata bootstrap (categories,
/// accounts, books settings) transferred on the same LAN session.
class JoinCompletion {
  const JoinCompletion({
    required this.payload,
    this.bootstrapMetadata = const [],
  });

  final JoinQrPayload payload;

  /// Host MetadataOps snapshot so the joiner receives catalog without waiting
  /// for a later Sync now (peer-sync "books transfer" at join).
  final List<MetadataOperation> bootstrapMetadata;
}
