import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_currency_catalog.dart';
import 'package:smara_accounting/domain/models/instrument.dart';
import 'package:smara_accounting/domain/models/instrument_holding.dart';
import 'package:smara_accounting/ui/features/holdings/view_models/holdings_view_model.dart';

import '../../../../mocks.mocks.dart';

// Teardown-safety for HoldingsViewModel's async stream listener (spec:
// internal-architecture, "async stream listeners must not raise, notify, or
// read a closed resource after dispose()"). Mirrors the register view model's
// dispose-guard tests.
void main() {
  late MockLedgerRepository ledger;
  late MockInvestmentRepository investment;
  late MockAccountRepository accountRepository;
  late MockCategoryRepository categoryRepository;
  late MockSettingsRepository settings;

  const apple = Instrument(
    id: 'inst-1',
    name: 'Apple Inc',
    kind: InstrumentKind.stock,
    ticker: 'AAPL',
    archived: false,
  );

  const holding = InstrumentHolding(
    instrument: apple,
    quantityScaled: 10000,
    averageCostMinor: 10000,
    totalCostMinor: 10000,
    sellableQuantityScaled: 10000,
    marketValueMinor: 12000,
    unrealizedGainLossMinor: 2000,
  );

  const account = Account(
    id: 'inv-1',
    name: 'Brokerage',
    type: AccountType.asset,
    archived: false,
    groupId: 'group_investments',
    holdsInvestments: true,
  );

  setUp(() {
    ledger = MockLedgerRepository();
    investment = MockInvestmentRepository();
    accountRepository = MockAccountRepository();
    categoryRepository = MockCategoryRepository();
    settings = MockSettingsRepository();
    when(
      accountRepository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([account]));
    when(
      investment.watchInstruments(),
    ).thenAnswer((_) => Stream.value([apple]));
    when(
      investment.watchInstrumentsHeldInAccount(any),
    ).thenAnswer((_) => Stream.value([apple]));
    when(
      categoryRepository.watchCategories(),
    ).thenAnswer((_) => Stream.value(const []));
    when(
      accountRepository.watchAccountCurrencies(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer(
      (_) => Stream.value(const AccountCurrencyCatalog({'inv-1': 'USD'})),
    );
    when(settings.isMarketPriceFetchEnabled()).thenAnswer((_) async => false);
  });

  HoldingsViewModel buildViewModel() => HoldingsViewModel(
    ledgerRepository: ledger,
    accountRepository: accountRepository,
    categoryRepository: categoryRepository,
    investmentRepository: investment,
    settingsRepository: settings,
    accountId: 'inv-1',
  );

  test(
    'holdings stream emits, then dispose() runs before the awaited balance '
    'read completes: nothing throws and no notifyListeners after dispose',
    () async {
      final holdingsController =
          StreamController<List<InstrumentHolding>>.broadcast();
      when(
        investment.watchHoldingsForAccount(any),
      ).thenAnswer((_) => holdingsController.stream);
      // The balance read is held pending so the async listener is suspended
      // mid-await exactly when dispose() runs.
      final balance = Completer<int>();
      when(
        ledger.displayBalanceMinor(any),
      ).thenAnswer((_) => balance.future);

      final viewModel = buildViewModel();
      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      holdingsController.add([holding]);
      await pumpEventQueue();

      // Listener is now suspended at `await displayBalanceMinor(...)`.
      viewModel.dispose();
      final notifyCountAtDispose = notifyCount;

      // Resolve the in-flight read after disposal: the continuation must
      // bail out instead of assigning state or notifying a dead notifier
      // (which would throw "used after being disposed" into the zone).
      balance.complete(40000);
      await pumpEventQueue();

      expect(
        notifyCount,
        notifyCountAtDispose,
        reason: 'notifyListeners must not fire after dispose()',
      );

      await holdingsController.close();
    },
  );

  test('a stream error while the view model is alive still propagates', () async {
    final instrumentsController = StreamController<List<Instrument>>.broadcast();
    when(
      investment.watchInstruments(),
    ).thenAnswer((_) => instrumentsController.stream);
    when(ledger.displayBalanceMinor(any)).thenAnswer((_) async => 40000);
    when(
      investment.watchHoldingsForAccount(any),
    ).thenAnswer((_) => Stream.value([holding]));

    Object? caught;
    await runZonedGuarded(
      () async {
        final viewModel = buildViewModel();
        await pumpEventQueue();
        // Delivered while still alive → must not be swallowed.
        instrumentsController.addError(StateError('stream boom'));
        await pumpEventQueue();
        viewModel.dispose();
      },
      (error, stack) => caught = error,
    );

    expect(caught, isStateError);
    await instrumentsController.close();
  });
}
