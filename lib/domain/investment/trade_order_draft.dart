import '../../data/repositories/investment_holdings_logic.dart';
import '../models/instrument.dart';
import '../models/instrument_holding.dart';

export '../../data/repositories/investment_holdings_logic.dart'
    show BuyFundingSource;

/// Mutable buy-dialog state: funding-source visibility and submit readiness.
class BuyOrderDraft {
  BuyFundingSource funding = BuyFundingSource.cash;
  String? instrumentId;
  String? incomeCategoryId;
  String? brokerageCategoryId;
  int? quantityScaled;
  int? unitPriceMinor;
  int? brokerageMinor;
  DateTime transactionDate = DateTime.now();
  DateTime? lockedUntil;
  String description = '';
  bool creatingNew = false;
  String newInstrumentName = '';
  InstrumentKind newKind = InstrumentKind.stock;
  String ticker = '';
  String isin = '';

  bool get requiresIncomeCategory => funding == BuyFundingSource.nonCash;

  bool get requiresBrokerageCategory => funding == BuyFundingSource.cash;

  bool get canSubmit {
    if (quantityScaled == null || unitPriceMinor == null) return false;
    if (creatingNew) return newInstrumentName.trim().isNotEmpty;
    return instrumentId != null;
  }

  String? get descriptionOrNull {
    final trimmed = description.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? get tickerOrNull {
    final trimmed = ticker.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? get isinOrNull {
    final trimmed = isin.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Mutable sell-dialog state: gain/loss-sign category visibility.
class SellOrderDraft {
  SellOrderDraft({required this.holding});

  InstrumentHolding holding;
  String? gainIncomeCategoryId;
  String? lossExpenseCategoryId;
  String? brokerageCategoryId;
  int? quantityScaled;
  int? unitPriceMinor;
  int? brokerageMinor;
  DateTime transactionDate = DateTime.now();
  String description = '';

  int? get gainLossMinor {
    final quantity = quantityScaled;
    final price = unitPriceMinor;
    if (quantity == null || price == null || quantity <= 0 || price <= 0) {
      return null;
    }
    final proceeds = multiplyScaledQuantityPrice(quantity, price);
    final cost = multiplyScaledQuantityPrice(
      quantity,
      holding.averageCostMinor,
    );
    return proceeds - cost;
  }

  bool get requiresIncomeCategory {
    final gainLoss = gainLossMinor;
    return gainLoss != null && gainLoss > 0;
  }

  bool get requiresExpenseCategory {
    final gainLoss = gainLossMinor;
    return gainLoss != null && gainLoss < 0;
  }

  bool get canSubmit => quantityScaled != null && unitPriceMinor != null;

  String? get descriptionOrNull {
    final trimmed = description.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Mutable dividend-dialog state: held-instrument list and submit readiness.
class DividendOrderDraft {
  DividendOrderDraft({required this.eligibleInstruments, this.instrumentId});

  List<Instrument> eligibleInstruments;
  String? instrumentId;
  String? incomeCategoryId;
  int? amountMinor;
  DateTime transactionDate = DateTime.now();
  String description = '';

  bool get canSubmit =>
      instrumentId != null && amountMinor != null && incomeCategoryId != null;

  String? get descriptionOrNull {
    final trimmed = description.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
