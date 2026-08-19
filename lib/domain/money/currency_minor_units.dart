import 'package:intl/intl.dart';

/// Canonical formatting locale per currency code (localized-money-formatting
/// design.md Decision 2: format by the amount's own currency, never the
/// viewing device's locale). `intl`'s `NumberFormat.currency` sources
/// grouping and decimal-separator conventions from a *locale*, not from
/// the currency code alone - so a currency needs a locale "home" to format
/// by consistently across devices. Deliberately small: only currencies
/// with a grouping/decimal convention that actually differs from the
/// fallback need an entry; everything else uses [fallbackLocale]'s
/// Western convention (comma grouping, period decimal), which is already
/// correct for the large majority of ISO 4217 currencies.
///
/// Domain-layer (not `ui/core`) so it's usable from the data layer too -
/// `LedgerRepository.exportLedgerCsv` (ledger-data-export) needs the same
/// currency-accurate minor-unit digit count `ui/core/money_formatter.dart`
/// uses for display, without the data layer depending on `ui/core`.
const currencyLocale = {
  'INR': 'en_IN', // lakhs/crores grouping (1,00,000), not 100,000.
  'JPY': 'ja_JP',
  'EUR': 'de_DE', // period grouping, comma decimal (12.500,00).
  'GBP': 'en_GB',
  'USD': 'en_US',
  'CAD': 'en_CA',
  'AUD': 'en_AU',
};
const fallbackLocale = 'en_US';

/// The `intl` locale [currency] formats under - never the device's own
/// locale (see [currencyLocale]'s doc comment).
String localeForCurrency(String currency) =>
    currencyLocale[currency] ?? fallbackLocale;

/// [currency]'s own minor-unit digit count (2 for most currencies, 0 for
/// JPY, 3 for a few others) - `intl`'s CLDR currency data. Callers that
/// need to convert minor units to major units for anything other than
/// locale-formatted display (e.g. computing an implied exchange rate
/// between two different currencies' minor-unit amounts, or a plain
/// machine-parseable CSV export) must use this - the raw minor-unit
/// ratio between two currencies is only ever equal to the major-unit
/// ratio when both currencies share the same digit count, which is not
/// true in general (a USD/JPY pair, for instance).
int minorUnitDigitsForCurrency(String currency) {
  return NumberFormat.currency(
        locale: localeForCurrency(currency),
        name: currency,
      ).decimalDigits ??
      2;
}
