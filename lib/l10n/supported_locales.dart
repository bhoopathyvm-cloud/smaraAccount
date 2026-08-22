import 'package:flutter/widgets.dart';

/// BCP-47 language tags registered in this build. Locale-pack changes append
/// here and add matching ARB files; do not invent tags that have no ARB.
const kSupportedLocaleTags = <String>[
  'en',
  'ta',
  'te',
  'ml',
  'kn',
  'hi',
  'ur',
  'pa',
  'ne',
  'sa',
  'doi',
  'ks',
  'mai',
  'mr',
  'gu',
  'kok',
  'sd',
  'bn',
  'as',
  'or',
  'mni',
  'brx',
  'sat',
  'de',
  'fr',
  'es',
  'it',
  'pt',
  'hu',
  'ro',
  'ja',
  'zh',
  'ko',
  'ar',
  'ru',
  'id',
  'tr',
  'vi',
  'th',
  'ms',
  'uk',
  'pl',
  'nl',
];

/// Sentinel stored in preferences when the user wants the device locale
/// (falling back to English if the device locale is not supported).
const kSystemLocalePreference = 'system';

Locale localeFromTag(String tag) {
  final parts = tag.split(RegExp('[-_]'));
  if (parts.length == 1) return Locale(parts[0]);
  if (parts.length == 2) return Locale(parts[0], parts[1]);
  return Locale.fromSubtags(
    languageCode: parts[0],
    scriptCode: parts.length > 2 ? parts[1] : null,
    countryCode: parts.length > 2 ? parts[2] : parts[1],
  );
}

String tagFromLocale(Locale locale) {
  final script = locale.scriptCode;
  final country = locale.countryCode;
  if (script != null &&
      script.isNotEmpty &&
      country != null &&
      country.isNotEmpty) {
    return '${locale.languageCode}-$script-$country';
  }
  if (country != null && country.isNotEmpty) {
    return '${locale.languageCode}-$country';
  }
  return locale.languageCode;
}

bool isSupportedLocaleTag(String tag) {
  final normalized = tag.replaceAll('_', '-').toLowerCase();
  return kSupportedLocaleTags.any(
    (supported) => supported.toLowerCase() == normalized,
  );
}

/// Picks a supported locale from [device], or English.
Locale resolveSupportedLocale(Locale? device) {
  if (device == null) return const Locale('en');
  final exact = tagFromLocale(device);
  if (isSupportedLocaleTag(exact)) return localeFromTag(exact);
  if (isSupportedLocaleTag(device.languageCode)) {
    return localeFromTag(device.languageCode);
  }
  return const Locale('en');
}
