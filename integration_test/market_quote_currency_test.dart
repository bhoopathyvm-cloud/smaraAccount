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
import 'package:smara_accounting/domain/investment/investment_holdings.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/instrument.dart';
import 'package:smara_accounting/domain/models/instrument_quote.dart';
import 'package:smara_accounting/domain/models/quote_provider.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/holdings/view_models/holdings_view_model.dart';
import 'package:smara_accounting/ui/features/holdings/views/holdings_view.dart';

import '../test/domain/crypto/in_memory_secure_key_storage.dart';

/// A quote service that returns a canned [FetchedQuote] regardless of the
/// symbol, so the holdings valuation path can be driven end to end without a
/// live network. Injected through [InstrumentQuoteRefresh]'s constructor seam
/// (design.md Decision 3).
///
/// It delivers the quote only once and then returns `null`: the view model
/// re-runs a quote refresh every time the holdings stream emits, and caching
/// a quote itself re-triggers that stream, so a service that answered on
/// every call would spin the fake in a tight loop (the real app is paced only
/// by network latency). Delivering once lets the cached quote settle.
class _CannedQuoteService extends InstrumentQuoteService {
  _CannedQuoteService(this.quote);

  final FetchedQuote? quote;
  bool _delivered = false;

  @override
  Future<FetchedQuote?> fetchQuote({
    required QuoteProvider provider,
    String? ticker,
    String? isin,
  }) async {
    if (_delivered) return null;
    _delivered = true;
    return quote;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SigningKeyService signingKeyService;
  late LedgerRepository repository;
  late AccountRepository accountRepository;
  late CategoryRepository categoryRepository;
  late IdentityRepository identityRepository;
  late InvestmentRepository investmentRepository;
  late SettingsRepository settingsRepository;

  setUp(() async {
    // Run headless: an in-memory async preferences store stands in for the
    // platform plugin so SettingsRepository works without a real device.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    signingKeyService = SigningKeyService(
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
    identityRepository = IdentityRepository(
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
    final generated = await identityRepository.generateFirstIdentity();
    await identityRepository.confirmFirstIdentity(generated, currency: 'CHF');
    // Value the investments group in CHF, mirroring the on-device CHF
    // "shares" account that surfaced the bug.
    await accountRepository.changeAccountGroupCurrency(
      groupId: groupInvestmentsId,
      currency: 'CHF',
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> incomeId() async {
    final categories = await categoryRepository.watchCategories().first;
    return categories.firstWhere((a) => a.type == AccountType.income).id;
  }

  // Seed the on-device repro: a CHF investment account holding 1000 units of
  // an instrument (ticker `ubsg.ch`) bought at 1.00 CHF (book cost 1000 CHF),
  // with 4000 CHF cash left after the buy. Returns the account id.
  Future<String> seedChfBrokerage() async {
    final account = await accountRepository.createFinancialAccount(
      name: 'Swiss Brokerage',
      type: AccountType.asset,
      groupId: groupInvestmentsId,
      holdsInvestments: true,
    );
    // 5000 CHF income into the account, in the account's own currency (no
    // cross-currency transfer), so the cash after a 1000 CHF buy is 4000.
    await repository.recordTransaction(
      amountMinor: 500000,
      direction: TransactionDirection.moneyIn,
      categoryId: await incomeId(),
      financialAccountId: account.id,
      transactionDate: DateTime(2026, 1, 1),
    );
    final instrument = await investmentRepository.createInstrument(
      name: 'UBS Group',
      kind: InstrumentKind.stock,
      ticker: 'ubsg.ch',
    );
    await investmentRepository.recordBuy(
      accountId: account.id,
      instrumentId: instrument.id,
      quantityScaled: 1000 * 10000,
      unitPriceMinor: 100,
      transactionDate: DateTime(2026, 1, 2),
      fundingSource: BuyFundingSource.cash,
    );
    return account.id;
  }

  Future<HoldingsViewModel> pumpHoldings(
    WidgetTester tester,
    String accountId,
    FetchedQuote? quote,
  ) async {
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
        quoteService: _CannedQuoteService(quote),
      ),
    );
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      MaterialApp(home: HoldingsView(viewModel: viewModel)),
    );
    // Let the holdings stream emit, the cash balance resolve, the quote cache
    // write, and the holdings stream re-emit with the quote applied.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    return viewModel;
  }

  testWidgets(
    'a CHF quote is applied: Market estimate and Unrealized use the quote, '
    'not book cost',
    (tester) async {
      final accountId = await seedChfBrokerage();
      final viewModel = await pumpHoldings(
        tester,
        accountId,
        const FetchedQuote(priceMinor: 2500, currency: 'CHF'),
      );

      expect(viewModel.currency, 'CHF');
      expect(viewModel.holdings, hasLength(1));
      final holding = viewModel.holdings.single;

      // 1000 units × 25.00 CHF = 25,000.00 CHF market contribution.
      expect(holding.displayMarketValueMinor, 2500000);
      // 25,000.00 − 1,000.00 book cost = +24,000.00 CHF.
      expect(holding.displayUnrealizedMinor, 2400000);
      expect(viewModel.displayQuoteUse(holding), QuoteUse.live);

      // Book = cash 4000 + book cost 1000 = 5000.00 CHF.
      expect(viewModel.bookMinor, 500000);
      // Market estimate = cash 4000 + market 25000 = 29,000.00 CHF.
      expect(viewModel.portfolioMinor, 2900000);
    },
  );

  testWidgets(
    'a USD quote for a CHF account falls back to book and is labeled a '
    'currency mismatch, not a missing quote',
    (tester) async {
      final accountId = await seedChfBrokerage();
      final viewModel = await pumpHoldings(
        tester,
        accountId,
        const FetchedQuote(priceMinor: 2500, currency: 'USD'),
      );

      final holding = viewModel.holdings.single;
      // Foreign-currency quote is not multiplied in: value stays book cost.
      expect(holding.displayMarketValueMinor, 100000);
      expect(holding.displayUnrealizedMinor, 0);
      expect(viewModel.displayQuoteUse(holding), QuoteUse.currencyMismatch);

      // Market estimate falls back to Book (both 5000.00 CHF).
      expect(viewModel.portfolioMinor, 500000);
      expect(viewModel.bookMinor, 500000);
    },
  );
}
