import 'dart:convert';
import 'dart:typed_data';

import '../crypto/crypto_backend.dart';

/// HMAC helpers for join-by-code (real-sync design Decision 3 / task 4.2).
/// HMAC-SHA256 runs in the [CryptoBackend], so Apple builds compute join
/// proofs and check codes through CryptoKit; the bytes are identical on
/// every platform.
class JoinCodeCrypto {
  /// Proves knowledge of [code] using both session nonces.
  static Future<List<int>> codeProof({
    required String code,
    required List<int> inviterNonce,
    required List<int> joinerNonce,
    CryptoBackend? backend,
  }) {
    final key = utf8.encode(JoinCodeNormalize.normalize(code));
    final material = BytesBuilder()
      ..add(inviterNonce)
      ..add(joinerNonce);
    return (backend ?? CryptoBackend.instance).hmacSha256(
      key: key,
      message: material.toBytes(),
    );
  }

  /// Six-digit check code shown on both screens before data flows.
  ///
  /// `HMAC-SHA256(code, inviterPublicKey ‖ joinerPublicKey ‖ nonces)` reduced
  /// to 6 decimal digits.
  static Future<String> checkCode({
    required String code,
    required List<int> inviterPublicKey,
    required List<int> joinerPublicKey,
    required List<int> inviterNonce,
    required List<int> joinerNonce,
    CryptoBackend? backend,
  }) async {
    final key = utf8.encode(JoinCodeNormalize.normalize(code));
    final material = BytesBuilder()
      ..add(inviterPublicKey)
      ..add(joinerPublicKey)
      ..add(inviterNonce)
      ..add(joinerNonce);
    final digest = await (backend ?? CryptoBackend.instance).hmacSha256(
      key: key,
      message: material.toBytes(),
    );
    var n = 0;
    for (var i = 0; i < 4; i++) {
      n = (n << 8) | digest[i];
    }
    final six = (n.abs() % 1000000).toString().padLeft(6, '0');
    return six;
  }
}

/// Shared normalize for join codes (avoids importing the full JoinCode type
/// into crypto-only call sites).
class JoinCodeNormalize {
  static String normalize(String input) =>
      input.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
}
