import 'package:smara_accounting/domain/backup/books_copy_file.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Books Copy encrypt/decrypt includes claim receipts without private keys',
    () async {
      final encoded = await BooksCopyFile.encrypt(
        databaseBytes: [1, 2, 3, 4],
        settings: const {'theme': 'system'},
        passphrase: 'test-passphrase-long',
        receiptsById: {
          'receipt-1': [9, 8, 7, 6, 5],
        },
      );
      expect(encoded.contains('privateKey'), isFalse);
      expect(syncPayloadContainsPrivateKeyMaterial(encoded), isFalse);

      final contents = await BooksCopyFile.decrypt(
        fileContents: encoded,
        passphrase: 'test-passphrase-long',
      );
      expect(contents.databaseBytes, [1, 2, 3, 4]);
      expect(contents.receiptsById['receipt-1'], [9, 8, 7, 6, 5]);
      expect(contents.settings['theme'], 'system');
    },
  );
}
