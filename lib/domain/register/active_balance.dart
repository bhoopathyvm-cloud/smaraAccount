import '../models/account.dart';
import '../models/journal_entry.dart';
import 'display_balance.dart';

/// Whether a journal entry contributes to display balances and home totals.
/// Quarantined (unverified) and migration-superseded entries are omitted.
bool entryCountsTowardDisplayBalance(JournalEntry entry) =>
    entry.isVerified && !entry.isSupersededByMigration;

/// Raw posting sums by account id under the display-balance exclusion
/// policy (Option A sign is applied separately via [displayBalanceDeltaFor]).
Map<String, int> rawPostingSumsByAccount(Iterable<JournalEntry> entries) {
  final sums = <String, int>{};
  for (final entry in entries) {
    if (!entryCountsTowardDisplayBalance(entry)) continue;
    for (final posting in entry.postings) {
      sums[posting.accountId] =
          (sums[posting.accountId] ?? 0) + posting.amountMinor;
    }
  }
  return sums;
}

/// Display balance for one financial account (exclusion + Option A sign).
int displayBalanceForAccount({
  required Iterable<JournalEntry> entries,
  required String accountId,
  required AccountType accountType,
}) {
  var balance = 0;
  for (final entry in entries) {
    if (!entryCountsTowardDisplayBalance(entry)) continue;
    for (final posting in entry.postings) {
      if (posting.accountId != accountId) continue;
      balance += displayBalanceDeltaFor(
        accountType: accountType,
        postingAmountMinor: posting.amountMinor,
      );
    }
  }
  return balance;
}
