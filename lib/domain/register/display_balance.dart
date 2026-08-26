import '../models/account.dart';

/// Display-balance contribution of one posting on a financial account.
/// Asset: raw amount. Liability owed: negated amount (Option A).
int displayBalanceDeltaFor({
  required AccountType accountType,
  required int postingAmountMinor,
}) {
  return switch (accountType) {
    AccountType.asset => postingAmountMinor,
    AccountType.liability => -postingAmountMinor,
    AccountType.equity ||
    AccountType.clearing ||
    AccountType.inventory ||
    AccountType.income ||
    AccountType.expense => 0,
  };
}
