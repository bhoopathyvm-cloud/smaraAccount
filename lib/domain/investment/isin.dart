/// Outcome of validating an ISIN entered on the Add-instrument form
/// (instrument-identifier-assist design.md Decision 2). Ordered by
/// severity: [valid] shows nothing, [badCheckDigit] warns but allows save,
/// [malformed] blocks save.
enum IsinCheck {
  /// 12 chars, legal alphabet, recognised country prefix, check digit OK.
  valid,

  /// Structurally a plausible ISIN (12 legal chars, known country) but the
  /// mod-10 check digit does not verify — always a typo, so warn.
  badCheckDigit,

  /// Not 12 characters, contains a character outside `A–Z`/`0–9`, or a
  /// first-two-character prefix that is not a known country/supranational
  /// code. Provably not an ISIN, so block saving.
  malformed,
}

/// Validates [raw] locally — no network. Blank input is treated as [valid]
/// (the ISIN field is optional; "no ISIN" is not an error).
IsinCheck validateIsin(String? raw) {
  final isin = raw?.trim().toUpperCase() ?? '';
  if (isin.isEmpty) return IsinCheck.valid;
  if (isin.length != 12) return IsinCheck.malformed;
  if (!_isinAlphabet.hasMatch(isin)) return IsinCheck.malformed;
  final prefix = isin.substring(0, 2);
  if (!_knownIsinPrefixes.contains(prefix)) return IsinCheck.malformed;
  if (!_checkDigitVerifies(isin)) return IsinCheck.badCheckDigit;
  return IsinCheck.valid;
}

/// The two-letter country/supranational prefix of [raw], or null when it is
/// too short. Does not validate the rest of the ISIN.
String? isinCountryCode(String? raw) {
  final isin = raw?.trim().toUpperCase() ?? '';
  if (isin.length < 2) return null;
  return isin.substring(0, 2);
}

/// The trading currency implied by [raw]'s country prefix, or null when the
/// ISIN is absent or its country has no mapping here. A heuristic: the ISIN
/// country is the security's registration home, which for the common cases
/// coincides with its primary listing currency.
String? currencyForIsin(String? raw) {
  final country = isinCountryCode(raw);
  if (country == null) return null;
  return _currencyByCountry[country];
}

final RegExp _isinAlphabet = RegExp(r'^[A-Z0-9]{12}$');

/// Luhn mod-10 over the letter-expanded ISIN (A→10 … Z→35), the standard
/// ISIN check-digit algorithm. Deterministic: a failure is always a typo,
/// never a false positive.
bool _checkDigitVerifies(String isin) {
  final digits = StringBuffer();
  for (final unit in isin.codeUnits) {
    if (unit >= 0x30 && unit <= 0x39) {
      digits.writeCharCode(unit);
    } else {
      digits.write((unit - 0x41 + 10).toString());
    }
  }
  final expanded = digits.toString();
  var sum = 0;
  var double = expanded.length.isEven;
  for (var i = 0; i < expanded.length; i++) {
    var value = expanded.codeUnitAt(i) - 0x30;
    if (double) {
      value *= 2;
      if (value > 9) value -= 9;
    }
    sum += value;
    double = !double;
  }
  return sum % 10 == 0;
}

/// ISO 3166-1 alpha-2 codes plus the supranational `XS` (Eurobonds/
/// international) prefix ISINs may legitimately use.
const Set<String> _knownIsinPrefixes = {
  'AD', 'AE', 'AF', 'AG', 'AI', 'AL', 'AM', 'AO', 'AQ', 'AR', 'AS', 'AT',
  'AU', 'AW', 'AX', 'AZ', 'BA', 'BB', 'BD', 'BE', 'BF', 'BG', 'BH', 'BI',
  'BJ', 'BL', 'BM', 'BN', 'BO', 'BQ', 'BR', 'BS', 'BT', 'BV', 'BW', 'BY',
  'BZ', 'CA', 'CC', 'CD', 'CF', 'CG', 'CH', 'CI', 'CK', 'CL', 'CM', 'CN',
  'CO', 'CR', 'CU', 'CV', 'CW', 'CX', 'CY', 'CZ', 'DE', 'DJ', 'DK', 'DM',
  'DO', 'DZ', 'EC', 'EE', 'EG', 'EH', 'ER', 'ES', 'ET', 'FI', 'FJ', 'FK',
  'FM', 'FO', 'FR', 'GA', 'GB', 'GD', 'GE', 'GF', 'GG', 'GH', 'GI', 'GL',
  'GM', 'GN', 'GP', 'GQ', 'GR', 'GS', 'GT', 'GU', 'GW', 'GY', 'HK', 'HM',
  'HN', 'HR', 'HT', 'HU', 'ID', 'IE', 'IL', 'IM', 'IN', 'IO', 'IQ', 'IR',
  'IS', 'IT', 'JE', 'JM', 'JO', 'JP', 'KE', 'KG', 'KH', 'KI', 'KM', 'KN',
  'KP', 'KR', 'KW', 'KY', 'KZ', 'LA', 'LB', 'LC', 'LI', 'LK', 'LR', 'LS',
  'LT', 'LU', 'LV', 'LY', 'MA', 'MC', 'MD', 'ME', 'MF', 'MG', 'MH', 'MK',
  'ML', 'MM', 'MN', 'MO', 'MP', 'MQ', 'MR', 'MS', 'MT', 'MU', 'MV', 'MW',
  'MX', 'MY', 'MZ', 'NA', 'NC', 'NE', 'NF', 'NG', 'NI', 'NL', 'NO', 'NP',
  'NR', 'NU', 'NZ', 'OM', 'PA', 'PE', 'PF', 'PG', 'PH', 'PK', 'PL', 'PM',
  'PN', 'PR', 'PS', 'PT', 'PW', 'PY', 'QA', 'RE', 'RO', 'RS', 'RU', 'RW',
  'SA', 'SB', 'SC', 'SD', 'SE', 'SG', 'SH', 'SI', 'SJ', 'SK', 'SL', 'SM',
  'SN', 'SO', 'SR', 'SS', 'ST', 'SV', 'SX', 'SY', 'SZ', 'TC', 'TD', 'TF',
  'TG', 'TH', 'TJ', 'TK', 'TL', 'TM', 'TN', 'TO', 'TR', 'TT', 'TV', 'TW',
  'TZ', 'UA', 'UG', 'UM', 'US', 'UY', 'UZ', 'VA', 'VC', 'VE', 'VG', 'VI',
  'VN', 'VU', 'WF', 'WS', 'YE', 'YT', 'ZA', 'ZM', 'ZW',
  'XS',
};

/// Country → primary listing currency for the cases the app can quote. Kept
/// small and aligned with [kExchangeRegistry]; unknown countries return
/// null (no currency inferred from the ISIN alone).
const Map<String, String> _currencyByCountry = {
  'US': 'USD',
  'CA': 'CAD',
  'BR': 'BRL',
  'GB': 'GBP',
  'CH': 'CHF',
  'LI': 'CHF',
  'DE': 'EUR',
  'AT': 'EUR',
  'FR': 'EUR',
  'NL': 'EUR',
  'BE': 'EUR',
  'PT': 'EUR',
  'IT': 'EUR',
  'ES': 'EUR',
  'IE': 'EUR',
  'LU': 'EUR',
  'FI': 'EUR',
  'SE': 'SEK',
  'DK': 'DKK',
  'NO': 'NOK',
  'AU': 'AUD',
  'NZ': 'NZD',
  'JP': 'JPY',
  'HK': 'HKD',
  'SG': 'SGD',
  'IN': 'INR',
  'KR': 'KRW',
  'ZA': 'ZAR',
  'IL': 'ILS',
};
