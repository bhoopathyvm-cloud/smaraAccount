import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/books_set/books_set_paths.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late Directory tempDir;
  late BooksSetStore store;
  late InMemorySecureKeyStorage secureStorage;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('smara-books-paths-');
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    store = BooksSetStore();
    secureStorage = InMemorySecureKeyStorage();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('path selection', () {
    test('databaseFile lives under books/<id>/ledger.sqlite', () {
      final file = BooksSetPaths.databaseFile(tempDir, 'set-a');
      expect(
        file.path,
        p.join(tempDir.path, 'books', 'set-a', 'ledger.sqlite'),
      );
    });

    test('ensureBooksSetDirectory creates only the requested set', () async {
      await BooksSetPaths.ensureBooksSetDirectory(tempDir, 'set-a');
      expect(
        BooksSetPaths.booksSetDirectory(tempDir, 'set-a').existsSync(),
        isTrue,
      );
      expect(
        BooksSetPaths.booksSetDirectory(tempDir, 'set-b').existsSync(),
        isFalse,
      );
    });

    test('deleteBooksSetDirectory leaves unrelated sets intact', () async {
      await BooksSetPaths.ensureBooksSetDirectory(tempDir, 'set-a');
      await BooksSetPaths.ensureBooksSetDirectory(tempDir, 'set-b');
      await BooksSetPaths.databaseFile(tempDir, 'set-a').writeAsString('a');
      await BooksSetPaths.databaseFile(tempDir, 'set-b').writeAsString('b');

      await BooksSetPaths.deleteBooksSetDirectory(tempDir, 'set-a');

      expect(
        BooksSetPaths.booksSetDirectory(tempDir, 'set-a').existsSync(),
        isFalse,
      );
      expect(
        await BooksSetPaths.databaseFile(tempDir, 'set-b').readAsString(),
        'b',
      );
    });
  });

  group('activeBooksSetId', () {
    test('create/open/switch/remove path selection via store', () async {
      expect(await store.activeBooksSetId(), isNull);

      await BooksSetPaths.ensureBooksSetDirectory(tempDir, 'set-a');
      await store.setActiveBooksSetId('set-a');
      expect(await store.activeBooksSetId(), 'set-a');
      final activeA = await store.activeBooksSetId();
      expect(
        BooksSetPaths.databaseFile(tempDir, activeA!).path,
        BooksSetPaths.databaseFile(tempDir, 'set-a').path,
      );

      await BooksSetPaths.ensureBooksSetDirectory(tempDir, 'set-b');
      await store.setActiveBooksSetId('set-b');
      expect(await store.activeBooksSetId(), 'set-b');
      final activeB = await store.activeBooksSetId();
      expect(
        BooksSetPaths.databaseFile(tempDir, activeB!).path,
        BooksSetPaths.databaseFile(tempDir, 'set-b').path,
      );

      await BooksSetPaths.deleteBooksSetDirectory(tempDir, 'set-a');
      expect(await store.activeBooksSetId(), 'set-b');
      expect(
        BooksSetPaths.booksSetDirectory(tempDir, 'set-a').existsSync(),
        isFalse,
      );
      expect(
        BooksSetPaths.booksSetDirectory(tempDir, 'set-b').existsSync(),
        isTrue,
      );
    });
  });

  group('legacy migration', () {
    test('moves legacy sqlite and namespaces the signing key once', () async {
      final legacy = BooksSetPaths.legacyDatabaseFile(tempDir);
      await legacy.writeAsString('legacy-bytes');
      await secureStorage.write(
        SigningKeyService.privateKeySeedStorageKey,
        'seed-b64',
      );

      final id = await BooksSetPaths.migrateLegacyLayoutIfNeeded(
        supportDirectory: tempDir,
        store: store,
        secureStorage: secureStorage,
        newId: () => 'migrated-set',
      );

      expect(id, 'migrated-set');
      expect(await store.activeBooksSetId(), 'migrated-set');
      expect(legacy.existsSync(), isFalse);
      expect(
        await BooksSetPaths.databaseFile(
          tempDir,
          'migrated-set',
        ).readAsString(),
        'legacy-bytes',
      );
      expect(
        await secureStorage.read(SigningKeyService.privateKeySeedStorageKey),
        isNull,
      );
      expect(
        await secureStorage.read(
          SigningKeyService.storageKeyFor('migrated-set'),
        ),
        'seed-b64',
      );

      // Idempotent on second call.
      final again = await BooksSetPaths.migrateLegacyLayoutIfNeeded(
        supportDirectory: tempDir,
        store: store,
        secureStorage: secureStorage,
        newId: () => 'other',
      );
      expect(again, 'migrated-set');
      expect(
        BooksSetPaths.booksSetDirectory(tempDir, 'other').existsSync(),
        isFalse,
      );
    });

    test('returns null when no legacy file and no active id', () async {
      final id = await BooksSetPaths.migrateLegacyLayoutIfNeeded(
        supportDirectory: tempDir,
        store: store,
        secureStorage: secureStorage,
      );
      expect(id, isNull);
      expect(await store.activeBooksSetId(), isNull);
    });
  });

  group('namespaced secure-storage keys', () {
    test('SigningKeyService isolates keys per books set', () async {
      final keysA = SigningKeyService(
        secureStorage: secureStorage,
        booksSetId: 'set-a',
      );
      final keysB = SigningKeyService(
        secureStorage: secureStorage,
        booksSetId: 'set-b',
      );

      final a = await keysA.generateNewIdentity();
      final b = await keysB.generateNewIdentity();

      expect(
        (await keysA.loadStoredKeyMaterial())!.publicKey,
        a.keyMaterial.publicKey,
      );
      expect(
        (await keysB.loadStoredKeyMaterial())!.publicKey,
        b.keyMaterial.publicKey,
      );
      expect(a.keyMaterial.publicKey, isNot(equals(b.keyMaterial.publicKey)));

      await keysA.deleteStoredKey();
      expect(await keysA.loadStoredKeyMaterial(), isNull);
      expect(await keysB.loadStoredKeyMaterial(), isNotNull);
    });
  });
}
