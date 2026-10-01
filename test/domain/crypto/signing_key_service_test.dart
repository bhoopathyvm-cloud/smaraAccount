import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smara_accounting/domain/crypto/secure_key_storage.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:test/test.dart';

import 'in_memory_secure_key_storage.dart';

void main() {
  group('FlutterSecureKeyStorage options', () {
    test('iOS options are this-device-only and non-synchronizable', () {
      expect(
        FlutterSecureKeyStorage.defaultIosOptions.accessibility,
        KeychainAccessibility.unlocked_this_device,
      );
      expect(FlutterSecureKeyStorage.defaultIosOptions.synchronizable, isFalse);
    });

    test('macOS options keep ADR 0001 path and this-device-only access', () {
      expect(
        FlutterSecureKeyStorage.defaultMacOsOptions.accessibility,
        KeychainAccessibility.unlocked_this_device,
      );
      expect(
        FlutterSecureKeyStorage.defaultMacOsOptions.synchronizable,
        isFalse,
      );
      expect(
        FlutterSecureKeyStorage.defaultMacOsOptions.usesDataProtectionKeychain,
        isFalse,
      );
    });
  });

  late InMemorySecureKeyStorage storage;
  late SigningKeyService service;

  setUp(() {
    storage = InMemorySecureKeyStorage();
    service = SigningKeyService(secureStorage: storage);
  });

  group('loadStoredKeyMaterial', () {
    test('returns null when no identity has been generated yet', () async {
      expect(await service.loadStoredKeyMaterial(), isNull);
    });

    test('returns the stored key material after generateNewIdentity', () async {
      final generated = await service.generateNewIdentity();
      final loaded = await service.loadStoredKeyMaterial();
      expect(loaded!.publicKey, equals(generated.keyMaterial.publicKey));
    });
  });

  group('generateNewIdentity', () {
    test('stores a usable key pair with no recovery phrase', () async {
      final generated = await service.generateNewIdentity();
      expect(generated.keyMaterial.privateKeySeed, hasLength(32));
      expect(generated.keyMaterial.publicKey, isNotEmpty);

      final message = [1, 2, 3, 4];
      final signature = await service.sign(message);
      expect(
        await service.verify(
          message,
          signature: signature,
          publicKey: generated.keyMaterial.publicKey,
        ),
        isTrue,
      );
    });

    test('two calls produce different identities', () async {
      final a = await service.generateNewIdentity();
      final b = await service.generateNewIdentity();
      expect(a.keyMaterial.publicKey, isNot(equals(b.keyMaterial.publicKey)));
    });
  });

  group('migrateKeyAccessibilityIfNeeded', () {
    test('rewrites the key and marks migrated on success', () async {
      await service.generateNewIdentity();
      var marked = false;
      final migrated = await service.migrateKeyAccessibilityIfNeeded(
        alreadyMigrated: false,
        markMigrated: () async => marked = true,
      );
      expect(migrated, isTrue);
      expect(marked, isTrue);
      expect(storage.writeCount, greaterThanOrEqualTo(2));
      expect(await service.loadStoredKeyMaterial(), isNotNull);
    });

    test('keeps the key and does not mark when write fails', () async {
      final generated = await service.generateNewIdentity();
      storage.failNextWriteWith = StateError('write failed');
      var marked = false;
      final migrated = await service.migrateKeyAccessibilityIfNeeded(
        alreadyMigrated: false,
        markMigrated: () async => marked = true,
      );
      expect(migrated, isFalse);
      expect(marked, isFalse);
      expect(
        (await service.loadStoredKeyMaterial())!.publicKey,
        equals(generated.keyMaterial.publicKey),
      );
    });

    test('keeps the key and does not mark on read-back mismatch', () async {
      final generated = await service.generateNewIdentity();
      storage.corruptReadBackAfterWrite = true;
      var marked = false;
      final migrated = await service.migrateKeyAccessibilityIfNeeded(
        alreadyMigrated: false,
        markMigrated: () async => marked = true,
      );
      expect(migrated, isFalse);
      expect(marked, isFalse);
      storage.corruptReadBackAfterWrite = false;
      expect(
        (await service.loadStoredKeyMaterial())!.publicKey,
        equals(generated.keyMaterial.publicKey),
      );
    });

    test('no-ops when already migrated', () async {
      await service.generateNewIdentity();
      final writesBefore = storage.writeCount;
      var marked = false;
      final migrated = await service.migrateKeyAccessibilityIfNeeded(
        alreadyMigrated: true,
        markMigrated: () async => marked = true,
      );
      expect(migrated, isFalse);
      expect(marked, isFalse);
      expect(storage.writeCount, equals(writesBefore));
    });
  });

  group('deleteStoredKey', () {
    test('removes the private key from secure storage', () async {
      await service.generateNewIdentity();
      await service.deleteStoredKey();
      expect(await service.loadStoredKeyMaterial(), isNull);
    });

    test('is a no-op when no key is stored (first-launch restore)', () async {
      storage.throwOnDeleteOfMissingKey = true;
      await service.deleteStoredKey();
      expect(await service.loadStoredKeyMaterial(), isNull);
    });
  });

  group('books-set key namespacing', () {
    test('migrateLegacyKeyToBooksSet moves the seed once', () async {
      await storage.write(
        SigningKeyService.privateKeySeedStorageKey,
        'legacy-seed',
      );
      await SigningKeyService.migrateLegacyKeyToBooksSet(
        secureStorage: storage,
        booksSetId: 'set-1',
      );
      expect(
        await storage.read(SigningKeyService.privateKeySeedStorageKey),
        isNull,
      );
      expect(
        await storage.read(SigningKeyService.storageKeyFor('set-1')),
        'legacy-seed',
      );
    });

    test('scoped service reads and writes the namespaced key', () async {
      final scoped = SigningKeyService(
        secureStorage: storage,
        booksSetId: 'set-1',
      );
      final generated = await scoped.generateNewIdentity();
      expect(
        await storage.read(SigningKeyService.storageKeyFor('set-1')),
        isNotNull,
      );
      expect(
        await storage.read(SigningKeyService.privateKeySeedStorageKey),
        isNull,
      );
      expect(
        (await scoped.loadStoredKeyMaterial())!.publicKey,
        generated.keyMaterial.publicKey,
      );
    });
  });
}
