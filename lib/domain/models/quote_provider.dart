/// Fixed, predefined set of instrument quote providers. Adding a provider
/// is a code change (same rule as [ExchangeRateProvider]) — no custom URL.
enum QuoteProvider { stooq, yahooFinance }

extension QuoteProviderDisplay on QuoteProvider {
  String get displayName => switch (this) {
    QuoteProvider.stooq => 'Stooq (daily quotes)',
    QuoteProvider.yahooFinance => 'Yahoo Finance (chart API)',
  };
}
