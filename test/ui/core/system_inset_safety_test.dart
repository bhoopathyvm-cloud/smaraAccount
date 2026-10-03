import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_currency_catalog.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/domain/models/integrity_event.dart';
import 'package:smara_accounting/domain/models/claim.dart';
import 'package:smara_accounting/domain/models/claim_status.dart';
import 'package:smara_accounting/domain/models/home_overview.dart';
import 'package:smara_accounting/domain/models/payee.dart';
import 'package:smara_accounting/domain/models/pending_transfer.dart';
import 'package:smara_accounting/domain/models/quote_provider.dart';
import 'package:smara_accounting/domain/models/recurring_template.dart';
import 'package:smara_accounting/domain/models/research_tool.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/investment/exchange_registry.dart';
import 'package:smara_accounting/domain/statement_import/parsed_statement_transaction.dart';
import 'package:smara_accounting/domain/statement_import/statement_import_preview.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/data/repositories/claim_repository.dart';
import 'package:smara_accounting/ui/features/claims/view_models/claims_list_view_model.dart';
import 'package:smara_accounting/ui/features/claims/views/claims_list_view.dart';
import 'package:smara_accounting/ui/features/continuation/view_models/continuation_view_model.dart';
import 'package:smara_accounting/ui/features/continuation/views/continuation_view.dart';
import 'package:smara_accounting/ui/features/correction_wizard/view_models/correction_view_model.dart';
import 'package:smara_accounting/ui/features/correction_wizard/views/correction_view.dart';
import 'package:smara_accounting/ui/features/first_week_setup/view_models/first_week_setup_view_model.dart';
import 'package:smara_accounting/ui/features/first_week_setup/views/first_week_setup_view.dart';
import 'package:smara_accounting/ui/features/lock/view_models/lock_view_model.dart';
import 'package:smara_accounting/ui/features/lock/views/lock_view.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/currency_backfill_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/first_account_name_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/first_identity_setup_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/views/currency_backfill_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/currency_selection_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/first_account_name_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/language_selection_view.dart';
import 'package:smara_accounting/ui/features/payee_management/view_models/payee_management_view_model.dart';
import 'package:smara_accounting/ui/features/payee_management/views/payee_management_view.dart';
import 'package:smara_accounting/ui/features/record_transaction/view_models/record_transaction_view_model.dart';
import 'package:smara_accounting/ui/features/record_transaction/views/record_transaction_view.dart';
import 'package:smara_accounting/ui/features/recurring_template_management/view_models/recurring_template_management_view_model.dart';
import 'package:smara_accounting/ui/features/recurring_template_management/views/recurring_template_management_view.dart';
import 'package:smara_accounting/ui/features/settings/view_models/device_history_view_model.dart';
import 'package:smara_accounting/ui/features/settings/view_models/settings_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/device_history_view.dart';
import 'package:smara_accounting/ui/features/settings/views/settings_view.dart';
import 'package:smara_accounting/ui/features/settle_pending_transfer/view_models/settle_pending_transfer_view_model.dart';
import 'package:smara_accounting/ui/features/settle_pending_transfer/views/settle_pending_transfer_view.dart';
import 'package:smara_accounting/ui/features/setup_choice/view_models/bundle_import_view_model.dart';
import 'package:smara_accounting/ui/features/setup_choice/views/bundle_import_view.dart';
import 'package:smara_accounting/ui/features/statement_import/view_models/statement_import_view_model.dart';
import 'package:smara_accounting/ui/features/statement_import/views/preview_step.dart';
import 'package:smara_accounting/ui/features/statement_import/views/summary_step.dart';
import 'package:smara_accounting/ui/features/transfer/view_models/transfer_view_model.dart';
import 'package:smara_accounting/ui/features/transfer/views/transfer_view.dart';

import '../../mocks.mocks.dart';
import 'system_inset_test_helpers.dart';

Future<LocaleController> _loadedLocaleController() async {
  final controller = LocaleController(settingsRepository: SettingsRepository());
  await controller.load();
  return controller;
}

Widget _languageApp(LocaleController locale, {required Widget home}) {
  return ChangeNotifierProvider<LocaleController>.value(
    value: locale,
    child: Builder(
      builder: (context) {
        final watched = context.watch<LocaleController>();
        return MaterialApp(
          locale: watched.overrideLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedAppLocales,
          localeListResolutionCallback: (locales, supported) => watched.resolve(
            locales?.isNotEmpty == true ? locales!.first : null,
          ),
          home: home,
        );
      },
    ),
  );
}

void main() {
  final surfaces = <String, Size>{
    'tablet 1200x1920@2': kTabletLogicalSize,
    'phone 375x667@2': kPhoneLogicalSize,
  };

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('pinned bottom actions stay clear of system inset', () {
    for (final entry in surfaces.entries) {
      testWidgets('LanguageSelectionView Continue on ${entry.key}', (
        tester,
      ) async {
        final controller = await _loadedLocaleController();
        await pumpWithBottomSystemInset(
          tester,
          logicalSize: entry.value,
          app: _languageApp(
            controller,
            home: LanguageSelectionView(onFinished: () {}),
          ),
        );
        await tester.pumpAndSettle();

        final en = lookupAppLocalizations(const Locale('en'));
        await tester.tap(find.text(en.settingsLanguageSystem));
        await tester.pump();

        await expectPrimaryActionClearOfBottomSystemInset(
          tester,
          actionFinder: find.widgetWithText(ElevatedButton, en.actionContinue),
        );
      });

      testWidgets('ContinuationView primary action on ${entry.key}', (
        tester,
      ) async {
        final viewModel = ContinuationViewModel(
          identityRepository: MockIdentityRepository(),
          chainVerifier: MockLedgerChainVerifier(),
          booksCopyRepository: MockBooksCopyRepository(),
        );
        await pumpWithBottomSystemInset(
          tester,
          logicalSize: entry.value,
          app: MaterialApp(
            home: ContinuationView(
              viewModel: viewModel,
              onContinued: () {},
              onRestoreFromCopy: () {},
            ),
          ),
        );

        await expectPrimaryActionClearOfBottomSystemInset(
          tester,
          actionFinder: find.widgetWithText(
            ElevatedButton,
            'Continue my books on this phone',
          ),
        );
      });
    }
  });

  group('statement import pinned footers', () {
    late MockAccountRepository accountRepository;
    late MockCategoryRepository categoryRepository;
    late MockPayeeRepository payeeRepository;
    late MockStatementImportRepository importRepository;

    const checking = Account(
      id: 'asset-1',
      name: 'Checking',
      type: AccountType.asset,
      archived: false,
      groupId: 'group-1',
    );
    final rowA = ParsedStatementTransaction(
      transactionDate: DateTime(2026, 1, 5),
      amountMinor: 1000,
      direction: TransactionDirection.moneyOut,
      description: 'Row A',
      currency: 'USD',
      externalReferenceId: 'FIT-A',
    );

    setUp(() {
      accountRepository = MockAccountRepository();
      categoryRepository = MockCategoryRepository();
      payeeRepository = MockPayeeRepository();
      importRepository = MockStatementImportRepository();
      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([checking]));
      when(
        categoryRepository.watchCategories(),
      ).thenAnswer((_) => Stream.value(const <Account>[]));
      when(
        importRepository.watchProfiles(),
      ).thenAnswer((_) => Stream.value(const []));
      when(
        importRepository.watchCategoryRules(),
      ).thenAnswer((_) => Stream.value(const []));
      when(importRepository.parseOfxFile(any)).thenReturn(
        StatementParseResult(
          transactions: [rowA],
          skippedRows: const [],
          statementCurrency: 'USD',
        ),
      );
      when(
        importRepository.buildPreviewRows(
          financialAccountId: anyNamed('financialAccountId'),
          transactions: anyNamed('transactions'),
          rules: anyNamed('rules'),
        ),
      ).thenAnswer(
        (_) async => StatementImportPreview(
          accountCurrency: 'USD',
          rows: [
            StatementImportPreviewDraft(transaction: rowA, isDuplicate: false),
          ],
        ),
      );
    });

    testWidgets('PreviewStep Confirm import clears inset on tablet', (
      tester,
    ) async {
      final viewModel = StatementImportViewModel(
        importRepository: importRepository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: payeeRepository,
        initialFinancialAccountId: checking.id,
      );
      addTearDown(viewModel.dispose);
      viewModel.chooseSource(StatementSource.ofx);
      await viewModel.loadFile(name: 'statement.ofx', bytes: const [1, 2, 3]);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kTabletLogicalSize,
        app: MaterialApp(
          home: Scaffold(body: PreviewStep(viewModel: viewModel)),
        ),
      );
      await tester.pumpAndSettle();

      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.widgetWithText(ElevatedButton, 'Confirm import'),
      );
    });

    testWidgets('SummaryStep Done clears inset on tablet', (tester) async {
      final viewModel = StatementImportViewModel(
        importRepository: importRepository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: payeeRepository,
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kTabletLogicalSize,
        app: MaterialApp(
          home: Scaffold(
            body: SummaryStep(viewModel: viewModel, onFinished: () {}),
          ),
        ),
      );

      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.widgetWithText(ElevatedButton, 'Done'),
      );
    });
  });

  group('scrollable forms: padding includes inset; primary action clear', () {
    testWidgets('CurrencySelectionView', (tester) async {
      final viewModel = FirstIdentitySetupViewModel(
        identityRepository: MockIdentityRepository(),
        chainVerifier: MockLedgerChainVerifier(),
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(
          home: CurrencySelectionView(viewModel: viewModel, onFinished: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(SingleChildScrollView),
      );
      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.widgetWithText(ElevatedButton, 'Continue'),
        scrollIntoView: true,
      );
    });

    testWidgets('FirstAccountNameView', (tester) async {
      final repository = MockAccountRepository();
      when(repository.watchFinancialAccounts()).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'asset-seed',
            name: 'Cash & Bank',
            type: AccountType.asset,
            archived: false,
          ),
        ]),
      );
      final viewModel = FirstAccountNameViewModel(
        accountRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(
          home: FirstAccountNameView(viewModel: viewModel, onFinished: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(SingleChildScrollView),
      );
      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.widgetWithText(ElevatedButton, 'Continue'),
        scrollIntoView: true,
      );
    });

    testWidgets('CurrencyBackfillView', (tester) async {
      final viewModel = CurrencyBackfillViewModel(
        accountRepository: MockAccountRepository(),
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(
          home: CurrencyBackfillView(viewModel: viewModel, onFinished: () {}),
        ),
      );

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(SingleChildScrollView),
      );
      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.widgetWithText(ElevatedButton, 'Continue'),
        scrollIntoView: true,
      );
    });

    testWidgets('FirstWeekSetupView', (tester) async {
      final viewModel = FirstWeekSetupViewModel(
        accountRepository: MockAccountRepository(),
        settingsRepository: MockSettingsRepository(),
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(
          home: FirstWeekSetupView(viewModel: viewModel, onFinished: () {}),
        ),
      );

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(SingleChildScrollView),
      );
      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.widgetWithText(ElevatedButton, 'Finish'),
        scrollIntoView: true,
      );
    });

    testWidgets('BundleImportView', (tester) async {
      final viewModel = BundleImportViewModel(
        booksCopyRepository: MockBooksCopyRepository(),
      );

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(home: BundleImportView(viewModel: viewModel)),
      );

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(SingleChildScrollView),
      );
      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.widgetWithText(ElevatedButton, 'Import'),
        scrollIntoView: true,
      );
    });

    testWidgets('LockView Unlock', (tester) async {
      final settings = MockSettingsRepository();
      when(settings.isAppLockBiometricEnabled()).thenAnswer((_) async => false);
      final viewModel = LockViewModel(
        appLockService: MockAppLockService(),
        biometricAuthenticator: MockBiometricAuthenticator(),
        settingsRepository: settings,
        lockController: MockAppLockController(),
        localeController: LocaleController(settingsRepository: settings),
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(home: LockView(viewModel: viewModel)),
      );
      await tester.pump();

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(SingleChildScrollView),
      );
      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.widgetWithText(ElevatedButton, 'Unlock'),
        scrollIntoView: true,
      );
    });

    testWidgets('RecordTransactionView Save', (tester) async {
      final accountRepository = MockAccountRepository();
      final categoryRepository = MockCategoryRepository();
      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'a1',
            name: 'Checking',
            type: AccountType.asset,
            archived: false,
          ),
        ]),
      );
      when(
        accountRepository.watchAccountCurrencies(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value(const AccountCurrencyCatalog({'a1': 'USD'})),
      );
      when(
        categoryRepository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value(const <Account>[]));

      final viewModel = RecordTransactionViewModel(
        ledgerRepository: MockLedgerRepository(),
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: MockPayeeRepository(),
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(home: RecordTransactionView(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(SingleChildScrollView),
      );
      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.widgetWithText(ElevatedButton, 'Save'),
        scrollIntoView: true,
      );
    });

    testWidgets('TransferView primary action', (tester) async {
      final accountRepository = MockAccountRepository();
      final categoryRepository = MockCategoryRepository();
      final settingsRepository = MockSettingsRepository();
      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'a1',
            name: 'Checking',
            type: AccountType.asset,
            archived: false,
            groupId: 'g1',
          ),
          Account(
            id: 'a2',
            name: 'Savings',
            type: AccountType.asset,
            archived: false,
            groupId: 'g1',
          ),
        ]),
      );
      when(
        accountRepository.watchAccountCurrencies(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          const AccountCurrencyCatalog({'a1': 'USD', 'a2': 'USD'}),
        ),
      );
      when(
        categoryRepository.watchCategories(),
      ).thenAnswer((_) => Stream.value(const []));
      when(
        settingsRepository.isReferenceRateLookupEnabled(),
      ).thenAnswer((_) async => false);
      when(
        settingsRepository.selectedProvider(),
      ).thenAnswer((_) async => ExchangeRateProvider.values.first);

      final viewModel = TransferViewModel(
        ledgerRepository: MockLedgerRepository(),
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        settingsRepository: settingsRepository,
        exchangeRateService: MockExchangeRateService(),
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(home: TransferView(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(SingleChildScrollView),
      );
      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.byType(ElevatedButton),
        scrollIntoView: true,
      );
    });

    testWidgets('CorrectionView Confirm fix', (tester) async {
      final accountRepository = MockAccountRepository();
      final categoryRepository = MockCategoryRepository();
      const account = Account(
        id: 'asset-1',
        name: 'Cash',
        type: AccountType.asset,
        archived: false,
        groupId: 'group-cash',
      );
      const groceries = Account(
        id: 'expense-groceries',
        name: 'Groceries',
        type: AccountType.expense,
        archived: false,
      );
      when(
        accountRepository.watchFinancialAccounts(),
      ).thenAnswer((_) => Stream.value([account]));
      when(
        categoryRepository.watchCategories(),
      ).thenAnswer((_) => Stream.value([groceries]));
      when(
        accountRepository.watchAccountCurrencies(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value(const AccountCurrencyCatalog({'asset-1': 'USD'})),
      );

      final viewModel = CorrectionViewModel(
        ledgerRepository: MockLedgerRepository(),
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        entryId: 'entry-1',
        initialAmountMinor: 1000,
        initialDirection: TransactionDirection.moneyOut,
        initialCategoryId: groceries.id,
        initialFinancialAccountId: account.id,
        initialTransactionDate: DateTime(2026, 1, 17),
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(home: CorrectionView(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(SingleChildScrollView),
      );
      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.byType(ElevatedButton),
        scrollIntoView: true,
      );
    });
  });

  group('list screens: scroll padding clears inset', () {
    testWidgets('SettingsView ListView padding', (tester) async {
      final repository = MockSettingsRepository();
      final lockController = MockAppLockController();
      when(
        repository.isReferenceRateLookupEnabled(),
      ).thenAnswer((_) async => false);
      when(
        repository.selectedProvider(),
      ).thenAnswer((_) async => ExchangeRateProvider.frankfurter);
      when(
        repository.isMarketPriceFetchEnabled(),
      ).thenAnswer((_) async => true);
      when(
        repository.selectedQuoteProvider(),
      ).thenAnswer((_) async => QuoteProvider.stooq);
      when(
        repository.selectedResearchTool(),
      ).thenAnswer((_) async => ResearchTool.chatGpt);
      when(
        repository.selectedDefaultExchange(
          deviceRegion: anyNamed('deviceRegion'),
        ),
      ).thenAnswer((_) async => exchangeForCode('US')!);
      when(repository.isAppLockEnabled()).thenAnswer((_) async => false);
      when(repository.appLockTimeoutMinutes()).thenAnswer((_) async => 0);
      when(
        repository.isAppLockBiometricEnabled(),
      ).thenAnswer((_) async => false);
      when(repository.isBackupReminderEnabled()).thenAnswer((_) async => true);
      when(repository.backupReminderDays()).thenAnswer((_) async => 30);
      when(repository.backupReminderEntries()).thenAnswer((_) async => 500);
      when(repository.backupReminderSnoozeDays()).thenAnswer((_) async => 7);
      when(
        repository.backupReminderSnoozeEntries(),
      ).thenAnswer((_) async => 500);
      final biometric = MockBiometricAuthenticator();
      when(biometric.isAvailable()).thenAnswer((_) async => false);
      when(lockController.isSnapshotHidingEnabled).thenReturn(false);

      final viewModel = SettingsViewModel(
        settingsRepository: repository,
        booksCopyRepository: MockBooksCopyRepository(),
        appLockService: MockAppLockService(),
        biometricAuthenticator: biometric,
        appLockController: lockController,
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kTabletLogicalSize,
        app: MaterialApp(home: SettingsView(viewModel: viewModel)),
      );
      await tester.pump();
      while (viewModel.isLoading) {
        await tester.pump();
      }

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(ListView),
      );
    });

    testWidgets('DeviceHistoryView ListView padding', (tester) async {
      final ledger = MockLedgerRepository();
      when(ledger.watchIntegrityEvents()).thenAnswer(
        (_) => Stream.value([
          IntegrityEvent(
            eventId: 'e1',
            eventType: IntegrityEventType.identityContinued,
            occurredAt: DateTime.utc(2026, 10, 3),
            relatedEntryId: null,
            relatedIdentityId: 'new',
            detail:
                '{"newId":"n","previousId":"p","copySavedAt":"2026-10-01T00:00:00.000Z"}',
          ),
        ]),
      );
      final viewModel = DeviceHistoryViewModel(ledgerRepository: ledger);
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(home: DeviceHistoryView(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(ListView),
      );
    });

    testWidgets('PayeeManagementView ListView bottom inset padding', (
      tester,
    ) async {
      final repository = MockPayeeRepository();
      when(repository.watchPayees()).thenAnswer(
        (_) => Stream.value(const [Payee(id: 'p1', name: 'Starbucks')]),
      );
      final viewModel = PayeeManagementViewModel(payeeRepository: repository);
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(home: PayeeManagementView(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      final list = tester.widget<ListView>(find.byType(ListView));
      final padding = list.padding!.resolve(TextDirection.ltr);
      expect(padding.bottom, greaterThanOrEqualTo(kBottomSystemInsetLogical));
    });

    testWidgets('RecurringTemplateManagementView ListView bottom inset', (
      tester,
    ) async {
      final repository = MockRecurringTemplateRepository();
      final accountRepository = MockAccountRepository();
      final categoryRepository = MockCategoryRepository();
      when(repository.watchRecurringTemplates()).thenAnswer(
        (_) => Stream.value(const [
          RecurringTemplate(
            id: 'template-1',
            name: 'Rent',
            direction: TransactionDirection.moneyOut,
            financialAccountId: 'account-1',
            categoryId: 'expense-1',
            amountMinor: 150000,
            dayOfMonth: 1,
          ),
        ]),
      );
      when(accountRepository.watchFinancialAccounts()).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'account-1',
            name: 'Checking',
            type: AccountType.asset,
            archived: false,
            groupId: 'group-1',
          ),
        ]),
      );
      when(
        accountRepository.watchAccountCurrencies(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value(const AccountCurrencyCatalog({'account-1': 'USD'})),
      );
      when(categoryRepository.watchCategories()).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'expense-1',
            name: 'Groceries',
            type: AccountType.expense,
            archived: false,
          ),
        ]),
      );

      final viewModel = RecurringTemplateManagementViewModel(
        recurringTemplateRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(
          home: RecurringTemplateManagementView(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      final list = tester.widget<ListView>(find.byType(ListView));
      final padding = list.padding!.resolve(TextDirection.ltr);
      expect(padding.bottom, greaterThanOrEqualTo(kBottomSystemInsetLogical));
    });

    testWidgets('ClaimsListView ListView padding', (tester) async {
      final vm = ClaimsListViewModel(
        claims: _NoopClaims(),
        localDeviceId: 'ravi',
        companyDisplayName: 'Acme',
      );
      vm.loading = false;
      vm.balanceMinor = 12000;
      vm.items = [
        Claim(
          id: 'claim-aaaaaaaa',
          claimantDeviceId: 'ravi',
          status: ClaimStatus.submitted,
          createdAt: DateTime(2026, 3, 1),
          updatedAt: DateTime(2026, 3, 1),
          submittedAt: DateTime(2026, 3, 1),
        ),
      ];

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(
          localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
          supportedLocales: supportedAppLocales,
          home: ClaimsListView(viewModel: vm),
        ),
      );

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(ListView),
        base: 16,
      );
    });
  });

  group('settle pending transfer scroll form', () {
    testWidgets('SettlePendingTransferView Settle action', (tester) async {
      final accountRepository = MockAccountRepository();
      final categoryRepository = MockCategoryRepository();
      const checking = Account(
        id: 'asset-1',
        name: 'Checking',
        type: AccountType.asset,
        archived: false,
        groupId: 'group-usd',
      );
      const euroSavings = Account(
        id: 'asset-2',
        name: 'Euro Savings',
        type: AccountType.asset,
        archived: false,
        groupId: 'group-eur',
      );
      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([checking, euroSavings]));
      when(
        accountRepository.watchAccountCurrencies(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          const AccountCurrencyCatalog({'asset-1': 'USD', 'asset-2': 'EUR'}),
        ),
      );
      when(categoryRepository.watchCategories()).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'expense-1',
            name: 'Bank Fees',
            type: AccountType.expense,
            archived: false,
          ),
        ]),
      );

      final pending = PendingTransfer(
        id: 'pending-1',
        kind: PendingTransferKind.transfer,
        sourceAccountId: 'asset-1',
        currency: 'USD',
        destinationAccountId: 'asset-2',
        provisionalEntryId: 'entry-1',
        status: PendingTransferStatus.pending,
        initiatedAt: DateTime(2026, 1, 15),
      );
      final summary = PendingTransferSummary(
        pendingTransfer: pending,
        sourceAccountName: 'Checking',
        destinationLabel: 'Euro Savings',
        currency: 'USD',
        amountMinor: 10000,
      );
      final viewModel = SettlePendingTransferViewModel(
        ledgerRepository: MockLedgerRepository(),
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        summary: summary,
      );
      addTearDown(viewModel.dispose);

      await pumpWithBottomSystemInset(
        tester,
        logicalSize: kPhoneLogicalSize,
        app: MaterialApp(home: SettlePendingTransferView(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      expectScrollPaddingIncludesBottomInset(
        tester,
        scrollableFinder: find.byType(SingleChildScrollView),
      );
      await expectPrimaryActionClearOfBottomSystemInset(
        tester,
        actionFinder: find.widgetWithText(ElevatedButton, 'Settle'),
        scrollIntoView: true,
      );
    });
  });
}

class _NoopClaims extends Fake implements ClaimRepository {}
