import '../models/account.dart';
import '../models/summary.dart';

/// One posting row already joined with its journal entry, account, and
/// optional verification-cache flag — input to [buildLedgerSummary] /
/// [buildCategoryTotals]. Drift mapping stays in repositories.
class SummaryPostingLine {
  const SummaryPostingLine({
    required this.entryId,
    required this.migratedFromEntryId,
    required this.isQuarantined,
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.amountMinor,
  });

  final String entryId;
  final String? migratedFromEntryId;

  /// True when a verification-cache row exists and `isVerified` is false.
  final bool isQuarantined;

  final String accountId;
  final String accountName;
  final AccountType accountType;
  final int amountMinor;
}

Set<String> _supersededEntryIds(Iterable<SummaryPostingLine> lines) => {
  for (final line in lines) ?line.migratedFromEntryId,
};

bool _includeLine(
  SummaryPostingLine line, {
  required Set<String> supersededEntryIds,
  Set<String>? entryIdsTouchingAccount,
}) {
  if (supersededEntryIds.contains(line.entryId)) return false;
  if (entryIdsTouchingAccount != null &&
      !entryIdsTouchingAccount.contains(line.entryId)) {
    return false;
  }
  if (line.isQuarantined) return false;
  return true;
}

/// Total income and expense magnitudes (positive) from [lines], applying
/// migration-supersession, quarantine, and optional account-touching
/// filter — same policy as historical `LedgerRepository.watchSummary`.
LedgerSummary buildLedgerSummary(
  List<SummaryPostingLine> lines, {
  String? financialAccountId,
}) {
  final supersededEntryIds = _supersededEntryIds(lines);
  Set<String>? entryIdsTouchingAccount;
  if (financialAccountId != null) {
    entryIdsTouchingAccount = {
      for (final line in lines)
        if (line.accountId == financialAccountId) line.entryId,
    };
  }

  var totalIncomeMinor = 0;
  var totalExpenseMinor = 0;
  for (final line in lines) {
    if (!_includeLine(
      line,
      supersededEntryIds: supersededEntryIds,
      entryIdsTouchingAccount: entryIdsTouchingAccount,
    )) {
      continue;
    }
    switch (line.accountType) {
      case AccountType.income:
        totalIncomeMinor -= line.amountMinor;
      case AccountType.expense:
        totalExpenseMinor += line.amountMinor;
      case AccountType.asset:
      case AccountType.liability:
      case AccountType.equity:
      case AccountType.clearing:
      case AccountType.inventory:
        break;
    }
  }
  return LedgerSummary(
    totalIncomeMinor: totalIncomeMinor,
    totalExpenseMinor: totalExpenseMinor,
  );
}

/// Per-category income/expense magnitudes from [lines], same exclusions
/// as [buildLedgerSummary] (without account filter). Categories with no
/// included postings are absent, not zero.
List<CategoryTotal> buildCategoryTotals(List<SummaryPostingLine> lines) {
  final supersededEntryIds = _supersededEntryIds(lines);
  final totalsById = <String, ({String name, bool isIncome, int total})>{};

  for (final line in lines) {
    if (!_includeLine(line, supersededEntryIds: supersededEntryIds)) {
      continue;
    }
    final int magnitude;
    final bool isIncome;
    switch (line.accountType) {
      case AccountType.income:
        magnitude = -line.amountMinor;
        isIncome = true;
      case AccountType.expense:
        magnitude = line.amountMinor;
        isIncome = false;
      case AccountType.asset:
      case AccountType.liability:
      case AccountType.equity:
      case AccountType.clearing:
      case AccountType.inventory:
        continue;
    }
    final existing = totalsById[line.accountId];
    totalsById[line.accountId] = (
      name: line.accountName,
      isIncome: isIncome,
      total: (existing?.total ?? 0) + magnitude,
    );
  }

  return [
    for (final entry in totalsById.entries)
      CategoryTotal(
        categoryId: entry.key,
        categoryName: entry.value.name,
        isIncome: entry.value.isIncome,
        totalMinor: entry.value.total,
      ),
  ];
}
