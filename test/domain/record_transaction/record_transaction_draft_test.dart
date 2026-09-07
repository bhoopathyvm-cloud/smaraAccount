import 'package:test/test.dart';

import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/payee.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/record_transaction/record_transaction_draft.dart';

Account _account({
  required String id,
  required AccountType type,
  bool isCreditCard = false,
}) {
  return Account(
    id: id,
    name: id,
    type: type,
    archived: false,
    groupId: 'g1',
    isCreditCard: isCreditCard,
  );
}

void main() {
  group('RecordTransactionDraft', () {
    test('splitRemainderMinor is total minus allocated lines', () {
      final draft = RecordTransactionDraft()..amountMinor = 1000;
      draft.startSplitting();
      draft.setSplitLineAmount(0, 400);
      draft.setSplitLineAmount(1, 600);
      expect(draft.splitRemainderMinor, 0);
      draft.setSplitLineAmount(1, 500);
      expect(draft.splitRemainderMinor, 100);
    });

    test('startSplitting is a no-op when already splitting', () {
      final draft = RecordTransactionDraft()..categoryId = 'c1';
      draft.startSplitting();
      expect(draft.splitLines, hasLength(2));
      draft.startSplitting();
      expect(draft.splitLines, hasLength(2));
    });

    test('removeSplitLine collapses to single when one line remains', () {
      final draft = RecordTransactionDraft()..categoryId = 'c1';
      draft.startSplitting();
      draft.setSplitLineCategory(0, 'c1');
      draft.setSplitLineCategory(1, 'c2');
      draft.removeSplitLine(1);
      expect(draft.isSplitting, isFalse);
      expect(draft.categoryId, 'c1');
    });

    test('isForeignCurrency when native differs from account currency', () {
      final draft = RecordTransactionDraft()
        ..accountCurrency = 'USD'
        ..setNativeCurrency('EUR');
      expect(draft.isForeignCurrency, isTrue);
      draft.setNativeCurrency('USD');
      expect(draft.isForeignCurrency, isFalse);
      draft.setNativeCurrency(null);
      expect(draft.isForeignCurrency, isFalse);
    });

    test('paid-from-card narrows financialAccountOptions to cards', () {
      final draft = RecordTransactionDraft()
        ..financialAccounts = [
          _account(id: 'card', type: AccountType.liability, isCreditCard: true),
          _account(id: 'bank', type: AccountType.asset),
        ]
        ..financialAccountId = 'bank';
      draft.selectPaidFromCard();
      expect(draft.financialAccountOptions.map((a) => a.id), ['card']);
      expect(draft.financialAccountId, 'card');
    });

    test('paid-from-bank narrows to non-cards', () {
      final draft = RecordTransactionDraft()
        ..financialAccounts = [
          _account(id: 'card', type: AccountType.liability, isCreditCard: true),
          _account(id: 'bank', type: AccountType.asset),
        ]
        ..financialAccountId = 'card';
      draft.selectPaidFromBank();
      expect(draft.financialAccountOptions.map((a) => a.id), ['bank']);
      expect(draft.financialAccountId, 'bank');
    });

    test('setDirection clears split categories and paid-from shortcuts', () {
      final draft = RecordTransactionDraft()
        ..categoryId = 'c1'
        ..financialAccounts = [
          _account(id: 'card', type: AccountType.liability, isCreditCard: true),
        ];
      draft.startSplitting();
      draft.setSplitLineCategory(0, 'c1');
      draft.selectPaidFromCard();
      draft.setDirection(TransactionDirection.moneyOut);
      expect(draft.splitLines.every((l) => l.categoryId == null), isTrue);
      expect(draft.paidFromCard, isFalse);
      expect(draft.paidFromBank, isFalse);
    });

    test('categories filter by direction', () {
      final draft =
          RecordTransactionDraft(direction: TransactionDirection.moneyIn)
            ..allCategories = [
              _account(id: 'inc', type: AccountType.income),
              _account(id: 'exp', type: AccountType.expense),
            ];
      expect(draft.categories.map((a) => a.id), ['inc']);
      draft.setDirection(TransactionDirection.moneyOut);
      expect(draft.categories.map((a) => a.id), ['exp']);
    });

    test('canSubmitSingle requires amount, account, category', () {
      final draft = RecordTransactionDraft();
      expect(draft.canSubmitSingle, isFalse);
      draft
        ..amountMinor = 100
        ..financialAccountId = 'a1'
        ..categoryId = 'c1';
      expect(draft.canSubmitSingle, isTrue);
    });

    test('canSubmitSplit requires complete lines and zero remainder', () {
      final draft = RecordTransactionDraft()
        ..amountMinor = 100
        ..financialAccountId = 'a1';
      draft.startSplitting();
      expect(draft.canSubmitSplit, isFalse);
      draft.setSplitLineCategory(0, 'c1');
      draft.setSplitLineAmount(0, 40);
      draft.setSplitLineCategory(1, 'c2');
      draft.setSplitLineAmount(1, 60);
      expect(draft.canSubmitSplit, isTrue);
      draft.setSplitLineAmount(1, 50);
      expect(draft.canSubmitSplit, isFalse);
    });

    test('payeeSuggestions matches normalized substring', () {
      final draft = RecordTransactionDraft()
        ..payees = [
          Payee(
            id: 'p1',
            name: 'Starbucks',
            defaultCategoryId: null,
            defaultFinancialAccountId: null,
          ),
        ];
      expect(draft.payeeSuggestions('star').map((p) => p.id), ['p1']);
      expect(draft.payeeSuggestions(''), isEmpty);
    });
  });
}
