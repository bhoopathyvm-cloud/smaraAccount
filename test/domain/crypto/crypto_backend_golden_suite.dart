import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/backup/books_copy_file.dart';
import 'package:smara_accounting/domain/crypto/crypto_backend.dart';

import '../../fixtures/books_copy/dart_backend_v1.dart';

/// Golden vectors every [CryptoBackend] must reproduce byte for byte
/// (os-provided-encryption task 1.3). The unit suite runs them on the Dart
/// backend; `integration_test/crypto_backend_golden_test.dart` runs the same
/// file against the Apple backend on the macOS and iOS simulators. Two
/// backends that both pass cannot have drifted apart on these formats.
///
/// Sources: SHA-256 and HMAC from FIPS 180-4 / RFC 4231, PBKDF2 from
/// RFC 7914 §11, AES-GCM from the NIST GCM spec test cases, Ed25519 from
/// RFC 8032 §7.1. The Books Copy fixture was saved by the Dart backend.
void runCryptoBackendGoldenSuite(
  String label,
  CryptoBackend Function() makeBackend,
) {
  group('CryptoBackend golden vectors ($label)', () {
    late CryptoBackend backend;

    setUp(() => backend = makeBackend());

    test('SHA-256("abc") matches FIPS 180-4', () async {
      final digest = await backend.sha256(utf8.encode('abc'));
      expect(
        _hex(digest),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('sha256Many hashes each input in order', () async {
      final digests = await backend.sha256Many([
        utf8.encode('abc'),
        const <int>[],
        utf8.encode('abc'),
      ]);
      expect(digests, hasLength(3));
      expect(
        _hex(digests[0]),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
      expect(
        _hex(digests[1]),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
      expect(digests[2], equals(digests[0]));
      expect(await backend.sha256Many(const []), isEmpty);
    });

    test('HMAC-SHA256 matches RFC 4231 test case 2', () async {
      final mac = await backend.hmacSha256(
        key: utf8.encode('Jefe'),
        message: utf8.encode('what do ya want for nothing?'),
      );
      expect(
        _hex(mac),
        '5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843',
      );
    });

    test('PBKDF2-HMAC-SHA256 matches RFC 7914 vectors', () async {
      final one = await backend.pbkdf2HmacSha256(
        password: utf8.encode('password'),
        salt: utf8.encode('salt'),
        iterations: 1,
        keyLength: 32,
      );
      expect(
        _hex(one),
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
      );
      final many = await backend.pbkdf2HmacSha256(
        password: utf8.encode('password'),
        salt: utf8.encode('salt'),
        iterations: 4096,
        keyLength: 32,
      );
      expect(
        _hex(many),
        'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
      );
    });

    test('AES-256-GCM matches NIST test cases 13, 14 and 16', () async {
      final zeroKey = Uint8List(32);
      final zeroNonce = Uint8List(12);

      final empty = await backend.aesGcmEncrypt(
        key: zeroKey,
        plainText: const [],
        nonce: zeroNonce,
      );
      expect(empty.cipherText, isEmpty);
      expect(_hex(empty.mac), '530f8afbc74536b9a963b4f1c4cb738b');

      final block = await backend.aesGcmEncrypt(
        key: zeroKey,
        plainText: Uint8List(16),
        nonce: zeroNonce,
      );
      expect(_hex(block.cipherText), 'cea7403d4d606b6e074ec5d3baf39d18');
      expect(_hex(block.mac), 'd0d1c8a799996bf0265b98b5d48ab919');
      expect(_hex(block.nonce), '000000000000000000000000');

      final key = _bytes(
        'feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308',
      );
      final nonce = _bytes('cafebabefacedbaddecaf888');
      final plain = _bytes(
        'd9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a72'
        '1c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b39',
      );
      final aad = _bytes('feedfacedeadbeeffeedfacedeadbeefabaddad2');
      final sealed = await backend.aesGcmEncrypt(
        key: key,
        plainText: plain,
        nonce: nonce,
        aad: aad,
      );
      expect(
        _hex(sealed.cipherText),
        '522dc1f099567d07f47f37a32a84427d643a8cdcbfe5c0c97598a2bd2555d1aa'
        '8cb08e48590dbb3da7b08b1056828838c5f61e6393ba7a0abcc9f662',
      );
      expect(_hex(sealed.mac), '76fc6ece0f4e1768cddf8853bb2d551b');

      final opened = await backend.aesGcmDecrypt(
        key: key,
        box: sealed,
        aad: aad,
      );
      expect(opened, equals(plain));
    });

    test('AES-GCM refuses a tampered tag with the shared exception', () async {
      final sealed = await backend.aesGcmEncrypt(
        key: Uint8List(32),
        plainText: utf8.encode('books'),
      );
      expect(sealed.nonce, hasLength(12));
      final tampered = AesGcmBox(
        nonce: sealed.nonce,
        cipherText: sealed.cipherText,
        mac: Uint8List(16),
      );
      await expectLater(
        backend.aesGcmDecrypt(key: Uint8List(32), box: tampered),
        throwsA(isA<CryptoAuthenticationException>()),
      );
      await expectLater(
        backend.aesGcmDecrypt(key: Uint8List(32)..[0] = 1, box: sealed),
        throwsA(isA<CryptoAuthenticationException>()),
      );
    });

    test('Ed25519 keys and signatures match RFC 8032 test 1 and 2', () async {
      final seed1 = _bytes(
        '9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60',
      );
      final pair1 = await backend.ed25519FromSeed(seed1);
      expect(pair1.privateKeySeed, equals(seed1));
      expect(
        _hex(pair1.publicKey),
        'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
      );
      // A signature made by a reference implementation verifies here
      // (sign on one implementation, verify on another).
      final referenceSignature = _bytes(
        'e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e06522490155'
        '5fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b',
      );
      expect(
        await backend.ed25519Verify(
          publicKey: pair1.publicKey,
          message: const [],
          signature: referenceSignature,
        ),
        isTrue,
      );

      final seed2 = _bytes(
        '4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb',
      );
      final pair2 = await backend.ed25519FromSeed(seed2);
      expect(
        _hex(pair2.publicKey),
        '3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c',
      );
      final signature72 = _bytes(
        '92a009a9f0d4cab8720e820b5f642540a2b27b5416503f8fb3762223ebdb69da'
        '085ac1e43e15996e458f3613d0f11d8c387b2eaeb4302aeeb00d291612bb0c00',
      );
      expect(
        await backend.ed25519Verify(
          publicKey: pair2.publicKey,
          message: const [0x72],
          signature: signature72,
        ),
        isTrue,
      );
      expect(
        await backend.ed25519Verify(
          publicKey: pair2.publicKey,
          message: const [0x73],
          signature: signature72,
        ),
        isFalse,
      );
      expect(
        await backend.ed25519Verify(
          publicKey: pair1.publicKey,
          message: const [0x72],
          signature: signature72,
        ),
        isFalse,
      );
    });

    test(
      'Ed25519 signatures made here verify; bytes are not compared',
      () async {
        final pair = await backend.ed25519Generate();
        expect(pair.privateKeySeed, hasLength(32));
        expect(pair.publicKey, hasLength(32));
        final message = utf8.encode('hello ledger');
        final signature = await backend.ed25519Sign(
          seed: pair.privateKeySeed,
          message: message,
        );
        expect(signature, hasLength(64));
        expect(
          await backend.ed25519Verify(
            publicKey: pair.publicKey,
            message: message,
            signature: signature,
          ),
          isTrue,
        );
        final other = await backend.ed25519Generate();
        expect(
          await backend.ed25519Verify(
            publicKey: other.publicKey,
            message: message,
            signature: signature,
          ),
          isFalse,
        );
        expect(
          await backend.ed25519Verify(
            publicKey: pair.publicKey,
            message: message,
            signature: Uint8List(10),
          ),
          isFalse,
        );
      },
    );

    test('Dart-backend signature fixture verifies', () async {
      // Signed by the Dart backend over the RFC 8032 test-1 key; a copy
      // restored or synced from Android must verify on Apple.
      final publicKey = _bytes(
        'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
      );
      final signature = _bytes(dartBackendSignatureOfLedgerMessage);
      expect(
        await backend.ed25519Verify(
          publicKey: publicKey,
          message: utf8.encode('smara ledger entry'),
          signature: signature,
        ),
        isTrue,
      );
    });

    test('Books Copy saved by the Dart backend restores', () async {
      // Embedded copy: the repository's files aren't readable on iOS.
      const fixture = booksCopyDartBackendV1;
      final contents = await BooksCopyFile.decrypt(
        fileContents: fixture,
        passphrase: booksCopyFixturePassphrase,
        backend: backend,
      );
      expect(contents.sourceKind, BooksCopySourceKind.booksCopy);
      expect(contents.databaseBytes, equals(booksCopyFixtureDatabaseBytes));
      expect(contents.settings, equals(booksCopyFixtureSettings));
      expect(contents.receiptsById['r1'], equals(utf8.encode('receipt-one')));
      await expectLater(
        BooksCopyFile.decrypt(
          fileContents: fixture,
          passphrase: 'not the passphrase',
          backend: backend,
        ),
        throwsA(isA<CryptoAuthenticationException>()),
      );
    });

    test('Books Copy written here round-trips', () async {
      final encoded = await BooksCopyFile.encrypt(
        databaseBytes: booksCopyFixtureDatabaseBytes,
        settings: booksCopyFixtureSettings,
        passphrase: booksCopyFixturePassphrase,
        backend: backend,
      );
      final decoded = await BooksCopyFile.decrypt(
        fileContents: encoded,
        passphrase: booksCopyFixturePassphrase,
        backend: backend,
      );
      expect(decoded.databaseBytes, equals(booksCopyFixtureDatabaseBytes));
      expect(decoded.settings, equals(booksCopyFixtureSettings));
    });
  });
}

/// Inputs of `test/fixtures/books_copy/dart_backend_v1.json`.
const booksCopyFixturePassphrase = 'correct horse battery staple';
final booksCopyFixtureDatabaseBytes = Uint8List.fromList(
  List<int>.generate(256, (i) => (i * 7) & 0xff),
);
const booksCopyFixtureSettings = <String, Object?>{
  'referenceRateLookupEnabled': true,
  'quoteProvider': 'stooq',
  'locale': 'en',
};

/// Ed25519 signature by the Dart backend over `smara ledger entry` with the
/// RFC 8032 test-1 seed (deterministic in Dart, so the bytes are stable).
const dartBackendSignatureOfLedgerMessage =
    '71a236fb2e397654cb93eec9a8bf34e1f50da1096904b22237320b3c71e1d7ad'
    '03bb04ff015c301c08488ac2499b58f164edb4bab78afbb014968901eb8e9e05';

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

Uint8List _bytes(String hex) {
  final out = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}
