import '../domain/investment/exchange_registry.dart';
import '../domain/models/instrument.dart';
import '../domain/models/quote_provider.dart';
import 'instrument_quote_service.dart';
import 'repositories/investment_repository.dart';
import 'repositories/settings_repository.dart';

/// Fetches quotes for instruments that have a ticker or ISIN and writes
/// the cache. Never sends quantity, cost, or account identifiers.
class InstrumentQuoteRefresh {
  InstrumentQuoteRefresh({
    required this.settingsRepository,
    required this.investmentRepository,
    InstrumentQuoteService? quoteService,
  }) : _quoteService = quoteService ?? InstrumentQuoteService();

  final SettingsRepository settingsRepository;
  final InvestmentRepository investmentRepository;
  final InstrumentQuoteService _quoteService;

  Future<void> refresh(List<Instrument> instruments) async {
    final enabled = await settingsRepository.isMarketPriceFetchEnabled();
    if (!enabled) return;
    final provider = await settingsRepository.selectedQuoteProvider();
    final defaultExchange = await settingsRepository.selectedDefaultExchange();
    for (final instrument in instruments) {
      await _refreshOne(instrument, provider, defaultExchange);
    }
  }

  Future<void> _refreshOne(
    Instrument instrument,
    QuoteProvider provider,
    Exchange defaultExchange,
  ) async {
    final ticker = instrument.ticker?.trim();
    final isin = instrument.isin?.trim();
    final hasTicker = ticker != null && ticker.isNotEmpty;
    final hasIsin = isin != null && isin.isNotEmpty;
    if (!hasTicker && !hasIsin) return;

    // Resolve-on-refresh: an instrument saved offline (or before its
    // listing was confirmed) is canonicalised here and the resolved symbol
    // is stored silently for next time (instrument-identifier-assist
    // Decision 4).
    var resolvedSymbol = instrument.resolvedSymbol?.trim();
    var exchange = exchangeForCode(instrument.exchange);
    if (resolvedSymbol == null || resolvedSymbol.isEmpty) {
      final candidate = await _resolve(
        query: hasIsin ? isin : ticker!,
        defaultExchange: defaultExchange,
      );
      if (candidate != null) {
        resolvedSymbol = candidate.symbol;
        exchange = exchangeForCode(candidate.exchangeCode);
        await investmentRepository.setInstrumentResolution(
          id: instrument.id,
          resolvedSymbol: candidate.symbol,
          exchange: candidate.exchangeCode ?? '',
        );
      }
    }

    final symbol = (resolvedSymbol != null && resolvedSymbol.isNotEmpty)
        ? resolvedSymbol
        : (hasTicker ? ticker : isin);

    var fetched = await _quoteService.fetchQuote(
      provider: provider,
      symbol: symbol,
    );

    // National fallback: the resolved exchange's home data source is tried
    // once when the primary provider returns nothing (Decision 5).
    final endpoint = exchange?.nationalEndpoint;
    if (fetched == null && endpoint != null && symbol != null) {
      fetched = await _quoteService.fetchNationalQuote(
        endpoint: endpoint,
        symbol: symbol,
      );
    }

    if (fetched == null) return;
    await investmentRepository.cacheInstrumentQuote(
      instrumentId: instrument.id,
      priceMinor: fetched.priceMinor,
      currency: fetched.currency,
    );
  }

  /// One identifier search, picking the default-exchange listing when
  /// present (the same bias Save-time confirm applies), else the first
  /// candidate. Returns null when the search yields nothing (offline or no
  /// match) so resolution is simply retried next run.
  Future<InstrumentCandidate?> _resolve({
    required String query,
    required Exchange defaultExchange,
  }) async {
    final candidates = await _quoteService.searchIdentifier(query);
    if (candidates.isEmpty) return null;
    for (final candidate in candidates) {
      if (candidate.exchangeCode == defaultExchange.code) return candidate;
    }
    return candidates.first;
  }

  QuoteProvider get defaultProvider => QuoteProvider.stooq;
}
