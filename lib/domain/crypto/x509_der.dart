import 'dart:math';
import 'dart:typed_data';

/// Minimal ASN.1 DER encoder: enough to assemble a self-signed X.509 v3
/// certificate without any cryptography. On Apple platforms the operating
/// system generates the key and signs the TBSCertificate; Dart only
/// serialises the structure (design D4).
class Asn1Der {
  const Asn1Der._();

  static Uint8List _tlv(int tag, List<int> content) {
    final out = BytesBuilder()..addByte(tag);
    final length = content.length;
    if (length < 0x80) {
      out.addByte(length);
    } else {
      final lengthBytes = <int>[];
      var remaining = length;
      while (remaining > 0) {
        lengthBytes.insert(0, remaining & 0xff);
        remaining >>= 8;
      }
      out.addByte(0x80 | lengthBytes.length);
      out.add(lengthBytes);
    }
    out.add(content);
    return out.toBytes();
  }

  static Uint8List sequence(List<List<int>> items) =>
      _tlv(0x30, _concat(items));

  static Uint8List set(List<List<int>> items) => _tlv(0x31, _concat(items));

  /// Positive INTEGER from big-endian magnitude bytes (leading zero added
  /// when the high bit is set).
  static Uint8List integerBytes(List<int> magnitude) {
    var start = 0;
    while (start < magnitude.length - 1 && magnitude[start] == 0) {
      start++;
    }
    final trimmed = magnitude.sublist(start);
    final needsPad = trimmed.isEmpty || (trimmed[0] & 0x80) != 0;
    return _tlv(0x02, [if (needsPad) 0, ...trimmed]);
  }

  static Uint8List integer(int value) {
    if (value < 0) throw ArgumentError('Only non-negative integers.');
    final bytes = <int>[];
    var remaining = value;
    do {
      bytes.insert(0, remaining & 0xff);
      remaining >>= 8;
    } while (remaining > 0);
    return integerBytes(bytes);
  }

  static Uint8List bigInteger(BigInt value) {
    if (value.isNegative) throw ArgumentError('Only non-negative integers.');
    final bytes = <int>[];
    var remaining = value;
    final mask = BigInt.from(0xff);
    do {
      bytes.insert(0, (remaining & mask).toInt());
      remaining >>= 8;
    } while (remaining > BigInt.zero);
    return integerBytes(bytes);
  }

  static Uint8List bitString(List<int> content, {int unusedBits = 0}) =>
      _tlv(0x03, [unusedBits, ...content]);

  static Uint8List octetString(List<int> content) => _tlv(0x04, content);

  static Uint8List nullValue() => _tlv(0x05, const []);

  static Uint8List objectIdentifier(String dotted) {
    final parts = dotted.split('.').map(int.parse).toList();
    if (parts.length < 2) throw ArgumentError('OID needs two arcs: $dotted');
    final content = <int>[parts[0] * 40 + parts[1]];
    for (final arc in parts.skip(2)) {
      final encoded = <int>[arc & 0x7f];
      var remaining = arc >> 7;
      while (remaining > 0) {
        encoded.insert(0, (remaining & 0x7f) | 0x80);
        remaining >>= 7;
      }
      content.addAll(encoded);
    }
    return _tlv(0x06, content);
  }

  static Uint8List utf8String(String value) => _tlv(
    0x0c,
    Uint8List.fromList(
      value.codeUnits.length == value.length ? value.codeUnits : _utf8(value),
    ),
  );

  static Uint8List printableString(String value) => _tlv(0x13, value.codeUnits);

  static Uint8List boolean(bool value) => _tlv(0x01, [value ? 0xff : 0x00]);

  /// UTCTime for years before 2050, GeneralizedTime from 2050 on (RFC 5280
  /// 4.1.2.5).
  static Uint8List time(DateTime value) {
    final utc = value.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    final body =
        '${two(utc.month)}${two(utc.day)}${two(utc.hour)}'
        '${two(utc.minute)}${two(utc.second)}Z';
    if (utc.year < 2050) {
      return _tlv(0x17, '${two(utc.year % 100)}$body'.codeUnits);
    }
    return _tlv(0x18, '${utc.year.toString().padLeft(4, '0')}$body'.codeUnits);
  }

  /// Context-specific, constructed, explicit tag `[n]`.
  static Uint8List explicit(int tagNumber, List<int> content) =>
      _tlv(0xa0 | tagNumber, content);

  static Uint8List _concat(List<List<int>> items) {
    final out = BytesBuilder();
    for (final item in items) {
      out.add(item);
    }
    return out.toBytes();
  }

  static List<int> _utf8(String value) {
    final out = <int>[];
    for (final rune in value.runes) {
      if (rune < 0x80) {
        out.add(rune);
      } else if (rune < 0x800) {
        out.addAll([0xc0 | (rune >> 6), 0x80 | (rune & 0x3f)]);
      } else if (rune < 0x10000) {
        out.addAll([
          0xe0 | (rune >> 12),
          0x80 | ((rune >> 6) & 0x3f),
          0x80 | (rune & 0x3f),
        ]);
      } else {
        out.addAll([
          0xf0 | (rune >> 18),
          0x80 | ((rune >> 12) & 0x3f),
          0x80 | ((rune >> 6) & 0x3f),
          0x80 | (rune & 0x3f),
        ]);
      }
    }
    return out;
  }
}

/// Builds the DER of a self-signed X.509 v3 certificate for an RSA key with
/// `sha256WithRSAEncryption`, in two halves so the operating system can sign
/// between them: [tbsCertificate] then [certificate].
///
/// The result matches what the Dart identity store issues on other
/// platforms closely enough for every peer to pin and verify it: same
/// subject layout, same `extendedKeyUsage` (serverAuth, clientAuth), same
/// non-CA `basicConstraints`, and no `keyUsage` extension (BoringSSL
/// rejected a malformed one before; the pin is the trust decision anyway).
class X509SelfSignedRsa {
  const X509SelfSignedRsa._();

  static const _oidSha256WithRsa = '1.2.840.113549.1.1.11';
  static const _oidRsaEncryption = '1.2.840.113549.1.1.1';
  static const _oidCommonName = '2.5.4.3';
  static const _oidOrganization = '2.5.4.10';
  static const _oidOrganizationalUnit = '2.5.4.11';
  static const _oidBasicConstraints = '2.5.29.19';
  static const _oidExtendedKeyUsage = '2.5.29.37';
  static const _oidServerAuth = '1.3.6.1.5.5.7.3.1';
  static const _oidClientAuth = '1.3.6.1.5.5.7.3.2';

  static Uint8List _algorithmSha256WithRsa() => Asn1Der.sequence([
    Asn1Der.objectIdentifier(_oidSha256WithRsa),
    Asn1Der.nullValue(),
  ]);

  static Uint8List _name({
    required String commonName,
    required String organization,
    required String organizationalUnit,
  }) {
    Uint8List rdn(String oid, String value) => Asn1Der.set([
      Asn1Der.sequence([
        Asn1Der.objectIdentifier(oid),
        Asn1Der.utf8String(value),
      ]),
    ]);
    return Asn1Der.sequence([
      rdn(_oidCommonName, commonName),
      rdn(_oidOrganization, organization),
      rdn(_oidOrganizationalUnit, organizationalUnit),
    ]);
  }

  /// A random positive 16-byte serial number.
  static Uint8List randomSerial([Random? random]) {
    final rng = random ?? Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[0] &= 0x7f;
    if (bytes[0] == 0) bytes[0] = 1;
    return Uint8List.fromList(bytes);
  }

  /// The `TBSCertificate` to be signed. [rsaPublicKeyPkcs1Der] is the
  /// PKCS#1 `RSAPublicKey` structure (what `SecKeyCopyExternalRepresentation`
  /// returns for RSA keys).
  static Uint8List tbsCertificate({
    required String commonName,
    String organization = 'Smara',
    String organizationalUnit = 'Linked devices',
    required List<int> serialNumber,
    required DateTime notBefore,
    required DateTime notAfter,
    required List<int> rsaPublicKeyPkcs1Der,
  }) {
    final name = _name(
      commonName: commonName,
      organization: organization,
      organizationalUnit: organizationalUnit,
    );
    final subjectPublicKeyInfo = Asn1Der.sequence([
      Asn1Der.sequence([
        Asn1Der.objectIdentifier(_oidRsaEncryption),
        Asn1Der.nullValue(),
      ]),
      Asn1Der.bitString(rsaPublicKeyPkcs1Der),
    ]);
    final extensions = Asn1Der.explicit(
      3,
      Asn1Der.sequence([
        Asn1Der.sequence([
          Asn1Der.objectIdentifier(_oidBasicConstraints),
          Asn1Der.octetString(Asn1Der.sequence(const [])),
        ]),
        Asn1Der.sequence([
          Asn1Der.objectIdentifier(_oidExtendedKeyUsage),
          Asn1Der.octetString(
            Asn1Der.sequence([
              Asn1Der.objectIdentifier(_oidServerAuth),
              Asn1Der.objectIdentifier(_oidClientAuth),
            ]),
          ),
        ]),
      ]),
    );
    return Asn1Der.sequence([
      Asn1Der.explicit(0, Asn1Der.integer(2)), // v3
      Asn1Der.integerBytes(serialNumber),
      _algorithmSha256WithRsa(),
      name, // issuer == subject: self-signed
      Asn1Der.sequence([Asn1Der.time(notBefore), Asn1Der.time(notAfter)]),
      name,
      subjectPublicKeyInfo,
      extensions,
    ]);
  }

  /// The final `Certificate` from the signed [tbsDer] and its
  /// RSASSA-PKCS1-v1_5 / SHA-256 [signature].
  static Uint8List certificate({
    required List<int> tbsDer,
    required List<int> signature,
  }) {
    return Asn1Der.sequence([
      tbsDer,
      _algorithmSha256WithRsa(),
      Asn1Der.bitString(signature),
    ]);
  }

  /// PKCS#1 `RSAPublicKey` DER from a modulus and exponent (test helpers
  /// and non-Apple callers that hold the key in Dart).
  static Uint8List rsaPublicKeyPkcs1({
    required BigInt modulus,
    required BigInt exponent,
  }) {
    return Asn1Der.sequence([
      Asn1Der.bigInteger(modulus),
      Asn1Der.bigInteger(exponent),
    ]);
  }
}
