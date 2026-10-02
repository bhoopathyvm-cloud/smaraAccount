import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/claims/claim_receipt_picker.dart';

/// Production [ClaimReceiptPicker] using `image_picker` (camera / gallery)
/// and `file_picker` (PDF).
class PlatformClaimReceiptPicker implements ClaimReceiptPicker {
  PlatformClaimReceiptPicker({ImagePicker? imagePicker})
    : _images = imagePicker ?? ImagePicker();

  final ImagePicker _images;

  @override
  Future<ClaimReceiptPickResult?> pick(ClaimReceiptSource source) async {
    switch (source) {
      case ClaimReceiptSource.camera:
        return _pickImage(ImageSource.camera, fallbackName: 'receipt.jpg');
      case ClaimReceiptSource.gallery:
        return _pickImage(ImageSource.gallery, fallbackName: 'receipt.jpg');
      case ClaimReceiptSource.pdf:
        return _pickPdf();
    }
  }

  Future<ClaimReceiptPickResult?> _pickImage(
    ImageSource source, {
    required String fallbackName,
  }) async {
    final file = await _images.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final name = file.name.isNotEmpty ? file.name : fallbackName;
    return ClaimReceiptPickResult(
      bytes: bytes,
      contentType: 'image/jpeg',
      fileName: name,
    );
  }

  Future<ClaimReceiptPickResult?> _pickPdf() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return ClaimReceiptPickResult(
      bytes: bytes,
      contentType: 'application/pdf',
      fileName: file.name.isNotEmpty ? file.name : 'receipt.pdf',
    );
  }
}
