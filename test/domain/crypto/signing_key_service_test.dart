import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:test/test.dart';

import 'in_memory_secure_key_storage.dart';

void main() {
  late InMemorySecureKeyStorage storage;
  late SigningKeyService service;

  setUp(() {
    storage = InMemorySecureKeyStorage();
    service = SigningKeyService(secureStorage: storage);
  });

  group('loadStoredKeyMaterial', () {
    test('returns null when no identity has been generated yet', () async {
      final material = await service.loadStoredKeyMaterial();

      expect(material, isNull);
    });

    test('returns the stored key material after generateNewIdentity', () async {
      final generated = await service.generateNewIdentity();

      final loaded = await service.loadStoredKeyMaterial();

      expect(loaded!.publicKey, equals(generated.keyMaterial.publicKey));
    });
  });

  group('generateNewIdentity', () {
    test(
      'returns a 24-word phrase that deterministically derives the stored key',
      () async {
        final generated = await service.generateNewIdentity();

        expect(generated.phrase.words, hasLength(24));

        final rederived = await service.restoreFromRecoveryPhrase(
          generated.phrase.words,
        );
        expect(rederived.publicKey, equals(generated.keyMaterial.publicKey));
      },
    );

    test('two calls produce different identities', () async {
      final a = await service.generateNewIdentity();
      final b = await service.generateNewIdentity();

      expect(a.keyMaterial.publicKey, isNot(equals(b.keyMaterial.publicKey)));
    });
  });

  group('restoreFromRecoveryPhrase', () {
    test('rejects a phrase with an invalid checksum', () async {
      final generated = await service.generateNewIdentity();
      final tampered = [...generated.phrase.words];
      final tmp = tampered[0];
      tampered[0] = tampered[1];
      tampered[1] = tmp;

      expect(
        () => service.restoreFromRecoveryPhrase(tampered),
        throwsException,
      );
    });
  });

  group('sign / verify round trip through the service', () {
    test(
      'a message signed with the stored key verifies against its public key',
      () async {
        final generated = await service.generateNewIdentity();
        final message = 'entry content'.codeUnits;

        final signature = await service.sign(message);
        final isValid = await service.verify(
          message,
          signature: signature,
          publicKey: generated.keyMaterial.publicKey,
        );

        expect(isValid, isTrue);
      },
    );

    test('sign throws when no identity is stored', () async {
      expect(() => service.sign('anything'.codeUnits), throwsStateError);
    });
  });

  group('keystore file export / restore', () {
    test('exporting then restoring recovers the same key', () async {
      final generated = await service.generateNewIdentity();

      final file = await service.exportKeystoreFile(
        passphrase: 'hunter2-hunter2',
      );
      final restored = await service.restoreFromKeystoreFile(
        fileContents: file,
        passphrase: 'hunter2-hunter2',
      );

      expect(restored.publicKey, equals(generated.keyMaterial.publicKey));
    });

    test('export throws when no identity is stored', () async {
      expect(
        () => service.exportKeystoreFile(passphrase: 'x'),
        throwsStateError,
      );
    });
  });
}
