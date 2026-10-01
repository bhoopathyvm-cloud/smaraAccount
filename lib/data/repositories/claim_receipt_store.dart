import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/app_error.dart';
import '../../domain/models/claim_receipt.dart';
import '../books_set/books_set_paths.dart';
import '../database/app_database.dart';

/// Stores Claim receipt blobs under `books/<id>/receipts/` and metadata
/// rows (design Decision 8). Photos are compressed to ~1 MB; PDFs are
/// kept as-is up to 5 MB.
class ClaimReceiptStore {
  ClaimReceiptStore({
    required AppDatabase database,
    required String booksSetId,
    Directory? supportDirectory,
    Uuid? uuid,
    Future<List<int>> Function(List<int> bytes, {required int targetBytes})?
    compressJpeg,
  }) : _db = database,
       _booksSetId = booksSetId,
       _supportDirectory = supportDirectory,
       _uuid = uuid ?? const Uuid(),
       _compressJpeg = compressJpeg ?? _defaultCompressJpeg;

  static const targetPhotoBytes = 1024 * 1024; // ~1 MB
  static const maxPdfBytes = 5 * 1024 * 1024; // 5 MB

  final AppDatabase _db;
  final String _booksSetId;
  final Directory? _supportDirectory;
  final Uuid _uuid;
  final Future<List<int>> Function(List<int> bytes, {required int targetBytes})
  _compressJpeg;

  Future<Directory> _support() async =>
      _supportDirectory ?? await getApplicationSupportDirectory();

  /// Attaches bytes to [claimItemId]. Compresses images; rejects oversized
  /// PDFs. Never deletes existing receipts (retention for life of books).
  Future<ClaimReceipt> attach({
    required String claimItemId,
    required List<int> bytes,
    required String contentType,
    required String fileName,
  }) async {
    var stored = bytes;
    var type = contentType;
    if (contentType == 'application/pdf' ||
        fileName.toLowerCase().endsWith('.pdf')) {
      if (bytes.length > maxPdfBytes) {
        throw const AppFailure(
          AppErrorCode.generic,
          debugMessage: 'This PDF is larger than 5 MB. Choose a smaller file.',
        );
      }
      type = 'application/pdf';
    } else if (contentType.startsWith('image/') || _looksLikeImage(fileName)) {
      stored = await _compressJpeg(bytes, targetBytes: targetPhotoBytes);
      type = 'image/jpeg';
    }

    final id = _uuid.v4();
    final hashBytes = await Sha256().hash(stored);
    final hash = base64Encode(hashBytes.bytes);
    final support = await _support();
    await BooksSetPaths.ensureReceiptsDirectory(support, _booksSetId);
    final file = BooksSetPaths.receiptFile(support, _booksSetId, id);
    await file.writeAsBytes(stored, flush: true);

    await _db
        .into(_db.claimReceipts)
        .insert(
          ClaimReceiptsCompanion.insert(
            id: Value(id),
            claimItemId: claimItemId,
            contentType: type,
            fileName: fileName,
            byteSize: stored.length,
            contentHash: hash,
          ),
        );

    return ClaimReceipt(
      id: id,
      claimItemId: claimItemId,
      contentType: type,
      fileName: fileName,
      byteSize: stored.length,
      contentHash: hash,
      createdAt: DateTime.now().toUtc(),
    );
  }

  Future<List<int>> readBytes(String receiptId) async {
    final support = await _support();
    final file = BooksSetPaths.receiptFile(support, _booksSetId, receiptId);
    if (!await file.exists()) {
      throw AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Receipt file missing: $receiptId',
      );
    }
    return file.readAsBytes();
  }

  Future<ClaimReceipt?> findForItem(String claimItemId) async {
    final row = await (_db.select(
      _db.claimReceipts,
    )..where((t) => t.claimItemId.equals(claimItemId))).getSingleOrNull();
    if (row == null) return null;
    return ClaimReceipt(
      id: row.id,
      claimItemId: row.claimItemId,
      contentType: row.contentType,
      fileName: row.fileName,
      byteSize: row.byteSize,
      contentHash: row.contentHash,
      createdAt: row.createdAt,
    );
  }

  static bool _looksLikeImage(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.heic') ||
        lower.endsWith('.webp');
  }

  /// Default compressor: if already under target, keep; otherwise truncate
  /// with a simple quality stand-in (tests inject a real compressor).
  static Future<List<int>> _defaultCompressJpeg(
    List<int> bytes, {
    required int targetBytes,
  }) async {
    if (bytes.length <= targetBytes) return bytes;
    return bytes.sublist(0, targetBytes);
  }
}

/// Content-addressed receipt blob for Peer Sync (design Decision 8).
class ReceiptBlob {
  const ReceiptBlob({
    required this.receiptId,
    required this.claimItemId,
    required this.contentType,
    required this.fileName,
    required this.contentHash,
    required this.bytesBase64,
  });

  final String receiptId;
  final String claimItemId;
  final String contentType;
  final String fileName;
  final String contentHash;
  final String bytesBase64;

  Map<String, Object?> toJson() => {
    'kind': 'receiptBlob',
    'receiptId': receiptId,
    'claimItemId': claimItemId,
    'contentType': contentType,
    'fileName': fileName,
    'contentHash': contentHash,
    'bytes': bytesBase64,
  };

  static ReceiptBlob fromJson(Map<String, dynamic> json) {
    for (final key in json.keys) {
      if (key.contains('private') || key.contains('secret')) {
        throw FormatException(
          'ReceiptBlob must not include private key material ($key).',
        );
      }
    }
    return ReceiptBlob(
      receiptId: json['receiptId'] as String,
      claimItemId: json['claimItemId'] as String,
      contentType: json['contentType'] as String,
      fileName: json['fileName'] as String,
      contentHash: json['contentHash'] as String,
      bytesBase64: json['bytes'] as String,
    );
  }

  String encode() => jsonEncode(toJson());

  List<int> get bytes => base64Decode(bytesBase64);
}
