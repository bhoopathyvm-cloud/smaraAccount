import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/ui/features/transfer/view_models/transfer_view_model.dart';
import 'package:smara_accounting/ui/features/transfer/views/transfer_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late MockExchangeRateService exchangeRateService;
  late MockSettingsRepository settingsRepository;

  TransferViewModel buildViewModel({String? initialFromAccountId}) {
    return TransferViewModel(
      ledgerRepository: repository,
      exchangeRateService: exchangeRateService,
      settingsRepository: settingsRepository,
      initialFromAccountId: initialFromAccountId,
    );
  }

  const checking = Account(
    id: 'asset-1',
    name: 'Checking',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-usd',
  );
  const savings = Account(
    id: 'asset-2',
    name: 'Savings',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-usd',
  );
  const euroSavings = Account(
    id: 'asset-3',
    name: 'Euro Savings',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-eur',
  );
  const usdGroup = AccountGroup(
    id: 'group-usd',
    name: 'Cash & cash equivalents',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 0,
    isSystem: true,
    currency: 'USD',
    archived: false,
  );
  const eurGroup = AccountGroup(
    id: 'group-eur',
    name: 'Pension & retirement',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 1,
    isSystem: true,
    currency: 'EUR',
    archived: false,
  );

  setUp(() {
    repository = MockLedgerRepository();
    when(
      repository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking, savings]));
    when(
      repository.watchAccountGroups(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([usdGroup, eurGroup]));
    when(
      repository.watchCategories(),
    ).thenAnswer((_) => Stream.value(const []));

    exchangeRateService = MockExchangeRateService();
    settingsRepository = MockSettingsRepository();
    when(
      settingsRepository.isReferenceRateLookupEnabled(),
    ).thenAnswer((_) async => false);
    when(
      settingsRepository.selectedProvider(),
    ).thenAnswer((_) async => ExchangeRateProvider.values.first);
  });

  testWidgets('shows a hint and disables submit with fewer than two accounts', (
    tester,
  ) async {
    when(
      repository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking]));

    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: TransferView(viewModel: viewModel)),
    );
    await tester.pump();

    expect(
      find.text('Create at least two active accounts to make a transfer.'),
      findsOneWidget,
    );
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('submitting a valid transfer calls onSaved', (tester) async {
    when(
      repository.recordTransfer(
        fromAccountId: anyNamed('fromAccountId'),
        toAccountId: anyNamed('toAccountId'),
        amountMinor: anyNamed('amountMinor'),
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
      ),
    ).thenAnswer((_) async {});

    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);
    var saved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TransferView(viewModel: viewModel, onSaved: () => saved = true),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, '25.00');
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'Moved money'),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Moved money'));
    await tester.pump();
    await tester.pump();

    expect(saved, isTrue);
    verify(
      repository.recordTransfer(
        fromAccountId: 'asset-1',
        toAccountId: 'asset-2',
        amountMinor: 2500,
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
      ),
    ).called(1);
  });

  testWidgets('surfaces a domain exception as an error message', (
    tester,
  ) async {
    when(
      repository.recordTransfer(
        fromAccountId: anyNamed('fromAccountId'),
        toAccountId: anyNamed('toAccountId'),
        amountMinor: anyNamed('amountMinor'),
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
      ),
    ).thenThrow(
      InvalidTransferException(
        'accounts must be distinct',
        code: AppErrorCode.transferAccountsMustDiffer,
      ),
    );

    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: TransferView(viewModel: viewModel)),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, '10.00');
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'Moved money'),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Moved money'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Source and destination accounts must be different.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'the deducted-fee checkbox appears once a fee is entered and toggling it updates the ViewModel',
    (tester) async {
      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: TransferView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.text('Fee is deducted from the amount above'), findsNothing);

      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == 'Fee amount',
        ),
        '1.62',
      );
      await tester.pump();

      final checkboxFinder = find.text('Fee is deducted from the amount above');
      expect(checkboxFinder, findsOneWidget);
      expect(viewModel.feeDeductedFromAmount, isFalse);

      await tester.ensureVisible(checkboxFinder);
      await tester.tap(checkboxFinder);
      await tester.pump();

      expect(viewModel.feeDeductedFromAmount, isTrue);
    },
  );

  group('cross-currency branching', () {
    setUp(() {
      when(
        repository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([checking, savings, euroSavings]));
    });

    testWidgets(
      'does not show a destination-amount field for a same-currency transfer',
      (tester) async {
        final viewModel = buildViewModel();
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: TransferView(viewModel: viewModel)),
        );
        await tester.pump();

        expect(find.text('Destination amount (optional)'), findsNothing);
      },
    );

    testWidgets(
      'shows an optional destination-amount field once a different-currency account is chosen',
      (tester) async {
        final viewModel = buildViewModel();
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: TransferView(viewModel: viewModel)),
        );
        await tester.pump();

        await tester.tap(
          find.widgetWithText(DropdownButtonFormField<String>, 'Savings'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Euro Savings').last);
        await tester.pumpAndSettle();

        expect(find.text('Destination amount (optional)'), findsOneWidget);
      },
    );

    testWidgets(
      'leaving the destination amount blank posts a provisional (unknown-rate) transfer',
      (tester) async {
        when(
          repository.recordTransfer(
            fromAccountId: anyNamed('fromAccountId'),
            toAccountId: anyNamed('toAccountId'),
            amountMinor: anyNamed('amountMinor'),
            transactionDate: anyNamed('transactionDate'),
            description: anyNamed('description'),
            destinationAmountMinor: null,
          ),
        ).thenAnswer((_) async {});

        final viewModel = buildViewModel();
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: TransferView(viewModel: viewModel)),
        );
        await tester.pump();

        await tester.tap(
          find.widgetWithText(DropdownButtonFormField<String>, 'Savings'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Euro Savings').last);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, '100.00');
        await tester.ensureVisible(
          find.widgetWithText(ElevatedButton, 'Moved money'),
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Moved money'));
        await tester.pump();
        await tester.pump();

        verify(
          repository.recordTransfer(
            fromAccountId: 'asset-1',
            toAccountId: 'asset-3',
            amountMinor: 10000,
            transactionDate: anyNamed('transactionDate'),
            description: anyNamed('description'),
            destinationAmountMinor: null,
          ),
        ).called(1);
      },
    );

    testWidgets(
      'entering a destination amount posts a known-rate cross-currency transfer',
      (tester) async {
        when(
          repository.recordTransfer(
            fromAccountId: anyNamed('fromAccountId'),
            toAccountId: anyNamed('toAccountId'),
            amountMinor: anyNamed('amountMinor'),
            transactionDate: anyNamed('transactionDate'),
            description: anyNamed('description'),
            destinationAmountMinor: anyNamed('destinationAmountMinor'),
          ),
        ).thenAnswer((_) async {});

        final viewModel = buildViewModel();
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: TransferView(viewModel: viewModel)),
        );
        await tester.pump();

        await tester.tap(
          find.widgetWithText(DropdownButtonFormField<String>, 'Savings'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Euro Savings').last);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, '100.00');
        // The destination account (Euro Savings) is EUR - a comma decimal
        // is EUR's own convention (localized-money-formatting), not a
        // period.
        await tester.enterText(find.byType(TextField).at(1), '92,00');
        await tester.ensureVisible(
          find.widgetWithText(ElevatedButton, 'Moved money'),
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Moved money'));
        await tester.pump();
        await tester.pump();

        verify(
          repository.recordTransfer(
            fromAccountId: 'asset-1',
            toAccountId: 'asset-3',
            amountMinor: 10000,
            transactionDate: anyNamed('transactionDate'),
            description: anyNamed('description'),
            destinationAmountMinor: 9200,
          ),
        ).called(1);
      },
    );

    testWidgets('no reference rate row when the lookup setting is disabled', (
      tester,
    ) async {
      // settingsRepository.isReferenceRateLookupEnabled() is stubbed to
      // false in the top-level setUp.
      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: TransferView(viewModel: viewModel)),
      );
      await tester.pump();

      await tester.tap(
        find.widgetWithText(DropdownButtonFormField<String>, 'Savings'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Euro Savings').last);
      await tester.pumpAndSettle();

      verifyZeroInteractions(exchangeRateService);
      expect(find.textContaining('Reference rate'), findsNothing);
    });

    testWidgets(
      'no reference rate row when lookup is enabled but the service returns null',
      (tester) async {
        when(
          settingsRepository.isReferenceRateLookupEnabled(),
        ).thenAnswer((_) async => true);
        when(
          exchangeRateService.fetchRate(
            from: anyNamed('from'),
            to: anyNamed('to'),
            provider: anyNamed('provider'),
          ),
        ).thenAnswer((_) async => null);

        final viewModel = buildViewModel();
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: TransferView(viewModel: viewModel)),
        );
        await tester.pump();

        await tester.tap(
          find.widgetWithText(DropdownButtonFormField<String>, 'Savings'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Euro Savings').last);
        await tester.pumpAndSettle();

        expect(find.textContaining('Reference rate'), findsNothing);
      },
    );

    testWidgets(
      'a fetched reference rate is shown but never overwrites the destination-amount field',
      (tester) async {
        when(
          settingsRepository.isReferenceRateLookupEnabled(),
        ).thenAnswer((_) async => true);
        when(
          exchangeRateService.fetchRate(
            from: anyNamed('from'),
            to: anyNamed('to'),
            provider: anyNamed('provider'),
          ),
        ).thenAnswer((_) async => 0.9);

        final viewModel = buildViewModel();
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: TransferView(viewModel: viewModel)),
        );
        await tester.pump();

        await tester.tap(
          find.widgetWithText(DropdownButtonFormField<String>, 'Savings'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Euro Savings').last);
        await tester.pumpAndSettle();

        expect(find.textContaining('Reference rate'), findsOneWidget);
        // Display-only: the fetched rate must never be written into the
        // destination-amount field itself.
        expect(viewModel.destinationAmountMinor, isNull);
        final destinationField = tester.widget<TextField>(
          find.byType(TextField).at(1),
        );
        expect(destinationField.controller?.text, isEmpty);
      },
    );
  });
}
