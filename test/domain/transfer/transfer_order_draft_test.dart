import 'package:test/test.dart';

import 'package:smara_accounting/domain/transfer/transfer_order_draft.dart';

void main() {
  group('TransferOrderDraft', () {
    test('isCrossCurrency when from/to currencies differ', () {
      final draft = TransferOrderDraft()
        ..fromCurrency = 'USD'
        ..toCurrency = 'EUR';
      expect(draft.isCrossCurrency, isTrue);
      draft.toCurrency = 'USD';
      expect(draft.isCrossCurrency, isFalse);
    });

    test('fee deducted from amount reduces transferAmountMinor', () {
      final draft = TransferOrderDraft()
        ..amountMinor = 10000
        ..feeAmountMinor = 162
        ..feeDeductedFromAmount = true;
      expect(draft.transferAmountMinor, 9838);
    });

    test('fee not deducted leaves transferAmountMinor equal to amount', () {
      final draft = TransferOrderDraft()
        ..amountMinor = 10000
        ..feeAmountMinor = 162
        ..feeDeductedFromAmount = false;
      expect(draft.transferAmountMinor, 10000);
    });

    test('feeExceedsAmountWhenDeducted when fee >= amount', () {
      final draft = TransferOrderDraft()
        ..amountMinor = 100
        ..feeAmountMinor = 100
        ..feeDeductedFromAmount = true;
      expect(draft.transferAmountMinor, isNull);
      expect(draft.feeExceedsAmountWhenDeducted, isTrue);
    });

    test('impliedRate uses converted amount after fee deduction', () {
      final draft = TransferOrderDraft()
        ..fromCurrency = 'USD'
        ..toCurrency = 'EUR'
        ..amountMinor = 10000
        ..destinationAmountMinor = 9000
        ..feeAmountMinor = 200
        ..feeDeductedFromAmount = true;
      // converted = 98.00 USD → 90.00 EUR → rate 90/98
      expect(draft.impliedRate, closeTo(90 / 98, 1e-9));
    });

    test('impliedRate without fee uses full amount', () {
      final draft = TransferOrderDraft()
        ..fromCurrency = 'USD'
        ..toCurrency = 'EUR'
        ..amountMinor = 10000
        ..destinationAmountMinor = 9000;
      expect(draft.impliedRate, closeTo(0.9, 1e-9));
    });

    test('feeInvalid when fee present without category', () {
      final draft = TransferOrderDraft()..feeAmountMinor = 100;
      expect(draft.feeInvalid, isTrue);
      draft.feeCategoryId = 'fee-cat';
      expect(draft.feeInvalid, isFalse);
    });

    test('setFromAccountId clears to when same id', () {
      final draft = TransferOrderDraft()
        ..fromAccountId = 'a'
        ..toAccountId = 'b';
      draft.setFromAccountId('b');
      expect(draft.toAccountId, isNull);
    });
  });
}
