import 'package:test/test.dart';

import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/summary/ledger_summary_engine.dart';

SummaryPostingLine _line({
  required String entryId,
  String? migratedFromEntryId,
  bool isQuarantined = false,
  required String accountId,
  String accountName = 'Cat',
  required AccountType accountType,
  required int amountMinor,
}) {
  return SummaryPostingLine(
    entryId: entryId,
    migratedFromEntryId: migratedFromEntryId,
    isQuarantined: isQuarantined,
    accountId: accountId,
    accountName: accountName,
    accountType: accountType,
    amountMinor: amountMinor,
  );
}

void main() {
  group('buildLedgerSummary', () {
    test('sums income and expense magnitudes', () {
      final summary = buildLedgerSummary([
        _line(
          entryId: 'e1',
          accountId: 'inc',
          accountType: AccountType.income,
          amountMinor: -5000,
        ),
        _line(
          entryId: 'e2',
          accountId: 'exp',
          accountType: AccountType.expense,
          amountMinor: 2000,
        ),
        _line(
          entryId: 'e2',
          accountId: 'asset',
          accountType: AccountType.asset,
          amountMinor: -2000,
        ),
      ]);
      expect(summary.totalIncomeMinor, 5000);
      expect(summary.totalExpenseMinor, 2000);
    });

    test('skips quarantined and superseded entries', () {
      final summary = buildLedgerSummary([
        _line(
          entryId: 'old',
          accountId: 'inc',
          accountType: AccountType.income,
          amountMinor: -1000,
        ),
        _line(
          entryId: 'new',
          migratedFromEntryId: 'old',
          accountId: 'inc',
          accountType: AccountType.income,
          amountMinor: -1000,
        ),
        _line(
          entryId: 'q',
          isQuarantined: true,
          accountId: 'exp',
          accountType: AccountType.expense,
          amountMinor: 999,
        ),
      ]);
      expect(summary.totalIncomeMinor, 1000);
      expect(summary.totalExpenseMinor, 0);
    });

    test('account filter includes whole entry when any posting touches it', () {
      final summary = buildLedgerSummary([
        _line(
          entryId: 'e1',
          accountId: 'asset-1',
          accountType: AccountType.asset,
          amountMinor: 5000,
        ),
        _line(
          entryId: 'e1',
          accountId: 'inc',
          accountType: AccountType.income,
          amountMinor: -5000,
        ),
        _line(
          entryId: 'e2',
          accountId: 'exp',
          accountType: AccountType.expense,
          amountMinor: 100,
        ),
      ], financialAccountId: 'asset-1');
      expect(summary.totalIncomeMinor, 5000);
      expect(summary.totalExpenseMinor, 0);
    });
  });

  group('buildCategoryTotals', () {
    test('groups by category and omits empty categories', () {
      final totals = buildCategoryTotals([
        _line(
          entryId: 'e1',
          accountId: 'exp',
          accountName: 'Groceries',
          accountType: AccountType.expense,
          amountMinor: 300,
        ),
        _line(
          entryId: 'e2',
          accountId: 'exp',
          accountName: 'Groceries',
          accountType: AccountType.expense,
          amountMinor: 200,
        ),
      ]);
      expect(totals, hasLength(1));
      expect(totals.single.categoryId, 'exp');
      expect(totals.single.totalMinor, 500);
      expect(totals.single.isIncome, isFalse);
    });
  });
}
