/// Coarse language -> ISO 4217 currency lookup used *only* to pre-fill the
/// first-launch currency screen from the language the user just chose
/// (onboarding-language-selection design.md Decision 7). Language is a weak
/// signal for currency, so this is a starting point, never a restriction: the
/// currency screen's quick-pick chips and free-text field stay fully editable,
/// and this lookup is not re-applied when the language is later changed in
/// Settings.
///
/// Any code not in the table falls back to USD.
const _currencyByLanguageCode = <String, String>{
  'en': 'USD',
  // All 22 of India's scheduled languages this app ships (locales-indian-*)
  // default to India's currency, even where the language is also spoken
  // elsewhere - consistent with why the app added them together.
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
  // Euro-area approximation; Hungary (HUF) and Romania (RON) accepted as
  // one-tap-away defaults for simplicity, not exactness.
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
  // One representative economy each for pan-regional languages; cannot be
  // exact and disclosed as such in the design.
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

/// The currency code to pre-fill for [languageCode] on the first-launch
/// currency screen, or `'USD'` for any language not in the table.
String defaultCurrencyForLocale(String languageCode) {
  return _currencyByLanguageCode[languageCode] ?? 'USD';
}
