import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/instrument_quote_refresh.dart';
import '../../../../data/repositories/investment_holdings_logic.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';
import '../../../../domain/investment_research_prompt.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';
import '../../../../domain/models/instrument.dart';
import '../../../../domain/models/instrument_holding.dart';
import '../../../../domain/models/instrument_quote.dart';

enum ResearchLaunchResult { opened, copied }

/// Test-only observation hook for the real research-launch path. Null in
/// production and in every other build. `app_router.dart` constructs
/// `HoldingsViewModel` without a `launchUrlFn` override, so the
/// acceptance-investment-research suite (which runs the real, unmodified
/// app - no ViewModel-construction backdoors) has no other way to see the
/// launched URI: the real `url_launcher` genuinely opens a system browser
/// on a live macOS run, which steals window focus and hangs the test
/// indefinitely (confirmed empirically - design.md Decision 2's
/// "capture hook" fallback). When set, `HoldingsViewModel`'s default
/// launcher calls this instead of `url_launcher`, so the suite can assert
/// on the prompt without ever opening a real browser.
@visibleForTesting
Future<bool> Function(Uri uri)? debugResearchLaunchInterceptor;

/// Holdings screen for one investment account: cash, inventory, buy/sell/
/// dividend, instrument housekeeping, and quote refresh while visible.
class HoldingsViewModel extends ChangeNotifier with LocalizedErrorMixin {
  HoldingsViewModel({
    required LedgerRepository ledgerRepository,
    required SettingsRepository settingsRepository,
    required this.accountId,
    InstrumentQuoteRefresh? quoteRefresh,
    Future<bool> Function(Uri url)? launchUrlFn,
    Future<void> Function(String text)? copyTextFn,
  }) : _ledgerRepository = ledgerRepository,
       _settingsRepository = settingsRepository,
       _quoteRefresh =
           quoteRefresh ??
           InstrumentQuoteRefresh(
             settingsRepository: settingsRepository,
             ledgerRepository: ledgerRepository,
           ),
       _launchUrl =
           launchUrlFn ??
           ((uri) =>
               (debugResearchLaunchInterceptor ??
               (uri) =>
                   launchUrl(uri, mode: LaunchMode.externalApplication))(uri)),
       _copyText =
           copyTextFn ??
           ((text) => Clipboard.setData(ClipboardData(text: text))) {
    _accountsSub = _ledgerRepository
        .watchFinancialAccounts(includeArchived: true)
        .listen((accounts) {
          _account = accounts.where((a) => a.id == accountId).firstOrNull;
          notifyListeners();
        }, onError: _ignoreError);
    _holdingsSub = _ledgerRepository.watchHoldingsForAccount(accountId).listen((
      holdings,
    ) async {
      _holdings = holdings;
      try {
        final cashMinor = await _ledgerRepository.displayBalanceMinor(
          accountId,
        );
        if (_disposed) return;
        _cashMinor = cashMinor;
        notifyListeners();
        await _refreshQuotes();
      } catch (_) {
        // The account/database this awaited call reads from can already
        // be gone by the time it resolves - a subscription in-flight when
        // dispose() runs isn't abortable mid-await, only prevented from
        // firing again. Nothing to recover to once the view is gone.
        if (!_disposed) rethrow;
      }
    }, onError: _ignoreError);
    _instrumentsSub = _ledgerRepository.watchInstruments().listen((
      instruments,
    ) {
      _instruments = instruments;
      notifyListeners();
    }, onError: _ignoreError);
    _heldInstrumentsSub = _ledgerRepository
        .watchInstrumentsHeldInAccount(accountId)
        .listen((instruments) {
          _heldInstruments = instruments;
          notifyListeners();
        }, onError: _ignoreError);
    _categoriesSub = _ledgerRepository.watchCategories().listen((categories) {
      _categories = categories;
      notifyListeners();
    }, onError: _ignoreError);
    _groupsSub = _ledgerRepository.watchAccountGroups().listen((groups) {
      _groups = groups;
      notifyListeners();
    }, onError: _ignoreError);
    _settingsRepository.isMarketPriceFetchEnabled().then((enabled) {
      _quotesEnabled = enabled;
      notifyListeners();
    }, onError: _ignoreError);
    _quoteTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      unawaited(_refreshQuotes());
    });
  }

  final LedgerRepository _ledgerRepository;
  final SettingsRepository _settingsRepository;
  final InstrumentQuoteRefresh _quoteRefresh;
  final Future<bool> Function(Uri url) _launchUrl;
  final Future<void> Function(String text) _copyText;
  final String accountId;

  late final StreamSubscription<List<Account>> _accountsSub;
  late final StreamSubscription<List<InstrumentHolding>> _holdingsSub;
  late final StreamSubscription<List<Instrument>> _instrumentsSub;
  late final StreamSubscription<List<Instrument>> _heldInstrumentsSub;
  late final StreamSubscription<List<Account>> _categoriesSub;
  late final StreamSubscription<List<AccountGroup>> _groupsSub;
  Timer? _quoteTimer;
  // `_holdingsSub`'s listener below is async and awaits a database call
  // mid-callback - cancelling a subscription doesn't abort an
  // already-running invocation of its listener, so a value emitted just
  // before dispose can still resolve afterward and touch a closed
  // database connection. Checked after every await in that listener.
  bool _disposed = false;

  // Every watch stream above is subscribed with this as its `onError` -
  // a query mid-flight when the database connection closes (this view's
  // own teardown, or - in the acceptance test suite - the next test's
  // fresh-device reset) surfaces as a stream error, not a call into the
  // data callback, so the try/catch there never sees it. There's nothing
  // a torn-down ViewModel could do with it besides crash the caller.
  void _ignoreError(Object error, [StackTrace? stackTrace]) {}

  Account? _account;
  Account? get account => _account;

  List<InstrumentHolding> _holdings = const [];
  List<InstrumentHolding> get holdings => _holdings;

  List<Instrument> _instruments = const [];
  List<Instrument> get instruments => _instruments;

  List<Instrument> _heldInstruments = const [];
  List<Instrument> get heldInstruments => _heldInstruments;

  List<Account> _categories = const [];
  List<Account> get incomeCategories => _categories
      .where((c) => c.type == AccountType.income && !c.archived)
      .toList();
  List<Account> get expenseCategories => _categories
      .where((c) => c.type == AccountType.expense && !c.archived)
      .toList();

  int _cashMinor = 0;
  int get cashMinor => _cashMinor;

  int get bookMinor =>
      _cashMinor + _holdings.fold<int>(0, (sum, h) => sum + h.totalCostMinor);

  int get portfolioMinor =>
      _cashMinor +
      _holdings.fold<int>(0, (sum, h) => sum + h.displayMarketValueMinor);

  bool _quotesEnabled = true;
  bool get quotesEnabled => _quotesEnabled;

  List<AccountGroup> _groups = const [];

  String get currency {
    final groupId = _account?.groupId;
    if (groupId == null) return 'USD';
    for (final group in _groups) {
      if (group.id == groupId && group.currency != null) {
        return group.currency!;
      }
    }
    return 'USD';
  }

  void clearError() => clearFailure();

  bool get isArchived => _account?.archived ?? false;

  Future<void> _refreshQuotes() async {
    try {
      await _quoteRefresh.refresh(_instruments);
    } catch (_) {
      // A refresh that started before dispose can still be in flight
      // against a since-closed database connection - nothing to recover
      // to once the view is gone, so this is deliberately swallowed
      // rather than surfaced as an unhandled async error.
      if (!_disposed) rethrow;
    }
  }

  Future<bool> _run(Future<void> Function() action) async {
    try {
      await action();
      clearFailure();
      return true;
    } on InvestmentException catch (e) {
      setFailure(e);
    } on AccountGroupException catch (e) {
      setFailure(e);
    } on InvalidTransactionAmountException catch (e) {
      setFailure(e);
    } on PendingTransferException catch (e) {
      // Buy/sell reuse `_requireActiveExpenseCategory` (brokerage fee,
      // realized-loss category), which throws this type even though it's
      // not a transfer - the shared validator's exception, not the caller's.
      setFailure(e);
    }
    return false;
  }

  Future<Instrument?> createInstrument({
    required String name,
    required InstrumentKind kind,
    String? ticker,
    String? isin,
  }) async {
    try {
      final created = await _ledgerRepository.createInstrument(
        name: name,
        kind: kind,
        ticker: ticker,
        isin: isin,
      );
      clearFailure();
      return created;
    } on InvestmentException catch (e) {
      setFailure(e);
    }
    return null;
  }

  Future<bool> renameInstrument({required String id, required String newName}) {
    return _run(
      () => _ledgerRepository.renameInstrument(id: id, newName: newName),
    );
  }

  Future<bool> archiveInstrument(String id) {
    return _run(() => _ledgerRepository.archiveInstrument(id));
  }

  int? sellGainLossMinor({
    required InstrumentHolding holding,
    required int quantityScaled,
    required int unitPriceMinor,
  }) {
    if (quantityScaled <= 0 || unitPriceMinor <= 0) return null;
    final proceeds = multiplyScaledQuantityPrice(
      quantityScaled,
      unitPriceMinor,
    );
    final cost = multiplyScaledQuantityPrice(
      quantityScaled,
      holding.averageCostMinor,
    );
    return proceeds - cost;
  }

  Future<bool> recordBuy({
    required String instrumentId,
    required int quantityScaled,
    required int unitPriceMinor,
    required DateTime transactionDate,
    required BuyFundingSource fundingSource,
    String? incomeCategoryId,
    DateTime? lockedUntil,
    String? description,
    int? brokerageMinor,
    String? brokerageExpenseCategoryId,
  }) {
    return _run(
      () => _ledgerRepository.recordBuy(
        accountId: accountId,
        instrumentId: instrumentId,
        quantityScaled: quantityScaled,
        unitPriceMinor: unitPriceMinor,
        transactionDate: transactionDate,
        fundingSource: fundingSource,
        incomeCategoryId: incomeCategoryId,
        lockedUntil: lockedUntil,
        description: description,
        brokerageMinor: brokerageMinor,
        brokerageExpenseCategoryId: brokerageExpenseCategoryId,
      ),
    );
  }

  Future<bool> recordSell({
    required String instrumentId,
    required int quantityScaled,
    required int unitPriceMinor,
    required DateTime transactionDate,
    String? gainIncomeCategoryId,
    String? lossExpenseCategoryId,
    String? description,
    int? brokerageMinor,
    String? brokerageExpenseCategoryId,
  }) {
    return _run(
      () => _ledgerRepository.recordSell(
        accountId: accountId,
        instrumentId: instrumentId,
        quantityScaled: quantityScaled,
        unitPriceMinor: unitPriceMinor,
        transactionDate: transactionDate,
        gainIncomeCategoryId: gainIncomeCategoryId,
        lossExpenseCategoryId: lossExpenseCategoryId,
        description: description,
        brokerageMinor: brokerageMinor,
        brokerageExpenseCategoryId: brokerageExpenseCategoryId,
      ),
    );
  }

  Future<bool> recordDividend({
    required String instrumentId,
    required int amountMinor,
    required DateTime transactionDate,
    required String incomeCategoryId,
    String? description,
  }) {
    return _run(
      () => _ledgerRepository.recordDividend(
        accountId: accountId,
        instrumentId: instrumentId,
        amountMinor: amountMinor,
        transactionDate: transactionDate,
        incomeCategoryId: incomeCategoryId,
        description: description,
      ),
    );
  }

  Future<ResearchLaunchResult> researchInstrument(Instrument instrument) async {
    final tool = await _settingsRepository.selectedResearchTool();
    final prompt = buildInvestmentResearchPrompt(instrument);
    final uri = researchQueryUri(tool, prompt);
    if (uri != null) {
      try {
        final opened = await _launchUrl(uri);
        if (opened) return ResearchLaunchResult.opened;
      } catch (_) {
        // Fall through to copy.
      }
    }
    await _copyText(prompt);
    return ResearchLaunchResult.copied;
  }

  QuoteUse displayQuoteUse(InstrumentHolding holding) {
    if (!_quotesEnabled) {
      if (holding.quoteUse == QuoteUse.currencyMismatch) {
        return QuoteUse.currencyMismatch;
      }
      return QuoteUse.disabled;
    }
    return holding.quoteUse;
  }

  @override
  void dispose() {
    _disposed = true;
    _quoteTimer?.cancel();
    _accountsSub.cancel();
    _holdingsSub.cancel();
    _instrumentsSub.cancel();
    _heldInstrumentsSub.cancel();
    _categoriesSub.cancel();
    _groupsSub.cancel();
    super.dispose();
  }
}
