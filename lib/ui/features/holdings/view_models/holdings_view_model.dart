import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/instrument_quote_refresh.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/investment_repository.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/investment/trade_order_draft.dart';
import '../../../../l10n/l10n.dart';
import '../../../../domain/investment_research_prompt.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_currency_catalog.dart';
import '../../../../domain/models/instrument.dart';
import '../../../../domain/models/instrument_holding.dart';
import '../../../../domain/models/instrument_quote.dart';

enum ResearchLaunchResult { opened, copied }

/// Holdings screen for one investment account: cash, inventory, buy/sell/
/// dividend, instrument housekeeping, and quote refresh while visible.
class HoldingsViewModel extends ChangeNotifier with LocalizedErrorMixin {
  HoldingsViewModel({
    required LedgerRepository ledgerRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    required InvestmentRepository investmentRepository,
    required SettingsRepository settingsRepository,
    required this.accountId,
    InstrumentQuoteRefresh? quoteRefresh,
    Future<bool> Function(Uri url)? launchUrlFn,
    Future<void> Function(String text)? copyTextFn,
  }) : _ledgerRepository = ledgerRepository,
       _accountRepository = accountRepository,
       _categoryRepository = categoryRepository,
       _investmentRepository = investmentRepository,
       _settingsRepository = settingsRepository,
       _quoteRefresh =
           quoteRefresh ??
           InstrumentQuoteRefresh(
             settingsRepository: settingsRepository,
             investmentRepository: investmentRepository,
           ),
       _launchUrl =
           launchUrlFn ??
           ((uri) => launchUrl(uri, mode: LaunchMode.externalApplication)),
       _copyText =
           copyTextFn ??
           ((text) => Clipboard.setData(ClipboardData(text: text))) {
    _accountsSub = _accountRepository
        .watchFinancialAccounts(includeArchived: true)
        .listen((accounts) {
          _account = accounts.where((a) => a.id == accountId).firstOrNull;
          notifyListeners();
        });
    _holdingsSub = _investmentRepository
        .watchHoldingsForAccount(accountId)
        .listen((holdings) async {
          _holdings = holdings;
          _cashMinor = await _ledgerRepository.displayBalanceMinor(accountId);
          notifyListeners();
          await _refreshQuotes();
        });
    _instrumentsSub = _investmentRepository.watchInstruments().listen((
      instruments,
    ) {
      _instruments = instruments;
      notifyListeners();
    });
    _heldInstrumentsSub = _investmentRepository
        .watchInstrumentsHeldInAccount(accountId)
        .listen((instruments) {
          _heldInstruments = instruments;
          notifyListeners();
        });
    _categoriesSub = _categoryRepository.watchCategories().listen((categories) {
      _categories = categories;
      notifyListeners();
    });
    _currenciesSub = _accountRepository
        .watchAccountCurrencies(includeArchived: true)
        .listen((catalog) {
          _currencies = catalog;
          notifyListeners();
        });
    _settingsRepository.isMarketPriceFetchEnabled().then((enabled) {
      _quotesEnabled = enabled;
      notifyListeners();
    });
    _quoteTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      unawaited(_refreshQuotes());
    });
  }

  final LedgerRepository _ledgerRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
  final InvestmentRepository _investmentRepository;
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
  late final StreamSubscription<AccountCurrencyCatalog> _currenciesSub;
  Timer? _quoteTimer;

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

  AccountCurrencyCatalog _currencies = AccountCurrencyCatalog.empty;

  String get currency => _currencies.currencyFor(accountId) ?? 'USD';

  void clearError() => clearFailure();

  bool get isArchived => _account?.archived ?? false;

  Future<void> _refreshQuotes() {
    return _quoteRefresh.refresh(_instruments);
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
      final created = await _investmentRepository.createInstrument(
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
      () => _investmentRepository.renameInstrument(id: id, newName: newName),
    );
  }

  Future<bool> archiveInstrument(String id) {
    return _run(() => _investmentRepository.archiveInstrument(id));
  }

  BuyOrderDraft newBuyDraft() => BuyOrderDraft();

  SellOrderDraft newSellDraft() => SellOrderDraft(holding: holdings.first);

  DividendOrderDraft newDividendDraft() {
    return DividendOrderDraft(
      eligibleInstruments: heldInstruments,
      instrumentId: heldInstruments.first.id,
    );
  }

  Future<bool> submitBuy(BuyOrderDraft draft) {
    return _run(
      () => _investmentRepository.recordBuy(
        accountId: accountId,
        instrumentId: draft.instrumentId!,
        quantityScaled: draft.quantityScaled!,
        unitPriceMinor: draft.unitPriceMinor!,
        transactionDate: draft.transactionDate,
        fundingSource: draft.funding,
        incomeCategoryId: draft.incomeCategoryId,
        lockedUntil: draft.lockedUntil,
        description: draft.descriptionOrNull,
        brokerageMinor: draft.brokerageMinor,
        brokerageExpenseCategoryId: draft.brokerageCategoryId,
      ),
    );
  }

  Future<bool> submitSell(SellOrderDraft draft) {
    return _run(
      () => _investmentRepository.recordSell(
        accountId: accountId,
        instrumentId: draft.holding.instrument.id,
        quantityScaled: draft.quantityScaled!,
        unitPriceMinor: draft.unitPriceMinor!,
        transactionDate: draft.transactionDate,
        gainIncomeCategoryId: draft.gainIncomeCategoryId,
        lossExpenseCategoryId: draft.lossExpenseCategoryId,
        description: draft.descriptionOrNull,
        brokerageMinor: draft.brokerageMinor,
        brokerageExpenseCategoryId: draft.brokerageCategoryId,
      ),
    );
  }

  Future<bool> submitDividend(DividendOrderDraft draft) {
    return _run(
      () => _investmentRepository.recordDividend(
        accountId: accountId,
        instrumentId: draft.instrumentId!,
        amountMinor: draft.amountMinor!,
        transactionDate: draft.transactionDate,
        incomeCategoryId: draft.incomeCategoryId!,
        description: draft.descriptionOrNull,
      ),
    );
  }

  Future<ResearchLaunchResult> researchInstrument(
    AppLocalizations l10n,
    Instrument instrument,
  ) async {
    final tool = await _settingsRepository.selectedResearchTool();
    final prompt = buildInvestmentResearchPrompt(l10n, instrument);
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
    _quoteTimer?.cancel();
    _accountsSub.cancel();
    _holdingsSub.cancel();
    _instrumentsSub.cancel();
    _heldInstrumentsSub.cancel();
    _categoriesSub.cancel();
    _currenciesSub.cancel();
    super.dispose();
  }
}
