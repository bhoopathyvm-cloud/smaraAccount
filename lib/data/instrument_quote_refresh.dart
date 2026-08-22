import '../domain/models/instrument.dart';
import '../domain/models/quote_provider.dart';
import 'instrument_quote_service.dart';
import 'repositories/ledger_repository.dart';
import 'repositories/settings_repository.dart';

/// Fetches quotes for instruments that have a ticker or ISIN and writes
/// the cache. Never sends quantity, cost, or account identifiers.
class InstrumentQuoteRefresh {
  InstrumentQuoteRefresh({
    required this.settingsRepository,
    required this.ledgerRepository,
    InstrumentQuoteService? quoteService,
  }) : _quoteService = quoteService ?? InstrumentQuoteService();

  final SettingsRepository settingsRepository;
  final LedgerRepository ledgerRepository;
  final InstrumentQuoteService _quoteService;

  Future<void> refresh(List<Instrument> instruments) async {
    final enabled = await settingsRepository.isMarketPriceFetchEnabled();
    if (!enabled) return;
    final provider = await settingsRepository.selectedQuoteProvider();
    for (final instrument in instruments) {
      final ticker = instrument.ticker?.trim();
      final isin = instrument.isin?.trim();
      if ((ticker == null || ticker.isEmpty) &&
          (isin == null || isin.isEmpty)) {
        continue;
      }
      final fetched = await _quoteService.fetchQuote(
        provider: provider,
        ticker: ticker,
        isin: isin,
      );
      if (fetched == null) continue;
      await ledgerRepository.cacheInstrumentQuote(
        instrumentId: instrument.id,
        priceMinor: fetched.priceMinor,
        currency: fetched.currency,
      );
    }
  }

  QuoteProvider get defaultProvider => QuoteProvider.stooq;
}
