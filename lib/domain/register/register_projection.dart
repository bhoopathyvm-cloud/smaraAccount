import '../models/account.dart';
import '../models/journal_entry.dart';
import '../models/transaction_direction.dart';
import 'display_balance.dart';
import 'register_row.dart';
import 'active_balance.dart';

/// Counterpart / split labels the projection needs without depending on
/// Flutter l10n. Register UI passes [AppLocalizations]; CSV export passes
/// English strings matching the historical export file.
class RegisterProjectionLabels {
  const RegisterProjectionLabels({
    required this.openingBalance,
    required this.transferFallback,
    required this.transferToName,
    required this.splitCounterpartMore,
  });

  /// English labels used by [LedgerRepository.exportLedgerCsv] so the
  /// export file stays locale-independent.
  static const english = RegisterProjectionLabels(
    openingBalance: 'Opening balance',
    transferFallback: 'Transfer',
    transferToName: _transferToName,
    splitCounterpartMore: _splitCounterpartMore,
  );

  final String openingBalance;
  final String transferFallback;
  final String Function(String name) transferToName;
  final String Function(String firstName, int extraCount) splitCounterpartMore;

  static String _transferToName(String name) => 'Transfer: $name';
  static String _splitCounterpartMore(String firstName, int extraCount) =>
      '$firstName +$extraCount more';
}

/// One category/counterparty line for CSV. Register UI uses the summarized
/// [RegisterProjectedEntry.row] instead; export emits one CSV row per leg
/// so split amounts still sum (documented UI/export divergence).
class RegisterExportLeg {
  const RegisterExportLeg({required this.label, required this.amountMinor});

  final String label;

  /// Always a positive magnitude for this leg.
  final int amountMinor;
}

class RegisterProjectedEntry {
  const RegisterProjectedEntry({required this.row, required this.legs});

  /// Newest-first register row (running balance already accumulated
  /// oldest-to-newest, then reversed with the rest of the list).
  final RegisterRow row;

  /// CSV legs: one for an ordinary transaction, one per category line for
  /// a split. Direction/verified come from [row], not from each leg.
  final List<RegisterExportLeg> legs;
}

/// Entries + chart context → register rows (and CSV legs).
///
/// Split entries: UI summarizes as `"Food +1 more"`; export keeps one row
/// per category leg so exported amounts still sum. Both views share sign,
/// quarantine exclusion, and counterpart naming.
List<RegisterProjectedEntry> projectRegisterEntries({
  required List<JournalEntry> entries,
  required String viewedAccountId,
  required AccountType viewedAccountType,
  required String currency,
  required Map<String, Account> accountsById,
  required Map<String, Account> categoriesById,
  required String openingBalanceAccountId,
  RegisterProjectionLabels labels = RegisterProjectionLabels.english,
}) {
  var runningBalance = 0;
  final projected = <RegisterProjectedEntry>[];
  for (final entry in entries) {
    final ownPosting = entry.postings.firstWhere(
      (p) => p.accountId == viewedAccountId,
    );
    final others = entry.postings
        .where((p) => p.accountId != viewedAccountId)
        .toList();
    final counterpartIds = others.isEmpty
        ? [ownPosting.accountId]
        : others.map((p) => p.accountId).toList();

    final counterpartName = _counterpartLabel(
      counterpartIds,
      accountsById: accountsById,
      categoriesById: categoriesById,
      openingBalanceAccountId: openingBalanceAccountId,
      labels: labels,
    );
    final delta = displayBalanceDeltaFor(
      accountType: viewedAccountType,
      postingAmountMinor: ownPosting.amountMinor,
    );

    if (entryCountsTowardDisplayBalance(entry)) {
      runningBalance += delta;
    }

    final row = RegisterRow(
      entryId: entry.id,
      categoryName: counterpartName,
      counterpartAccountIds: counterpartIds,
      currency: currency,
      direction: delta >= 0
          ? TransactionDirection.moneyIn
          : TransactionDirection.moneyOut,
      amountMinor: delta.abs(),
      transactionDate: entry.transactionDate,
      description: entry.description,
      runningBalanceMinor: runningBalance,
      isReversal: entry.reversesEntryId != null,
      isVerified: entry.isVerified,
      breakReason: entry.breakReason,
      isSupersededByMigration: entry.isSupersededByMigration,
    );

    final sourceLegs = others.isEmpty ? [ownPosting] : others;
    final legs = [
      for (final leg in sourceLegs)
        RegisterExportLeg(
          label: leg.accountId == viewedAccountId
              ? counterpartName
              : _singleCounterpartLabel(
                  leg.accountId,
                  accountsById: accountsById,
                  categoriesById: categoriesById,
                  openingBalanceAccountId: openingBalanceAccountId,
                  labels: labels,
                ),
          amountMinor: leg.amountMinor.abs(),
        ),
    ];

    projected.add(RegisterProjectedEntry(row: row, legs: legs));
  }
  return projected.reversed.toList();
}

/// Newest-first [RegisterRow] list for the Register UI.
List<RegisterRow> projectRegisterRows({
  required List<JournalEntry> entries,
  required String viewedAccountId,
  required AccountType viewedAccountType,
  required String currency,
  required Map<String, Account> accountsById,
  required Map<String, Account> categoriesById,
  required String openingBalanceAccountId,
  RegisterProjectionLabels labels = RegisterProjectionLabels.english,
}) {
  return projectRegisterEntries(
    entries: entries,
    viewedAccountId: viewedAccountId,
    viewedAccountType: viewedAccountType,
    currency: currency,
    accountsById: accountsById,
    categoriesById: categoriesById,
    openingBalanceAccountId: openingBalanceAccountId,
    labels: labels,
  ).map((e) => e.row).toList();
}

String _counterpartLabel(
  List<String> accountIds, {
  required Map<String, Account> accountsById,
  required Map<String, Account> categoriesById,
  required String openingBalanceAccountId,
  required RegisterProjectionLabels labels,
}) {
  final names = [
    for (final id in accountIds)
      _singleCounterpartLabel(
        id,
        accountsById: accountsById,
        categoriesById: categoriesById,
        openingBalanceAccountId: openingBalanceAccountId,
        labels: labels,
      ),
  ];
  if (names.length <= 1) {
    return names.isEmpty ? labels.transferFallback : names.first;
  }
  return labels.splitCounterpartMore(names.first, names.length - 1);
}

String _singleCounterpartLabel(
  String accountId, {
  required Map<String, Account> accountsById,
  required Map<String, Account> categoriesById,
  required String openingBalanceAccountId,
  required RegisterProjectionLabels labels,
}) {
  if (accountId == openingBalanceAccountId) {
    return labels.openingBalance;
  }
  final category = categoriesById[accountId];
  if (category != null) return category.name;
  final other = accountsById[accountId];
  if (other != null) {
    return labels.transferToName(other.name);
  }
  return labels.transferFallback;
}
