/// Fixed, predefined set of reference-exchange-rate providers the user can
/// choose between in Settings. Adding a provider means adding a case here
/// (and its request/response mapping in `ExchangeRateService`) - a product
/// change, not a user-facing option; there is no custom/free-text provider.
enum ExchangeRateProvider { frankfurter, openErApi }

/// UI label for the Settings provider dropdown.
extension ExchangeRateProviderDisplay on ExchangeRateProvider {
  String get displayName => switch (this) {
    ExchangeRateProvider.frankfurter => 'Frankfurter (ECB rates)',
    ExchangeRateProvider.openErApi => 'ExchangeRate-API (open.er-api.com)',
  };
}
