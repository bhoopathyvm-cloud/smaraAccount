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

/// Fakes the Save-time identifier search and the market-price fetch for one
/// real-world ISIN (`CH0244767585`, UBS) with two listings — a Swiss one in
/// CHF and a US one in USD — so `instrument-identifier-assist`'s
/// resolve-and-confirm flow can be driven end to end through the real
/// Add-instrument dialog without a live network (design.md Decision 4/5).
class _ResolvingQuoteService extends InstrumentQuoteService {
  static const chfCandidate = InstrumentCandidate(
    name: 'UBS Group AG',
    symbol: 'UBSG.SW',
    exchangeDisplay: 'SIX Swiss Exchange',
    currency: 'CHF',
    exchangeCode: 'SIX',
  );

  static const usdCandidate = InstrumentCandidate(
    name: 'UBS Group AG',
    symbol: 'UBS',
    exchangeDisplay: 'NYSE',
    currency: 'USD',
    exchangeCode: 'US',
  );

  @override
  Future<List<InstrumentCandidate>> searchIdentifier(String query) async {
    if (query.trim().toUpperCase() != 'CH0244767585') return const [];
    return const [chfCandidate, usdCandidate];
  }

  // Delivered only once: caching a quote re-triggers the holdings stream,
  // which re-triggers a refresh - a service that answered on every call
  // would spin in a tight loop (same reasoning as
  // market_quote_currency_test.dart's _CannedQuoteService).
  bool _delivered = false;

  @override
  Future<FetchedQuote?> fetchQuote({
    required QuoteProvider provider,
    String? ticker,
    String? isin,
    String? symbol,
  }) async {
    if (_delivered || symbol != chfCandidate.symbol) return null;
    _delivered = true;
    return const FetchedQuote(priceMinor: 2500, currency: 'CHF');
  }
}

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
    // Bias the confirm sheet toward the CHF/SIX listing, matching the
    // account currency below (instrument-identifier-assist design.md
    // Decision 3: pre-selection follows the Default-exchange setting).
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
    // Cash to fund the buy through the real dialog.
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
    'creating "UBS" with ISIN CH0244767585 shows both listings, pre-selects '
    'the CHF one, stores only on confirm, and holdings then use the CHF '
    'quote (market-quote-currency applied)',
    (tester) async {
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
          quoteService: _ResolvingQuoteService(),
        ),
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
        find.widgetWithText(TextField, 'ISIN (optional)'),
        'CH0244767585',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Quantity'),
        '1000',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Unit price'),
        '1.00',
      );
      await tester.pump();

      await tester.tap(find.text('Record buy'));
      // The identifier search runs, then the confirm bottom sheet opens -
      // pump past both async gaps rather than a single settle, which would
      // stop at the first frame with no further scheduled work.
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      // Both listings shown, CHF/SIX pre-selected per the Default-exchange
      // setting above.
      expect(find.text('Confirm the listing'), findsOneWidget);
      expect(find.textContaining('UBSG.SW'), findsOneWidget);
      expect(find.textContaining('UBS'), findsWidgets);
      final radioGroup = tester.widget<RadioGroup<InstrumentCandidate>>(
        find.byType(RadioGroup<InstrumentCandidate>),
      );
      expect(radioGroup.groupValue?.symbol, 'UBSG.SW');

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Instrument persisted with the confirmed CHF/SIX resolution, not the
      // USD one - and only now, after confirmation.
      final instruments = await investmentRepository.watchInstruments().first;
      final ubs = instruments.singleWhere((i) => i.name == 'UBS');
      expect(ubs.resolvedSymbol, 'UBSG.SW');
      expect(ubs.exchange, 'SIX');

      // Let the holdings stream re-emit with the cached quote applied
      // (same settle loop market_quote_currency_test.dart uses).
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(viewModel.holdings, hasLength(1));
      final holding = viewModel.holdings.single;
      // 1000 units x 25.00 CHF quote = 25,000.00 CHF market contribution.
      expect(holding.displayMarketValueMinor, 2500000);
      // 25,000.00 - 1,000.00 book cost (1000 units x 1.00 CHF entered unit
      // price) = +24,000.00 CHF.
      expect(holding.displayUnrealizedMinor, 2400000);
      expect(viewModel.displayQuoteUse(holding), QuoteUse.live);
    },
  );
}
