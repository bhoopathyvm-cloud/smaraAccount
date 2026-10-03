import 'dart:convert';
import 'dart:io';

import '../../domain/claims/claim_receipt_picker.dart';

/// Company-sync test picker: returns seeded fixture files so Claimants can
/// attach receipts through the real gallery / PDF buttons without a camera.
///
/// Selected by `--dart-define=COMPANY_SYNC_TEST=true` in [main.dart].
///
/// Known fixtures are embedded so iOS simulator Claimants (whose app cwd is
/// not the repo root) still get bytes. Optional host paths remain as a
/// fallback for macOS / local debugging.
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
    final embedded = _embeddedBytes(fileName);
    if (embedded != null) {
      return ClaimReceiptPickResult(
        bytes: embedded,
        contentType: contentType,
        fileName: fileName,
      );
    }

    final absoluteRoot = const String.fromEnvironment(
      'COMPANY_SYNC_FIXTURES',
      defaultValue: '',
    );
    final candidates = <String>[
      if (absoluteRoot.isNotEmpty) '$absoluteRoot/$fileName',
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

  /// Bytes for the seeded fixtures under [test_fixtures/receipts].
  static List<int>? _embeddedBytes(String fileName) {
    switch (fileName) {
      case 'hotel_receipt.jpg':
      case 'meal_receipt.jpg':
      // Tom's "unreadable" label is the file name; content only needs to attach.
      case 'unreadable_receipt.jpg':
        return _tinyJpeg;
      case 'train_receipt.pdf':
        return _tinyPdf;
      default:
        return null;
    }
  }

  /// Exact bytes of [test_fixtures/receipts/hotel_receipt.jpg] (1×1 JPEG).
  static final List<int> _tinyJpeg = base64Decode(
    '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8U'
    'HRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/wAALCAABAAEBAREA'
    '/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/9oACAEBAAA/AH//2Q==',
  );

  static final List<int> _tinyPdf = utf8.encode(
    '%PDF-1.1\n1 0 obj<<>>endobj\ntrailer<<>>\n%%EOF\n',
  );
}
