/// Snapshot of financial-account id → that account's group ISO 4217
/// currency. Built by [AccountRepository.watchAccountCurrencies] so
/// feature view models do not join account and group streams themselves
/// (account-group-currency-lookup).
class AccountCurrencyCatalog {
  const AccountCurrencyCatalog(this._byAccountId);

  static const empty = AccountCurrencyCatalog({});

  final Map<String, String> _byAccountId;

  /// The group's currency for [accountId], or null when the account is
  /// unknown, has no group, or the group has no currency yet.
  String? currencyFor(String? accountId) {
    if (accountId == null) return null;
    return _byAccountId[accountId];
  }
}
