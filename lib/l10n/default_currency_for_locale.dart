/// Coarse language-code -> ISO 4217 currency default, used only to seed
/// the onboarding currency screen's pre-filled value (onboarding-language-
/// selection design.md Decision 7). Language is a weak signal for
/// currency - this is a starting point, not a claim of correctness, and
/// the currency screen remains fully editable regardless of this default.
const _currencyByLanguage = <String, String>{
  // India's 22 scheduled languages this app supports all default to INR,
  // even where the language is also spoken elsewhere (Urdu, Sindhi,
  // Nepali) - consistent with why this app added them together.
  'ta': 'INR',
  'te': 'INR',
  'ml': 'INR',
  'kn': 'INR',
  'hi': 'INR',
  'ur': 'INR',
  'pa': 'INR',
  'ne': 'INR',
  'sa': 'INR',
  'doi': 'INR',
  'ks': 'INR',
  'mai': 'INR',
  'mr': 'INR',
  'gu': 'INR',
  'kok': 'INR',
  'sd': 'INR',
  'bn': 'INR',
  'as': 'INR',
  'or': 'INR',
  'mni': 'INR',
  'brx': 'INR',
  'sat': 'INR',
  // Europe (approximated to EUR for Hungary/Romania; one edit away).
  'de': 'EUR',
  'fr': 'EUR',
  'es': 'EUR',
  'it': 'EUR',
  'pt': 'EUR',
  'hu': 'EUR',
  'ro': 'EUR',
  'nl': 'EUR',
  'ja': 'JPY',
  'zh': 'CNY',
  'ko': 'KRW',
  'ar': 'SAR',
  'ru': 'RUB',
  'id': 'IDR',
  'tr': 'TRY',
  'vi': 'VND',
  'th': 'THB',
  'ms': 'MYR',
  'uk': 'UAH',
  'pl': 'PLN',
};

/// Default currency for [languageCode], or `'USD'` if the code isn't in
/// the table (including English itself).
String defaultCurrencyForLocale(String languageCode) =>
    _currencyByLanguage[languageCode] ?? 'USD';
