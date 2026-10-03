import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';

/// Device TLS certificate material exchanged at join (design Decision 2).
///
/// [derBytes] / [fingerprint] travel in the QR payload. [certificatePem] and
/// [privateKeyPem] stay on the owning device for [TlsSyncTransport] and are
/// never included in sync or QR payloads (ADR 0004).
class DeviceCertificate {
  const DeviceCertificate({
    required this.derBytes,
    required this.fingerprint,
    this.certificatePem,
    this.privateKeyPem,
  });

  final List<int> derBytes;
  final String fingerprint;

  /// PEM-encoded certificate for [SecurityContext], when available.
  final String? certificatePem;

  /// PEM-encoded private key for the local TLS identity, when available.
  final String? privateKeyPem;
}

abstract class DeviceCertificateStore {
  Future<DeviceCertificate> localCertificate({required String deviceId});

  /// Remembers a peer's public certificate (DER/PEM, never a private key)
  /// so [TlsSyncTransport.listen] can trust it during client-cert TLS.
  /// Membership only stores fingerprints; the PEM must come from join.
  Future<void> rememberPeerCertificate(DeviceCertificate certificate) async {}

  /// Public material for [fingerprint], when previously [rememberPeerCertificate]
  /// was called (or the fingerprint belongs to a local identity).
  Future<DeviceCertificate?> certificateForFingerprint(
    String fingerprint,
  ) async => null;
}

class FakeDeviceCertificateStore implements DeviceCertificateStore {
  FakeDeviceCertificateStore({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  final Map<String, DeviceCertificate> _cache = {};
  final Map<String, DeviceCertificate> _byFingerprint = {};

  @override
  Future<DeviceCertificate> localCertificate({required String deviceId}) async {
    final existing = _cache[deviceId];
    if (existing != null) return existing;
    final seed = utf8.encode('smara-device-cert:$deviceId:${_uuid.v4()}');
    final hash = await Sha256().hash(seed);
    final der = Uint8List.fromList([...hash.bytes, ...seed]);
    final fp = await Sha256().hash(der);
    final fingerprint = fp.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final cert = DeviceCertificate(derBytes: der, fingerprint: fingerprint);
    _cache[deviceId] = cert;
    _byFingerprint[fingerprint] = cert;
    return cert;
  }

  @override
  Future<void> rememberPeerCertificate(DeviceCertificate certificate) async {
    if (certificate.derBytes.isEmpty && certificate.certificatePem == null) {
      return;
    }
    final fp = certificate.fingerprint;
    if (fp.isEmpty) return;
    _byFingerprint[fp] = certificate;
  }

  @override
  Future<DeviceCertificate?> certificateForFingerprint(
    String fingerprint,
  ) async => _byFingerprint[fingerprint];
}
