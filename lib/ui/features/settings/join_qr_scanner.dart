import '../../../domain/models/join_qr_payload.dart';

/// Seam for scanning a join QR (task 12.3). Production uses the camera;
/// tests inject [FakeJoinQrScanner].
abstract class JoinQrScanner {
  /// Scans once and returns the decoded payload, or null if cancelled.
  Future<JoinQrPayload?> scanOnce();
}

class FakeJoinQrScanner implements JoinQrScanner {
  FakeJoinQrScanner({this.payload});

  JoinQrPayload? payload;
  int scanCount = 0;

  @override
  Future<JoinQrPayload?> scanOnce() async {
    scanCount += 1;
    return payload;
  }
}
