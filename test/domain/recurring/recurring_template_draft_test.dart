import 'package:test/test.dart';

import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/recurring/recurring_template_draft.dart';
import 'package:smara_accounting/domain/transaction/categories_for_direction.dart';

Account _account({required String id, required AccountType type}) {
  return Account(id: id, name: id, type: type, archived: false, groupId: 'g1');
}

void main() {
  group('categoriesForDirection', () {
    test('filters income vs expense by direction', () {
      final all = [
        _account(id: 'e1', type: AccountType.expense),
        _account(id: 'i1', type: AccountType.income),
      ];
      expect(
        categoriesForDirection(
          all,
          TransactionDirection.moneyOut,
        ).map((a) => a.id),
        ['e1'],
      );
      expect(
        categoriesForDirection(
          all,
          TransactionDirection.moneyIn,
        ).map((a) => a.id),
        ['i1'],
      );
    });
  });

  group('RecurringTemplateDraft', () {
    test('setDirection clears category', () {
      final draft = RecurringTemplateDraft(
        categoryId: 'e1',
        direction: TransactionDirection.moneyOut,
      );
      draft.setDirection(TransactionDirection.moneyIn);
      expect(draft.categoryId, isNull);
    });

    test(
      'canSubmit requires name, account, category, positive amount, day 1-31',
      () {
        final draft = RecurringTemplateDraft(
          name: 'Rent',
          financialAccountId: 'a1',
          categoryId: 'e1',
          amountMinor: 1000,
          dayOfMonth: 1,
        );
        expect(draft.canSubmit, isTrue);
        draft.name = '  ';
        expect(draft.canSubmit, isFalse);
        draft.name = 'Rent';
        draft.dayOfMonth = 32;
        expect(draft.canSubmit, isFalse);
        draft.dayOfMonth = 15;
        draft.amountMinor = 0;
        expect(draft.canSubmit, isFalse);
      },
    );

    test('fromTemplate prefills fields', () {
      final draft = RecurringTemplateDraft.fromTemplate(
        name: 'Salary',
        direction: TransactionDirection.moneyIn,
        financialAccountId: 'a1',
        categoryId: 'i1',
        amountMinor: 5000,
        dayOfMonth: 28,
      );
      expect(draft.name, 'Salary');
      expect(draft.direction, TransactionDirection.moneyIn);
      expect(draft.dayOfMonth, 28);
    });
  });
}
