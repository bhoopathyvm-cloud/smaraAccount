/// A national quote source tried when the primary market-data provider
/// returns nothing for a resolved listing (instrument-identifier-assist
/// design.md Decision 5). Only the exchanges whose home listings the
/// default provider (Stooq) commonly misses declare one; the fetch itself
/// lives in `InstrumentQuoteService.fetchNationalQuote`. Adding an endpoint
/// is a code change — there is no user-supplied URL, ever.
enum NationalQuoteEndpoint { nseIndia, boerseFrankfurt }

/// One predefined stock exchange. The registry entry is the single source
/// of truth that biases Save-time resolution, supplies a resolved symbol's
/// currency, binds the national fallback endpoint, and lets a bare ticker
/// be tried as `TICKER` + [yahooSuffix] (instrument-identifier-assist
/// design.md Decision 3). It is a `const` value: extending the list is a
/// code change, matching the quote-provider and research-tool settings —
/// there is no custom-entry, endpoint URL, or API key.
class Exchange {
  const Exchange({
    required this.code,
    required this.name,
    required this.mic,
    required this.yahooSuffix,
    required this.currency,
    this.nationalEndpoint,
  });

  /// Stable identifier persisted by the Default-exchange setting. Distinct
  /// from [mic] so the combined US listing (NYSE + Nasdaq) can be one
  /// entry, and so a MIC correction never silently changes a stored value.
  final String code;

  /// Human-facing display name (a proper noun; left untranslated).
  final String name;

  /// ISO 10383 Market Identifier Code.
  final String mic;

  /// Suffix appended to a bare ticker to form the market-data symbol —
  /// e.g. `.SW` for SIX, `.L` for LSE. Empty for US listings, which Yahoo
  /// and Stooq address by the bare ticker.
  final String yahooSuffix;

  /// ISO 4217 trading currency of this exchange's listings.
  final String currency;

  /// Optional national data source tried on a primary-provider miss.
  final NationalQuoteEndpoint? nationalEndpoint;
}

/// The ~24 predefined exchanges (instrument-identifier-assist tasks.md 1.1).
/// Ordered roughly by region for the Settings dropdown.
const List<Exchange> kExchangeRegistry = [
  Exchange(
    code: 'US',
    name: 'United States (NYSE / Nasdaq)',
    mic: 'XNYS',
    yahooSuffix: '',
    currency: 'USD',
  ),
  Exchange(
    code: 'TSX',
    name: 'Toronto Stock Exchange',
    mic: 'XTSE',
    yahooSuffix: '.TO',
    currency: 'CAD',
  ),
  Exchange(
    code: 'B3',
    name: 'B3 (Brazil)',
    mic: 'BVMF',
    yahooSuffix: '.SA',
    currency: 'BRL',
  ),
  Exchange(
    code: 'LSE',
    name: 'London Stock Exchange',
    mic: 'XLON',
    yahooSuffix: '.L',
    currency: 'GBP',
  ),
  Exchange(
    code: 'SIX',
    name: 'SIX Swiss Exchange',
    mic: 'XSWX',
    yahooSuffix: '.SW',
    currency: 'CHF',
  ),
  Exchange(
    code: 'XETRA',
    name: 'Deutsche Börse Xetra',
    mic: 'XETR',
    yahooSuffix: '.DE',
    currency: 'EUR',
    nationalEndpoint: NationalQuoteEndpoint.boerseFrankfurt,
  ),
  Exchange(
    code: 'XPAR',
    name: 'Euronext Paris',
    mic: 'XPAR',
    yahooSuffix: '.PA',
    currency: 'EUR',
  ),
  Exchange(
    code: 'XAMS',
    name: 'Euronext Amsterdam',
    mic: 'XAMS',
    yahooSuffix: '.AS',
    currency: 'EUR',
  ),
  Exchange(
    code: 'XBRU',
    name: 'Euronext Brussels',
    mic: 'XBRU',
    yahooSuffix: '.BR',
    currency: 'EUR',
  ),
  Exchange(
    code: 'XLIS',
    name: 'Euronext Lisbon',
    mic: 'XLIS',
    yahooSuffix: '.LS',
    currency: 'EUR',
  ),
  Exchange(
    code: 'BIT',
    name: 'Borsa Italiana',
    mic: 'XMIL',
    yahooSuffix: '.MI',
    currency: 'EUR',
  ),
  Exchange(
    code: 'BME',
    name: 'BME (Madrid)',
    mic: 'XMAD',
    yahooSuffix: '.MC',
    currency: 'EUR',
  ),
  Exchange(
    code: 'ST',
    name: 'Nasdaq Stockholm',
    mic: 'XSTO',
    yahooSuffix: '.ST',
    currency: 'SEK',
  ),
  Exchange(
    code: 'HE',
    name: 'Nasdaq Helsinki',
    mic: 'XHEL',
    yahooSuffix: '.HE',
    currency: 'EUR',
  ),
  Exchange(
    code: 'CO',
    name: 'Nasdaq Copenhagen',
    mic: 'XCSE',
    yahooSuffix: '.CO',
    currency: 'DKK',
  ),
  Exchange(
    code: 'ASX',
    name: 'Australian Securities Exchange',
    mic: 'XASX',
    yahooSuffix: '.AX',
    currency: 'AUD',
  ),
  Exchange(
    code: 'TSE',
    name: 'Tokyo Stock Exchange',
    mic: 'XTKS',
    yahooSuffix: '.T',
    currency: 'JPY',
  ),
  Exchange(
    code: 'HKEX',
    name: 'Hong Kong Stock Exchange',
    mic: 'XHKG',
    yahooSuffix: '.HK',
    currency: 'HKD',
  ),
  Exchange(
    code: 'SGX',
    name: 'Singapore Exchange',
    mic: 'XSES',
    yahooSuffix: '.SI',
    currency: 'SGD',
  ),
  Exchange(
    code: 'NSE',
    name: 'National Stock Exchange of India',
    mic: 'XNSE',
    yahooSuffix: '.NS',
    currency: 'INR',
    nationalEndpoint: NationalQuoteEndpoint.nseIndia,
  ),
  Exchange(
    code: 'BSE',
    name: 'BSE (Bombay)',
    mic: 'XBOM',
    yahooSuffix: '.BO',
    currency: 'INR',
  ),
  Exchange(
    code: 'KRX',
    name: 'Korea Exchange',
    mic: 'XKRX',
    yahooSuffix: '.KS',
    currency: 'KRW',
  ),
  Exchange(
    code: 'JSE',
    name: 'Johannesburg Stock Exchange',
    mic: 'XJSE',
    yahooSuffix: '.JO',
    currency: 'ZAR',
  ),
  Exchange(
    code: 'TASE',
    name: 'Tel Aviv Stock Exchange',
    mic: 'XTAE',
    yahooSuffix: '.TA',
    currency: 'ILS',
  ),
];

/// The registry's fallback default, used when no region mapping and no
/// stored value apply. US is the largest market and the app's origin.
const String kDefaultExchangeCode = 'US';

/// The exchange with [code], or `null` when the code is not in the current
/// registry (e.g. a stored value from a build that has since dropped it).
Exchange? exchangeForCode(String? code) {
  if (code == null) return null;
  for (final exchange in kExchangeRegistry) {
    if (exchange.code == code) return exchange;
  }
  return null;
}

/// The exchange whose [Exchange.yahooSuffix] equals [suffix] (a non-empty
/// suffix such as `.SW`), or `null`. The empty US suffix is never matched
/// here — a bare ticker carries no exchange information.
Exchange? exchangeForYahooSuffix(String suffix) {
  if (suffix.isEmpty) return null;
  for (final exchange in kExchangeRegistry) {
    if (exchange.yahooSuffix.toUpperCase() == suffix.toUpperCase()) {
      return exchange;
    }
  }
  return null;
}

/// First-run Default-exchange from the device's ISO 3166 region (the part
/// after `_`/`-` in a locale tag, e.g. `de_CH` → `CH` → SIX). Unknown or
/// absent regions fall back to [kDefaultExchangeCode].
Exchange defaultExchangeForRegion(String? regionCode) {
  final code = _exchangeCodeByRegion[regionCode?.toUpperCase()];
  return exchangeForCode(code) ?? exchangeForCode(kDefaultExchangeCode)!;
}

/// The default exchange for a stored code, falling back to the region
/// default (then the global default) when the stored code is unknown —
/// the same "unrecognised stored value falls back" rule the rate-provider
/// setting uses.
Exchange resolveDefaultExchange({
  required String? storedCode,
  required String? regionCode,
}) {
  return exchangeForCode(storedCode) ?? defaultExchangeForRegion(regionCode);
}

const Map<String, String> _exchangeCodeByRegion = {
  'US': 'US',
  'CA': 'TSX',
  'BR': 'B3',
  'GB': 'LSE',
  'CH': 'SIX',
  'LI': 'SIX',
  'DE': 'XETRA',
  'AT': 'XETRA',
  'FR': 'XPAR',
  'NL': 'XAMS',
  'BE': 'XBRU',
  'PT': 'XLIS',
  'IT': 'BIT',
  'ES': 'BME',
  'SE': 'ST',
  'FI': 'HE',
  'DK': 'CO',
  'AU': 'ASX',
  'NZ': 'ASX',
  'JP': 'TSE',
  'HK': 'HKEX',
  'SG': 'SGX',
  'IN': 'NSE',
  'KR': 'KRX',
  'ZA': 'JSE',
  'IL': 'TASE',
};
