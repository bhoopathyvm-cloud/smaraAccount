import 'package:test/test.dart';

import 'package:smara_accounting/domain/investment/investment_holdings.dart';
import 'package:smara_accounting/domain/models/instrument_quote.dart';

void main() {
  group('multiplyScaledQuantityPrice', () {
    test('scales quantity×price by 10000', () {
      expect(multiplyScaledQuantityPrice(10000, 2500), 2500);
      expect(multiplyScaledQuantityPrice(5000, 2000), 1000);
    });
  });

  group('replayInvestmentHistory', () {
    test('buy then sell updates quantity and average cost', () {
      final events = [
        InvestmentReplayEvent(
          kind: InvestmentReplayEventKind.buy,
          transactionDate: DateTime(2026, 1, 1),
          recordedAt: DateTime(2026, 1, 1),
          quantityScaled: 10000,
          unitCostMinor: 1000,
          journalEntryId: 'b1',
        ),
        InvestmentReplayEvent(
          kind: InvestmentReplayEventKind.sell,
          transactionDate: DateTime(2026, 2, 1),
          recordedAt: DateTime(2026, 2, 1),
          quantityScaled: 4000,
          unitCostMinor: 0,
          journalEntryId: 's1',
        ),
      ];
      final metrics = replayInvestmentHistory(
        events,
        asOf: DateTime(2026, 3, 1),
      );
      expect(metrics.quantityScaled, 6000);
      expect(metrics.averageCostMinor, 1000);
      expect(metrics.totalCostMinor, 600);
    });

    test('locked quantity is not sellable before lockedUntil', () {
      final events = [
        InvestmentReplayEvent(
          kind: InvestmentReplayEventKind.buy,
          transactionDate: DateTime(2026, 1, 1),
          recordedAt: DateTime(2026, 1, 1),
          quantityScaled: 10000,
          unitCostMinor: 1000,
          lockedUntil: DateTime(2026, 6, 1),
          journalEntryId: 'b1',
        ),
      ];
      final metrics = replayInvestmentHistory(
        events,
        asOf: DateTime(2026, 3, 1),
      );
      expect(metrics.lockedQuantityScaled, 10000);
      expect(metrics.sellableQuantityScaled, 0);
    });
  });

  group('valueHolding', () {
    test('uses quote price when currency matches', () {
      final quote = InstrumentQuote(
        instrumentId: 'i1',
        priceMinor: 2000,
        currency: 'USD',
        fetchedAt: DateTime(2026, 1, 1),
      );
      final valuation = valueHolding(
        quantityScaled: 10000,
        totalCostMinor: 1000,
        quote: quote,
        groupCurrency: 'USD',
        quotesEnabled: true,
        now: DateTime(2026, 1, 1, 1),
      );
      expect(valuation.marketValueMinor, 2000);
      expect(valuation.quoteUse, QuoteUse.live);
    });

    test('falls back to book cost on currency mismatch', () {
      final quote = InstrumentQuote(
        instrumentId: 'i1',
        priceMinor: 2000,
        currency: 'EUR',
        fetchedAt: DateTime(2026, 1, 1),
      );
      final valuation = valueHolding(
        quantityScaled: 10000,
        totalCostMinor: 1000,
        quote: quote,
        groupCurrency: 'USD',
        quotesEnabled: true,
        now: DateTime(2026, 1, 1, 1),
      );
      expect(valuation.marketValueMinor, 1000);
      expect(valuation.quoteUse, QuoteUse.currencyMismatch);
    });
  });
}
