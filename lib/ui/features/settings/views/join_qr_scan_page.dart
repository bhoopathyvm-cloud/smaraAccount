import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../domain/models/join_qr_payload.dart';
import '../join_qr_scanner.dart';

/// Camera-backed [JoinQrScanner] using `mobile_scanner`.
class PlatformJoinQrScanner implements JoinQrScanner {
  @override
  Future<JoinQrPayload?> scanOnce() async {
    // Caller should present [JoinQrScanPage]; this class is used when the
    // page is not needed (rare). Prefer [JoinQrScanPage] for UI.
    throw UnsupportedError(
      'Use JoinQrScanPage to present the camera scanner UI.',
    );
  }
}

/// Full-screen QR scanner that returns a decoded [JoinQrPayload] or null.
class JoinQrScanPage extends StatefulWidget {
  const JoinQrScanPage({super.key});

  @override
  State<JoinQrScanPage> createState() => _JoinQrScanPageState();
}

class _JoinQrScanPageState extends State<JoinQrScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.isEmpty) continue;
      try {
        final payload = JoinQrPayload.decode(raw);
        _handled = true;
        Navigator.of(context).pop(payload);
        return;
      } on FormatException {
        // Keep scanning until a valid Smara join QR appears.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan join QR')),
      body: MobileScanner(controller: _controller, onDetect: _onDetect),
    );
  }
}
