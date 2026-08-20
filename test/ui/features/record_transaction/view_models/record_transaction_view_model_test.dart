import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/payee.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/record_transaction/view_models/record_transaction_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late RecordTransactionViewModel viewModel;

  setUp(() {
    repository = MockLedgerRepository();
    viewModel = RecordTransactionViewModel(ledgerRepository: repository);
  });

  test(
    'categories reflects the currently selected direction, active only',
    () async {
      final withCategories = MockLedgerRepository();
      when(withCategories.watchCategories()).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'income-1',
            name: 'Salary',
            type: AccountType.income,
            archived: false,
          ),
          Account(
            id: 'expense-1',
            name: 'Groceries',
            type: AccountType.expense,
            archived: false,
          ),
        ]),
      );
      final categorizedViewModel = RecordTransactionViewModel(
        ledgerRepository: withCategories,
      );
      addTearDown(categorizedViewModel.dispose);
      // Stream.value(...) emits asynchronously (via a microtask), not
      // synchronously on listen - let it deliver before asserting.
      await Future<void>.delayed(Duration.zero);

      expect(categorizedViewModel.direction, TransactionDirection.moneyIn);
      expect(categorizedViewModel.categories.map((c) => c.id), ['income-1']);

      categorizedViewModel.setDirection(TransactionDirection.moneyOut);
      expect(categorizedViewModel.categories.map((c) => c.id), ['expense-1']);
    },
  );

  test('defaults direction to moneyIn, but honors an explicit initialDirection '
      '(home-hub-capture: Spent/Received pre-selected from the Add sheet)', () {
    expect(viewModel.direction, equals(TransactionDirection.moneyIn));

    final spentViewModel = RecordTransactionViewModel(
      ledgerRepository: repository,
      initialDirection: TransactionDirection.moneyOut,
    );
    addTearDown(spentViewModel.dispose);
    expect(spentViewModel.direction, equals(TransactionDirection.moneyOut));
  });

  test('setters update exposed state', () {
    viewModel.setAmountMinor(500);
    viewModel.setDirection(TransactionDirection.moneyOut);
    viewModel.setCategoryId('cat-1');
    viewModel.setDescription('lunch');
    final date = DateTime(2026, 3, 1);
    viewModel.setTransactionDate(date);

    expect(viewModel.amountMinor, equals(500));
    expect(viewModel.direction, equals(TransactionDirection.moneyOut));
    expect(viewModel.categoryId, equals('cat-1'));
    expect(viewModel.description, equals('lunch'));
    expect(viewModel.transactionDate, equals(date));
  });

  test(
    'submit fails with an errorMessage when amount or category missing',
    () async {
      viewModel.setCategoryId(null);
      viewModel.setAmountMinor(null);

      final result = await viewModel.submit();

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      verifyNever(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      );
    },
  );

  test('submit calls recordTransaction and returns true on success', () async {
    viewModel.setAmountMinor(1000);
    viewModel.setCategoryId('cat-1');
    viewModel.setFinancialAccountId('account-1');
    when(
      repository.recordTransaction(
        amountMinor: anyNamed('amountMinor'),
        direction: anyNamed('direction'),
        categoryId: anyNamed('categoryId'),
        financialAccountId: anyNamed('financialAccountId'),
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
      ),
    ).thenAnswer((_) async => 'entry-1');

    final result = await viewModel.submit();

    expect(result, isTrue);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isSubmitting, isFalse);
  });

  group('payees-and-spending-memory', () {
    const starbucks = Payee(
      id: 'payee-1',
      name: 'Starbucks',
      defaultCategoryId: 'cat-groceries',
      defaultFinancialAccountId: 'account-checking',
    );

    Future<
      ({RecordTransactionViewModel viewModel, MockLedgerRepository repository})
    >
    viewModelWithPayees() async {
      final withPayees = MockLedgerRepository();
      when(
        withPayees.watchFinancialAccounts(),
      ).thenAnswer((_) => Stream.value(const []));
      when(
        withPayees.watchAccountGroups(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value(const []));
      when(
        withPayees.watchCategories(),
      ).thenAnswer((_) => Stream.value(const []));
      when(
        withPayees.watchPayees(),
      ).thenAnswer((_) => Stream.value(const [starbucks]));
      final vm = RecordTransactionViewModel(ledgerRepository: withPayees);
      await Future<void>.delayed(Duration.zero);
      return (viewModel: vm, repository: withPayees);
    }

    test('payeeSuggestions matches by normalized substring, empty query '
        'yields no suggestions', () async {
      final (:viewModel, :repository) = await viewModelWithPayees();
      addTearDown(viewModel.dispose);

      expect(viewModel.payeeSuggestions('star').map((p) => p.id), ['payee-1']);
      expect(viewModel.payeeSuggestions('STAR').map((p) => p.id), ['payee-1']);
      expect(viewModel.payeeSuggestions('nomatch'), isEmpty);
      expect(viewModel.payeeSuggestions(''), isEmpty);
    });

    test(
      'selectPayee applies defaults, always overridable afterward',
      () async {
        final (:viewModel, :repository) = await viewModelWithPayees();
        addTearDown(viewModel.dispose);

        viewModel.selectPayee(starbucks);
        expect(viewModel.description, equals('Starbucks'));
        expect(viewModel.categoryId, equals('cat-groceries'));
        expect(viewModel.financialAccountId, equals('account-checking'));

        // Overridable: a subsequent explicit choice wins.
        viewModel.setCategoryId('cat-other');
        expect(viewModel.categoryId, equals('cat-other'));
      },
    );

    test(
      'submit records payee usage for an explicitly selected payee',
      () async {
        final (:viewModel, :repository) = await viewModelWithPayees();
        addTearDown(viewModel.dispose);
        viewModel.selectPayee(starbucks);
        viewModel.setAmountMinor(500);
        viewModel.setFinancialAccountId('account-1');
        viewModel.setCategoryId('cat-1');

        when(
          repository.recordTransaction(
            amountMinor: anyNamed('amountMinor'),
            direction: anyNamed('direction'),
            categoryId: anyNamed('categoryId'),
            financialAccountId: anyNamed('financialAccountId'),
            transactionDate: anyNamed('transactionDate'),
            description: anyNamed('description'),
          ),
        ).thenAnswer((_) async => 'entry-1');

        final result = await viewModel.submit();

        expect(result, isTrue);
        verify(
          repository.recordPayeeUsage(
            payeeId: 'payee-1',
            categoryId: 'cat-1',
            financialAccountId: 'account-1',
          ),
        ).called(1);
      },
    );

    test(
      'submit records payee usage when the typed description exactly '
      'matches an existing payee, even without an explicit selection',
      () async {
        final (:viewModel, :repository) = await viewModelWithPayees();
        addTearDown(viewModel.dispose);
        viewModel.setDescription('starbucks');
        viewModel.setAmountMinor(500);
        viewModel.setFinancialAccountId('account-1');
        viewModel.setCategoryId('cat-1');

        when(
          repository.recordTransaction(
            amountMinor: anyNamed('amountMinor'),
            direction: anyNamed('direction'),
            categoryId: anyNamed('categoryId'),
            financialAccountId: anyNamed('financialAccountId'),
            transactionDate: anyNamed('transactionDate'),
            description: anyNamed('description'),
          ),
        ).thenAnswer((_) async => 'entry-1');

        await viewModel.submit();

        verify(
          repository.recordPayeeUsage(
            payeeId: 'payee-1',
            categoryId: 'cat-1',
            financialAccountId: 'account-1',
          ),
        ).called(1);
      },
    );

    test(
      'submit records no payee usage when the description matches nothing',
      () async {
        final (:viewModel, :repository) = await viewModelWithPayees();
        addTearDown(viewModel.dispose);
        viewModel.setDescription('unrelated text');
        viewModel.setAmountMinor(500);
        viewModel.setFinancialAccountId('account-1');
        viewModel.setCategoryId('cat-1');

        when(
          repository.recordTransaction(
            amountMinor: anyNamed('amountMinor'),
            direction: anyNamed('direction'),
            categoryId: anyNamed('categoryId'),
            financialAccountId: anyNamed('financialAccountId'),
            transactionDate: anyNamed('transactionDate'),
            description: anyNamed('description'),
          ),
        ).thenAnswer((_) async => 'entry-1');

        await viewModel.submit();

        verifyNever(
          repository.recordPayeeUsage(
            payeeId: anyNamed('payeeId'),
            categoryId: anyNamed('categoryId'),
            financialAccountId: anyNamed('financialAccountId'),
          ),
        );
      },
    );

    test('editing the description away from a selected payee clears the '
        'selection, so submit records no usage for it', () async {
      final (:viewModel, :repository) = await viewModelWithPayees();
      addTearDown(viewModel.dispose);
      viewModel.selectPayee(starbucks);
      viewModel.setDescription('something else entirely');
      viewModel.setAmountMinor(500);
      viewModel.setFinancialAccountId('account-1');
      viewModel.setCategoryId('cat-1');

      when(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).thenAnswer((_) async => 'entry-1');

      await viewModel.submit();

      verifyNever(
        repository.recordPayeeUsage(
          payeeId: anyNamed('payeeId'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
        ),
      );
    });
  });

  test(
    'submit surfaces InvalidTransactionAmountException as errorMessage, never rethrows',
    () async {
      viewModel.setAmountMinor(0);
      viewModel.setCategoryId('cat-1');
      viewModel.setFinancialAccountId('account-1');
      when(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).thenThrow(InvalidTransactionAmountException('must be positive'));

      final result = await viewModel.submit();

      expect(result, isFalse);
      expect(viewModel.errorMessage, equals('Amount must be positive.'));
    },
  );

  group('split-transactions', () {
    test('starts non-splitting; startSplitting promotes the current '
        'category into line 1 and adds a blank line 2', () {
      viewModel.setCategoryId('cat-1');
      expect(viewModel.isSplitting, isFalse);

      viewModel.startSplitting();

      expect(viewModel.isSplitting, isTrue);
      expect(viewModel.splitLines, hasLength(2));
      expect(viewModel.splitLines[0].categoryId, equals('cat-1'));
      expect(viewModel.splitLines[1].categoryId, isNull);
    });

    test('splitRemainderMinor is the total minus every line\'s amount', () {
      viewModel.setAmountMinor(10000);
      viewModel.startSplitting();
      viewModel.setSplitLineAmount(0, 6000);
      viewModel.setSplitLineAmount(1, 3000);

      expect(viewModel.splitRemainderMinor, equals(1000));

      viewModel.setSplitLineAmount(1, 4000);
      expect(viewModel.splitRemainderMinor, equals(0));
    });

    test('addSplitLine appends a blank line', () {
      viewModel.startSplitting();
      expect(viewModel.splitLines, hasLength(2));

      viewModel.addSplitLine();

      expect(viewModel.splitLines, hasLength(3));
    });

    test('removing down to one line collapses back to the ordinary, '
        'non-split experience', () {
      viewModel.setCategoryId('cat-1');
      viewModel.startSplitting();
      viewModel.setSplitLineCategory(1, 'cat-2');

      viewModel.removeSplitLine(1);

      expect(viewModel.isSplitting, isFalse);
      expect(viewModel.splitLines, isEmpty);
      expect(viewModel.categoryId, equals('cat-1'));
    });

    test('changing direction clears every split line\'s category', () {
      viewModel.startSplitting();
      viewModel.setSplitLineCategory(0, 'cat-1');
      viewModel.setSplitLineCategory(1, 'cat-2');

      viewModel.setDirection(TransactionDirection.moneyOut);

      expect(viewModel.splitLines.every((l) => l.categoryId == null), isTrue);
    });

    test('submit posts recordSplitTransaction when every line is filled and '
        'balanced', () async {
      viewModel.setAmountMinor(10000);
      viewModel.setFinancialAccountId('account-1');
      viewModel.startSplitting();
      viewModel.setSplitLineCategory(0, 'cat-1');
      viewModel.setSplitLineAmount(0, 6000);
      viewModel.setSplitLineCategory(1, 'cat-2');
      viewModel.setSplitLineAmount(1, 4000);
      when(
        repository.recordSplitTransaction(
          totalAmountMinor: anyNamed('totalAmountMinor'),
          splitLines: anyNamed('splitLines'),
          direction: anyNamed('direction'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).thenAnswer((_) async => 'entry-1');

      final result = await viewModel.submit();

      expect(result, isTrue);
      verify(
        repository.recordSplitTransaction(
          totalAmountMinor: 10000,
          splitLines: [
            (categoryId: 'cat-1', amountMinor: 6000),
            (categoryId: 'cat-2', amountMinor: 4000),
          ],
          direction: TransactionDirection.moneyIn,
          financialAccountId: 'account-1',
          transactionDate: anyNamed('transactionDate'),
          description: null,
        ),
      ).called(1);
      verifyNever(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      );
    });

    test(
      'submit fails without posting while the remainder is nonzero',
      () async {
        viewModel.setAmountMinor(10000);
        viewModel.setFinancialAccountId('account-1');
        viewModel.startSplitting();
        viewModel.setSplitLineCategory(0, 'cat-1');
        viewModel.setSplitLineAmount(0, 6000);
        viewModel.setSplitLineCategory(1, 'cat-2');
        viewModel.setSplitLineAmount(1, 3000);

        final result = await viewModel.submit();

        expect(result, isFalse);
        expect(viewModel.errorMessage, isNotEmpty);
        verifyNever(
          repository.recordSplitTransaction(
            totalAmountMinor: anyNamed('totalAmountMinor'),
            splitLines: anyNamed('splitLines'),
            direction: anyNamed('direction'),
            financialAccountId: anyNamed('financialAccountId'),
            transactionDate: anyNamed('transactionDate'),
            description: anyNamed('description'),
          ),
        );
      },
    );

    test('submit fails without posting while a line has no category', () async {
      viewModel.setAmountMinor(10000);
      viewModel.setFinancialAccountId('account-1');
      viewModel.startSplitting();
      viewModel.setSplitLineCategory(0, 'cat-1');
      viewModel.setSplitLineAmount(0, 10000);
      // Line 1 (index 1) never gets a category.

      final result = await viewModel.submit();

      expect(result, isFalse);
      verifyNever(
        repository.recordSplitTransaction(
          totalAmountMinor: anyNamed('totalAmountMinor'),
          splitLines: anyNamed('splitLines'),
          direction: anyNamed('direction'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      );
    });
  });

  group('credit-card-household-flow', () {
    const checking = Account(
      id: 'account-1',
      name: 'Checking',
      type: AccountType.asset,
      archived: false,
    );
    const visaCard = Account(
      id: 'account-2',
      name: 'Visa',
      type: AccountType.liability,
      archived: false,
      isCreditCard: true,
    );

    Future<RecordTransactionViewModel> viewModelWithCardAndBank() async {
      final withAccounts = MockLedgerRepository();
      when(
        withAccounts.watchFinancialAccounts(),
      ).thenAnswer((_) => Stream.value(const [checking, visaCard]));
      final vm = RecordTransactionViewModel(ledgerRepository: withAccounts);
      await Future<void>.delayed(Duration.zero);
      return vm;
    }

    test('hasCardAccounts is false with no card-flagged account', () {
      expect(viewModel.hasCardAccounts, isFalse);
    });

    test(
      'hasCardAccounts is true once a card-flagged account exists',
      () async {
        final vm = await viewModelWithCardAndBank();
        addTearDown(vm.dispose);

        expect(vm.hasCardAccounts, isTrue);
      },
    );

    test(
      'selectPaidFromCard narrows options to card accounts and preselects one',
      () async {
        final vm = await viewModelWithCardAndBank();
        addTearDown(vm.dispose);

        vm.selectPaidFromCard();

        expect(vm.isPaidFromCard, isTrue);
        expect(
          vm.financialAccountOptions.map((a) => a.id),
          equals(['account-2']),
        );
        expect(vm.financialAccountId, equals('account-2'));
      },
    );

    test(
      'selectPaidFromBank narrows options to non-card accounts and preselects one',
      () async {
        final vm = await viewModelWithCardAndBank();
        addTearDown(vm.dispose);

        vm.selectPaidFromBank();

        expect(vm.isPaidFromBank, isTrue);
        expect(
          vm.financialAccountOptions.map((a) => a.id),
          equals(['account-1']),
        );
        expect(vm.financialAccountId, equals('account-1'));
      },
    );

    test(
      'changing direction clears the paid-from-card/bank shortcut and its filter',
      () async {
        final vm = await viewModelWithCardAndBank();
        addTearDown(vm.dispose);
        vm.selectPaidFromCard();

        vm.setDirection(TransactionDirection.moneyIn);

        expect(vm.isPaidFromCard, isFalse);
        expect(vm.isPaidFromBank, isFalse);
        expect(
          vm.financialAccountOptions.map((a) => a.id),
          equals(['account-1', 'account-2']),
        );
      },
    );

    test('with no card-flagged account, financialAccountOptions is always the '
        'full list', () {
      expect(
        viewModel.financialAccountOptions,
        equals(viewModel.financialAccounts),
      );
    });
  });
}
