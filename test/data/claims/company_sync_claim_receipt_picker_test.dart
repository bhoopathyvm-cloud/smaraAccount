import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/data/claims/company_sync_claim_receipt_picker.dart';
import 'package:smara_accounting/domain/claims/claim_receipt_picker.dart';

void main() {
  test(
    'gallery pick returns embedded hotel_receipt without host files',
    () async {
      final picker = CompanySyncClaimReceiptPicker(
        fixturesRoot: '/nonexistent/path/receipts',
      );
      final picked = await picker.pick(ClaimReceiptSource.gallery);
      expect(picked, isNotNull);
      expect(picked!.fileName, 'hotel_receipt.jpg');
      expect(picked.bytes.length, greaterThan(100));
      expect(picked.contentType, 'image/jpeg');
    },
  );

  test('setNextGalleryFile overrides the next gallery pick name', () async {
    final picker = CompanySyncClaimReceiptPicker(
      fixturesRoot: '/nonexistent/path/receipts',
    );
    picker.setNextGalleryFile('unreadable_receipt.jpg');
    final picked = await picker.pick(ClaimReceiptSource.gallery);
    expect(picked!.fileName, 'unreadable_receipt.jpg');
    expect(picked.bytes, isNotEmpty);
  });
}
