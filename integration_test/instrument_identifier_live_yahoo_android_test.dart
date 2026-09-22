import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/instrument_quote_refresh.dart';
import 'package:smara_accounting/data/instrument_quote_service.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/investment_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/investment/exchange_registry.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/instrument_quote.dart';
import 'package:smara_accounting/domain/models/quote_provider.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/holdings/view_models/holdings_view_model.dart';
import 'package:smara_accounting/ui/features/holdings/views/holdings_view.dart';

import '../test/domain/crypto/in_memory_secure_key_storage.dart';

/// Live-network verification for instrument-identifier-assist task 6.3:
/// on a real Android device, resolve via Yahoo and confirm the currency-
/// mismatch warning when the NYSE `UBS` listing is chosen for a CHF account.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late LedgerRepository repository;
  late AccountRepository accountRepository;
  late CategoryRepository categoryRepository;
  late InvestmentRepository investmentRepository;
  late SettingsRepository settingsRepository;
  late String accountId;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final signingKeyService = SigningKeyService(
      secureStorage: InMemorySecureKeyStorage(),
    );
    repository = LedgerRepository(
      database: db,
      signingKeyService: signingKeyService,
    );
    accountRepository = AccountRepository(
      database: db,
      ledgerRepository: repository,
    );
    categoryRepository = CategoryRepository(database: db);
    final identityRepository = IdentityRepository(
      database: db,
      accountRepository: accountRepository,
      signingKeyService: signingKeyService,
    );
    investmentRepository = InvestmentRepository(
      database: db,
      ledgerRepository: repository,
    );
    settingsRepository = SettingsRepository();
    await settingsRepository.setMarketPriceFetchEnabled(true);
    await settingsRepository.setSelectedQuoteProvider(
      QuoteProvider.yahooFinance,
    );
    // Prefer SIX so a CHF listing is pre-selected when both appear; the
    // test then deliberately switches to the NYSE `UBS` candidate.
    await settingsRepository.setDefaultExchange(exchangeForCode('SIX')!);
    final generated = await identityRepository.generateFirstIdentity();
    await identityRepository.confirmFirstIdentity(generated, currency: 'CHF');
    await accountRepository.changeAccountGroupCurrency(
      groupId: groupInvestmentsId,
      currency: 'CHF',
    );
    final account = await accountRepository.createFinancialAccount(
      name: 'Swiss Brokerage',
      type: AccountType.asset,
      groupId: groupInvestmentsId,
      holdsInvestments: true,
    );
    accountId = account.id;
    final categories = await categoryRepository.watchCategories().first;
    final incomeId = categories
        .firstWhere((a) => a.type == AccountType.income)
        .id;
    await repository.recordTransaction(
      amountMinor: 500000,
      direction: TransactionDirection.moneyIn,
      categoryId: incomeId,
      financialAccountId: accountId,
      transactionDate: DateTime(2026, 1, 1),
    );
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
    'Android + live Yahoo: choosing NYSE UBS in a CHF account shows the '
    'currency-mismatch warning',
    (tester) async {
      // Sanity: live search must work from this device before we drive UI.
      final probe = InstrumentQuoteService();
      final live = await probe.searchIdentifier('UBS');
      expect(
        live,
        isNotEmpty,
        reason:
            'live Yahoo search for UBS returned no candidates '
            '(network/device connectivity)',
      );
      expect(
        live.any((c) => c.symbol == 'UBS' && c.currency == 'USD'),
        isTrue,
        reason:
            'live Yahoo search must include the NYSE UBS (USD) listing; '
            'got: ${live.map((c) => '${c.symbol}/${c.currency}').join(', ')}',
      );

      final viewModel = HoldingsViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        investmentRepository: investmentRepository,
        settingsRepository: settingsRepository,
        accountId: accountId,
        quoteRefresh: InstrumentQuoteRefresh(
          settingsRepository: settingsRepository,
          investmentRepository: investmentRepository,
          quoteService: InstrumentQuoteService(),
        ),
        quoteService: InstrumentQuoteService(),
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: HoldingsView(viewModel: viewModel)),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Buy'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New instrument'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'UBS');
      await tester.enterText(
        find.widgetWithText(TextField, 'Ticker (optional)'),
        'UBS',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Quantity'), '10');
      await tester.enterText(
        find.widgetWithText(TextField, 'Unit price'),
        '1.00',
      );
      await tester.pump();

      await tester.tap(find.text('Record buy'));
      // Live Yahoo search: allow several seconds for the network round-trip.
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 250));
        if (find.text('Confirm the listing').evaluate().isNotEmpty) break;
      }
      await tester.pumpAndSettle();

      expect(find.text('Confirm the listing'), findsOneWidget);
      expect(find.textContaining('NYSE'), findsWidgets);

      // Choose the NYSE `UBS` listing (USD), not the Swiss one.
      final nyseTile = find.ancestor(
        of: find.textContaining('NYSE'),
        matching: find.byType(RadioListTile<InstrumentCandidate>),
      );
      expect(nyseTile, findsWidgets);
      await tester.tap(nyseTile.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      final instruments = await investmentRepository.watchInstruments().first;
      final ubs = instruments.singleWhere((i) => i.name == 'UBS');
      // Bare US Yahoo symbols have no market suffix, so exchangeCode is null
      // and currency defaults to USD in InstrumentQuoteService._candidateFrom.
      expect(ubs.resolvedSymbol, 'UBS');
      expect(ubs.exchange == null || ubs.exchange == 'US', isTrue);

      // Wait for the live Yahoo quote to land; a USD quote in a CHF account
      // must surface as currencyMismatch (market-quote-currency).
      QuoteUse? use;
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 250));
        if (viewModel.holdings.isEmpty) continue;
        use = viewModel.displayQuoteUse(viewModel.holdings.single);
        if (use == QuoteUse.currencyMismatch || use == QuoteUse.live) break;
      }

      expect(viewModel.holdings, hasLength(1));
      expect(
        use,
        QuoteUse.currencyMismatch,
        reason:
            'NYSE UBS quote is USD in a CHF account — expected '
            'currencyMismatch, got $use',
      );
      expect(find.textContaining('price currency differs'), findsOneWidget);
    },
  );
}
