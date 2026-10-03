import 'dart:io';

import '../../domain/claims/claim_receipt_picker.dart';

/// Company-sync test picker: returns seeded fixture files so Claimants can
/// attach receipts through the real gallery / PDF buttons without a camera.
///
/// Selected by `--dart-define=COMPANY_SYNC_TEST=true` in [main.dart].
class CompanySyncClaimReceiptPicker implements ClaimReceiptPicker {
  CompanySyncClaimReceiptPicker({
    this.fixturesRoot = 'test_fixtures/receipts',
    String? nextGalleryFile,
  }) : _nextGalleryFile = nextGalleryFile;

  final String fixturesRoot;

  /// Override the next gallery pick (e.g. unreadable_receipt.jpg for Tom).
  String? _nextGalleryFile;

  void setNextGalleryFile(String? fileName) {
    _nextGalleryFile = fileName;
  }

  @override
  Future<ClaimReceiptPickResult?> pick(ClaimReceiptSource source) async {
    switch (source) {
      case ClaimReceiptSource.gallery:
      case ClaimReceiptSource.camera:
        final name = _nextGalleryFile ?? 'hotel_receipt.jpg';
        _nextGalleryFile = null;
        return _read(name, 'image/jpeg');
      case ClaimReceiptSource.pdf:
        return _read('train_receipt.pdf', 'application/pdf');
    }
  }

  ClaimReceiptPickResult? _read(String fileName, String contentType) {
    final candidates = [
      '$fixturesRoot/$fileName',
      '../$fixturesRoot/$fileName',
    ];
    for (final path in candidates) {
      final file = File(path);
      if (file.existsSync()) {
        return ClaimReceiptPickResult(
          bytes: file.readAsBytesSync(),
          contentType: contentType,
          fileName: fileName,
        );
      }
    }
    return null;
  }
}
