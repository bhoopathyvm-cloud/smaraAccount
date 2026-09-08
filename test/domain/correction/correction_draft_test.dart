import 'package:test/test.dart';

import 'package:smara_accounting/domain/correction/correction_draft.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';

Account _account({required String id, required AccountType type}) {
  return Account(id: id, name: id, type: type, archived: false, groupId: 'g1');
}

CorrectionDraft _draft({
  TransactionDirection direction = TransactionDirection.moneyOut,
  String categoryId = 'expense-1',
}) {
  return CorrectionDraft(
    amountMinor: 4500,
    direction: direction,
    categoryId: categoryId,
    financialAccountId: 'asset-1',
    transactionDate: DateTime(2026, 1, 17),
    description: 'Corner store',
  );
}

void main() {
  group('CorrectionDraft', () {
    test('categories filters by direction', () {
      final draft = _draft()
        ..allCategories = [
          _account(id: 'expense-1', type: AccountType.expense),
          _account(id: 'income-1', type: AccountType.income),
        ];
      expect(draft.categories.map((a) => a.id), ['expense-1']);
      draft.setDirection(TransactionDirection.moneyIn);
      expect(draft.categories.map((a) => a.id), ['income-1']);
    });

    test('setDirection clears category when direction changes', () {
      final draft = _draft();
      draft.setDirection(TransactionDirection.moneyIn);
      expect(draft.categoryId, isNull);
    });

    test('setDirection is a no-op when direction is unchanged', () {
      final draft = _draft();
      draft.setDirection(TransactionDirection.moneyOut);
      expect(draft.categoryId, 'expense-1');
    });

    test('canSubmit requires category and financial account', () {
      final draft = _draft();
      expect(draft.canSubmit, isTrue);
      draft.setCategoryId(null);
      expect(draft.canSubmit, isFalse);
      draft.setCategoryId('expense-1');
      draft.setFinancialAccountId(null);
      expect(draft.canSubmit, isFalse);
    });

    test('setAmountMinor ignores null', () {
      final draft = _draft();
      draft.setAmountMinor(null);
      expect(draft.amountMinor, 4500);
      draft.setAmountMinor(5000);
      expect(draft.amountMinor, 5000);
    });
  });
}
