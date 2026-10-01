import 'dart:convert';

import 'linked_device_role.dart';

/// In-person QR payload for "Add a device". Carries public material only —
/// never private key bytes (ADR 0004 / linked-devices design Decision 2).
class JoinQrPayload {
  const JoinQrPayload({
    required this.booksSetId,
    required this.hostDeviceId,
    required this.hostDisplayName,
    required this.signingPublicKey,
    required this.deviceCertDer,
    required this.deviceCertFingerprint,
    required this.roleOffer,
    required this.joinNonce,
    this.protocolVersion = 1,
  });

  final int protocolVersion;
  final String booksSetId;
  final String hostDeviceId;
  final String hostDisplayName;

  /// Host Signing Identity public key bytes (SPKI / raw as stored).
  final List<int> signingPublicKey;

  /// Host device TLS certificate DER bytes (or stand-in until real TLS).
  final List<int> deviceCertDer;

  final String deviceCertFingerprint;
  final LinkedDeviceRole roleOffer;
  final String joinNonce;

  static const _privateKeyKeys = {
    'privateKey',
    'private_key',
    'signingPrivateKey',
    'signing_private_key',
    'secretKey',
    'secret_key',
  };

  Map<String, Object?> toJson() => {
    'v': protocolVersion,
    'booksSetId': booksSetId,
    'hostDeviceId': hostDeviceId,
    'hostDisplayName': hostDisplayName,
    'signingPublicKey': base64Encode(signingPublicKey),
    'deviceCert': base64Encode(deviceCertDer),
    'deviceCertFingerprint': deviceCertFingerprint,
    'roleOffer': roleOffer.name,
    'joinNonce': joinNonce,
  };

  String encode() => jsonEncode(toJson());

  /// Parses [raw] JSON. Throws [FormatException] if private-key fields are
  /// present or required public fields are missing/invalid.
  static JoinQrPayload decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Join QR payload must be a JSON object.');
    }
    final map = Map<String, dynamic>.from(decoded);
    for (final key in map.keys) {
      if (_privateKeyKeys.contains(key)) {
        throw FormatException(
          'Join QR payload must not include private key material ($key).',
        );
      }
    }

    final booksSetId = map['booksSetId'];
    final hostDeviceId = map['hostDeviceId'];
    final hostDisplayName = map['hostDisplayName'];
    final signingPublicKeyB64 = map['signingPublicKey'];
    final deviceCertB64 = map['deviceCert'];
    final fingerprint = map['deviceCertFingerprint'];
    final roleOfferRaw = map['roleOffer'];
    final joinNonce = map['joinNonce'];
    final version = map['v'] ?? 1;

    if (booksSetId is! String ||
        hostDeviceId is! String ||
        hostDisplayName is! String ||
        signingPublicKeyB64 is! String ||
        deviceCertB64 is! String ||
        fingerprint is! String ||
        roleOfferRaw is! String ||
        joinNonce is! String) {
      throw const FormatException(
        'Join QR payload is missing required fields.',
      );
    }

    final roleOffer = LinkedDeviceRole.values.where(
      (r) => r.name == roleOfferRaw,
    );
    if (roleOffer.isEmpty) {
      throw FormatException('Unknown role offer: $roleOfferRaw');
    }

    return JoinQrPayload(
      protocolVersion: version is int ? version : int.parse('$version'),
      booksSetId: booksSetId,
      hostDeviceId: hostDeviceId,
      hostDisplayName: hostDisplayName,
      signingPublicKey: base64Decode(signingPublicKeyB64),
      deviceCertDer: base64Decode(deviceCertB64),
      deviceCertFingerprint: fingerprint,
      roleOffer: roleOffer.first,
      joinNonce: joinNonce,
    );
  }

  /// True when [raw] JSON contains any known private-key field name.
  static bool containsPrivateKeyMaterial(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return false;
      return decoded.keys.any((k) => _privateKeyKeys.contains('$k'));
    } on FormatException {
      return false;
    }
  }
}
