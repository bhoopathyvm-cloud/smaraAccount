/// Metadata for a receipt attachment stored under the books set's
/// `receipts/` directory (design Decision 8).
class ClaimReceipt {
  const ClaimReceipt({
    required this.id,
    required this.claimItemId,
    required this.contentType,
    required this.fileName,
    required this.byteSize,
    required this.contentHash,
    required this.createdAt,
  });

  final String id;
  final String claimItemId;

  /// MIME type, e.g. `image/jpeg` or `application/pdf`.
  final String contentType;
  final String fileName;
  final int byteSize;

  /// Content hash (hex) for sync dedupe.
  final String contentHash;
  final DateTime createdAt;

  bool get isPdf => contentType == 'application/pdf';
  bool get isImage => contentType.startsWith('image/');
}
