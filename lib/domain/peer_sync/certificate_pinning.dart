import 'dart:convert';

import '../crypto/crypto_backend.dart';
import '../linked_devices/device_certificate_store.dart';

/// Result of comparing a presented device certificate to the pins exchanged
/// at join (design Decision 2).
enum PinCheckResult { accepted, refusedUnknown }

/// Validates peer TLS certificates against fingerprints stored at join.
class CertificatePinning {
  const CertificatePinning({required this.pinnedFingerprints});

  /// Fingerprints of device certificates exchanged for these books.
  final Set<String> pinnedFingerprints;

  /// Accepts when [fingerprint] is in [pinnedFingerprints].
  PinCheckResult checkFingerprint(String fingerprint) {
    if (pinnedFingerprints.contains(fingerprint)) {
      return PinCheckResult.accepted;
    }
    return PinCheckResult.refusedUnknown;
  }

  /// Hashes [certificate] DER bytes and checks the pin set.
  Future<PinCheckResult> checkCertificate(DeviceCertificate certificate) {
    return checkDerBytes(certificate.derBytes);
  }

  Future<PinCheckResult> checkDerBytes(List<int> derBytes) async {
    final fingerprint = await fingerprintOf(derBytes);
    return checkFingerprint(fingerprint);
  }

  /// SHA-256 hex of certificate DER bytes, the pin format every platform
  /// shares. Hashed by the [CryptoBackend].
  static Future<String> fingerprintOf(List<int> derBytes) async {
    final hash = await CryptoBackend.instance.sha256(derBytes);
    return hexOf(hash);
  }

  /// Lowercase hex of [bytes].
  static String hexOf(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  /// Convenience: fingerprint of [utf8] seed bytes (tests / fakes).
  static Future<String> fingerprintOfUtf8(String seed) {
    return fingerprintOf(utf8.encode(seed));
  }
}
