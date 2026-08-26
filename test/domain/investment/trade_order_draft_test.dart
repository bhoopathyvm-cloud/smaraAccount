import 'package:smara_accounting/domain/investment/trade_order_draft.dart';
import 'package:smara_accounting/domain/models/instrument.dart';
import 'package:smara_accounting/domain/models/instrument_holding.dart';
import 'package:test/test.dart';

void main() {
  group('BuyOrderDraft', () {
    test('cash funding shows brokerage fields, not income category', () {
      final draft = BuyOrderDraft()..funding = BuyFundingSource.cash;
      expect(draft.requiresIncomeCategory, isFalse);
      expect(draft.requiresBrokerageCategory, isTrue);
    });

    test('non-cash funding shows income category, hides brokerage', () {
      final draft = BuyOrderDraft()..funding = BuyFundingSource.nonCash;
      expect(draft.requiresIncomeCategory, isTrue);
      expect(draft.requiresBrokerageCategory, isFalse);
    });

    test('canSubmit requires instrument, quantity, and unit price', () {
      final draft = BuyOrderDraft();
      expect(draft.canSubmit, isFalse);
      draft.instrumentId = 'inst-1';
      expect(draft.canSubmit, isFalse);
      draft.quantityScaled = 10000;
      expect(draft.canSubmit, isFalse);
      draft.unitPriceMinor = 1500;
      expect(draft.canSubmit, isTrue);
    });

    test('creating a new instrument needs a name instead of an id', () {
      final draft = BuyOrderDraft()
        ..creatingNew = true
        ..quantityScaled = 10000
        ..unitPriceMinor = 1500;
      expect(draft.canSubmit, isFalse);
      draft.newInstrumentName = '  ';
      expect(draft.canSubmit, isFalse);
      draft.newInstrumentName = 'New Co';
      expect(draft.canSubmit, isTrue);
    });
  });

  group('SellOrderDraft', () {
    const holding = InstrumentHolding(
      instrument: Instrument(
        id: 'inst-1',
        name: 'Apple Inc',
        kind: InstrumentKind.stock,
        archived: false,
      ),
      quantityScaled: 10000,
      averageCostMinor: 10000,
      totalCostMinor: 10000,
      sellableQuantityScaled: 10000,
    );

    test('positive gain requires income category, not expense', () {
      final draft = SellOrderDraft(holding: holding)
        ..quantityScaled = 10000
        ..unitPriceMinor = 12000;
      expect(draft.gainLossMinor, 2000);
      expect(draft.requiresIncomeCategory, isTrue);
      expect(draft.requiresExpenseCategory, isFalse);
    });

    test('negative gain requires expense category, not income', () {
      final draft = SellOrderDraft(holding: holding)
        ..quantityScaled = 10000
        ..unitPriceMinor = 8000;
      expect(draft.gainLossMinor, -2000);
      expect(draft.requiresIncomeCategory, isFalse);
      expect(draft.requiresExpenseCategory, isTrue);
    });

    test('zero gain requires neither category', () {
      final draft = SellOrderDraft(holding: holding)
        ..quantityScaled = 10000
        ..unitPriceMinor = 10000;
      expect(draft.gainLossMinor, 0);
      expect(draft.requiresIncomeCategory, isFalse);
      expect(draft.requiresExpenseCategory, isFalse);
    });

    test('canSubmit requires quantity and unit price', () {
      final draft = SellOrderDraft(holding: holding);
      expect(draft.canSubmit, isFalse);
      draft.quantityScaled = 10000;
      expect(draft.canSubmit, isFalse);
      draft.unitPriceMinor = 11000;
      expect(draft.canSubmit, isTrue);
    });
  });

  group('DividendOrderDraft', () {
    const apple = Instrument(
      id: 'inst-1',
      name: 'Apple Inc',
      kind: InstrumentKind.stock,
      archived: false,
    );

    test('canSubmit requires instrument, amount, and income category', () {
      final draft = DividendOrderDraft(
        eligibleInstruments: const [apple],
        instrumentId: apple.id,
      );
      expect(draft.canSubmit, isFalse);
      draft.amountMinor = 250;
      expect(draft.canSubmit, isFalse);
      draft.incomeCategoryId = 'inc-1';
      expect(draft.canSubmit, isTrue);
    });
  });
}
