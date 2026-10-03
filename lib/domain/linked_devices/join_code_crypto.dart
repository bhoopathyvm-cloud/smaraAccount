import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// HMAC helpers for join-by-code (real-sync design Decision 3 / task 4.2).
class JoinCodeCrypto {
  /// Proves knowledge of [code] using both session nonces.
  static List<int> codeProof({
    required String code,
    required List<int> inviterNonce,
    required List<int> joinerNonce,
  }) {
    final key = utf8.encode(JoinCodeNormalize.normalize(code));
    final material = BytesBuilder()
      ..add(inviterNonce)
      ..add(joinerNonce);
    return Hmac(sha256, key).convert(material.toBytes()).bytes;
  }

  /// Six-digit check code shown on both screens before data flows.
  ///
  /// `HMAC-SHA256(code, inviterPublicKey ‖ joinerPublicKey ‖ nonces)` reduced
  /// to 6 decimal digits.
  static String checkCode({
    required String code,
    required List<int> inviterPublicKey,
    required List<int> joinerPublicKey,
    required List<int> inviterNonce,
    required List<int> joinerNonce,
  }) {
    final key = utf8.encode(JoinCodeNormalize.normalize(code));
    final material = BytesBuilder()
      ..add(inviterPublicKey)
      ..add(joinerPublicKey)
      ..add(inviterNonce)
      ..add(joinerNonce);
    final digest = Hmac(sha256, key).convert(material.toBytes()).bytes;
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
