import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';

/// Device TLS certificate material exchanged at join (design Decision 2).
/// Real X.509 generation is a follow-up when section 5 TLS lands;
/// [FakeDeviceCertificateStore] issues stand-in DER bytes and fingerprints
/// for membership/QR tests.
class DeviceCertificate {
  const DeviceCertificate({required this.derBytes, required this.fingerprint});

  final List<int> derBytes;
  final String fingerprint;
}

abstract class DeviceCertificateStore {
  Future<DeviceCertificate> localCertificate({required String deviceId});
}

class FakeDeviceCertificateStore implements DeviceCertificateStore {
  FakeDeviceCertificateStore({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  final Map<String, DeviceCertificate> _cache = {};

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
    return cert;
  }
}
