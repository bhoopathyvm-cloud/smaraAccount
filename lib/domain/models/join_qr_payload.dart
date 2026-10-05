import 'dart:convert';

import '../crypto/crypto_backend.dart';

import 'linked_device_role.dart';

/// In-person QR payload for "Add a device" / "Add a person". Carries public
/// material only — never private key bytes (ADR 0004 / linked-devices
/// design Decision 2; shared-accounts design Decision 6).
///
/// Offers expire after [joinQrTtl] and may be accepted at most once
/// (task 12.3).
class JoinQrPayload {
  const JoinQrPayload({
    required this.booksSetId,
    required this.hostDeviceId,
    required this.hostDisplayName,
    required this.hostIdentityId,
    required this.signingPublicKey,
    required this.deviceCertDer,
    required this.deviceCertFingerprint,
    required this.roleOffer,
    required this.joinNonce,
    required this.expiresAt,
    required this.checkCode,
    this.protocolVersion = 1,
    this.personRoles = const {},
    this.personDisplayName,
    this.isPersonJoin = false,
    this.booksSetDisplayName,
    this.joinCode,
  });

  /// How long a freshly built join QR remains acceptable.
  static const joinQrTtl = Duration(minutes: 2);

  final int protocolVersion;
  final String booksSetId;
  final String hostDeviceId;
  final String hostDisplayName;

  /// Host Signing Identity id — shared so the joiner stores the same id for
  /// the host's public key (entries are verified by `signedByIdentityId`).
  final String hostIdentityId;

  /// Host Signing Identity public key bytes (SPKI / raw as stored).
  final List<int> signingPublicKey;

  /// Host device TLS certificate DER bytes (or stand-in until real TLS).
  final List<int> deviceCertDer;

  final String deviceCertFingerprint;

  /// Primary role offer (B-compatible). Prefer [personRoles] when set.
  final LinkedDeviceRole roleOffer;
  final String joinNonce;

  /// Absolute expiry (UTC). Offers past this instant are refused.
  final DateTime expiresAt;

  /// Short shared code shown on host and joiner screens before data flows.
  final String checkCode;

  /// Role set offered for "Add a person" (default Claimant).
  final Set<LinkedDeviceRole> personRoles;

  /// Display name for the person being added.
  final String? personDisplayName;

  /// True when this QR is an "Add a person" offer (vs device).
  final bool isPersonJoin;

  /// Host books-set display name so joiners show the company name, not
  /// "Books N".
  final String? booksSetDisplayName;

  /// The join code issued with this offer ("Enter code instead"). Scanning
  /// the QR then runs the same lookup, check code and handshake as typing
  /// the code, so the inviting device learns the joiner's certificate; the
  /// QR alone never contacted the host, and the devices could not sync.
  final String? joinCode;

  /// This payload with [code] embedded (see [joinCode]).
  JoinQrPayload withJoinCode(String code) => JoinQrPayload(
    protocolVersion: protocolVersion,
    booksSetId: booksSetId,
    hostDeviceId: hostDeviceId,
    hostDisplayName: hostDisplayName,
    hostIdentityId: hostIdentityId,
    signingPublicKey: signingPublicKey,
    deviceCertDer: deviceCertDer,
    deviceCertFingerprint: deviceCertFingerprint,
    roleOffer: roleOffer,
    joinNonce: joinNonce,
    expiresAt: expiresAt,
    checkCode: checkCode,
    personRoles: personRoles,
    personDisplayName: personDisplayName,
    isPersonJoin: isPersonJoin,
    booksSetDisplayName: booksSetDisplayName,
    joinCode: code,
  );

  static const _privateKeyKeys = {
    'privateKey',
    'private_key',
    'signingPrivateKey',
    'signing_private_key',
    'secretKey',
    'secret_key',
  };

  /// Six-character uppercase check code derived from [joinNonce].
  static Future<String> deriveCheckCode(String joinNonce) async {
    final digest = await CryptoBackend.instance.sha256(
      utf8.encode('smara-join-check:$joinNonce'),
    );
    final hex = digest
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
    return hex.substring(0, 6);
  }

  bool isExpiredAt(DateTime now) => !now.toUtc().isBefore(expiresAt.toUtc());

  Map<String, Object?> toJson() => {
    'v': protocolVersion,
    'booksSetId': booksSetId,
    'hostDeviceId': hostDeviceId,
    'hostDisplayName': hostDisplayName,
    'hostIdentityId': hostIdentityId,
    'signingPublicKey': base64Encode(signingPublicKey),
    'deviceCert': base64Encode(deviceCertDer),
    'deviceCertFingerprint': deviceCertFingerprint,
    'roleOffer': roleOffer.name,
    'joinNonce': joinNonce,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'checkCode': checkCode,
    if (personRoles.isNotEmpty)
      'personRoles': personRoles.map((r) => r.name).toList()..sort(),
    if (personDisplayName != null) 'personDisplayName': personDisplayName,
    if (isPersonJoin) 'isPersonJoin': true,
    if (booksSetDisplayName != null && booksSetDisplayName!.isNotEmpty)
      'booksSetDisplayName': booksSetDisplayName,
    if (joinCode != null) 'joinCode': joinCode,
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
    final hostIdentityId = map['hostIdentityId'];
    final signingPublicKeyB64 = map['signingPublicKey'];
    final deviceCertB64 = map['deviceCert'];
    final fingerprint = map['deviceCertFingerprint'];
    final roleOfferRaw = map['roleOffer'];
    final joinNonce = map['joinNonce'];
    final expiresAtRaw = map['expiresAt'];
    final checkCode = map['checkCode'];
    final version = map['v'] ?? 1;

    if (booksSetId is! String ||
        hostDeviceId is! String ||
        hostDisplayName is! String ||
        hostIdentityId is! String ||
        signingPublicKeyB64 is! String ||
        deviceCertB64 is! String ||
        fingerprint is! String ||
        roleOfferRaw is! String ||
        joinNonce is! String ||
        expiresAtRaw is! String ||
        checkCode is! String) {
      throw const FormatException(
        'Join QR payload is missing required fields.',
      );
    }

    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) {
      throw const FormatException('Join QR payload has an invalid expiresAt.');
    }

    final roleOffer = LinkedDeviceRole.values.where(
      (r) => r.name == roleOfferRaw,
    );
    if (roleOffer.isEmpty) {
      throw FormatException('Unknown role offer: $roleOfferRaw');
    }

    final personRoles = <LinkedDeviceRole>{};
    final personRolesRaw = map['personRoles'];
    if (personRolesRaw is List) {
      for (final item in personRolesRaw) {
        if (item is! String) {
          throw const FormatException('personRoles entries must be strings.');
        }
        final match = LinkedDeviceRole.values.where((r) => r.name == item);
        if (match.isEmpty) {
          throw FormatException('Unknown person role: $item');
        }
        personRoles.add(match.first);
      }
    }

    return JoinQrPayload(
      protocolVersion: version is int ? version : int.parse('$version'),
      booksSetId: booksSetId,
      hostDeviceId: hostDeviceId,
      hostDisplayName: hostDisplayName,
      hostIdentityId: hostIdentityId,
      signingPublicKey: base64Decode(signingPublicKeyB64),
      deviceCertDer: base64Decode(deviceCertB64),
      deviceCertFingerprint: fingerprint,
      roleOffer: roleOffer.first,
      joinNonce: joinNonce,
      expiresAt: expiresAt.toUtc(),
      checkCode: checkCode,
      personRoles: personRoles,
      personDisplayName: map['personDisplayName'] as String?,
      isPersonJoin: map['isPersonJoin'] == true,
      booksSetDisplayName: map['booksSetDisplayName'] as String?,
      joinCode: map['joinCode'] as String?,
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

/// Tracks join nonces that have already been accepted so a QR cannot be reused
/// (task 12.3). Process-local; a fresh QR always gets a new nonce.
class JoinNonceRegistry {
  final Set<String> _used = {};

  bool hasBeenUsed(String joinNonce) => _used.contains(joinNonce);

  void markUsed(String joinNonce) {
    _used.add(joinNonce);
  }

  void clear() => _used.clear();
}
