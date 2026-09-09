import 'package:test/test.dart';

import 'package:smara_accounting/domain/transfer/closeout_transfer_draft.dart';

void main() {
  group('CloseoutTransferDraft', () {
    test(
      'same-currency closeout is not cross-currency and submits null amount',
      () {
        final draft = CloseoutTransferDraft(sourceCurrency: 'USD')
          ..setDestinationAccount('acct-2', 'USD')
          ..destinationAmountMinor = 5000;
        expect(draft.isCrossCurrency, isFalse);
        // A same-currency closeout moves the full source balance, so no
        // destination amount is carried even if one was set.
        expect(draft.destinationAmountForSubmit, isNull);
      },
    );

    test('cross-currency closeout submits the entered destination amount', () {
      final draft = CloseoutTransferDraft(sourceCurrency: 'USD')
        ..setDestinationAccount('acct-2', 'EUR')
        ..destinationAmountMinor = 4200;
      expect(draft.isCrossCurrency, isTrue);
      expect(draft.destinationAmountForSubmit, 4200);
    });

    test('changing the destination account clears the previous amount', () {
      final draft = CloseoutTransferDraft(sourceCurrency: 'USD')
        ..setDestinationAccount('acct-2', 'EUR')
        ..destinationAmountMinor = 4200;
      draft.setDestinationAccount('acct-3', 'GBP');
      expect(draft.toAccountId, 'acct-3');
      expect(draft.destinationCurrency, 'GBP');
      expect(draft.destinationAmountMinor, isNull);
    });

    test('hasDestinationAccount gates submission', () {
      final draft = CloseoutTransferDraft(sourceCurrency: 'USD');
      expect(draft.hasDestinationAccount, isFalse);
      draft.setDestinationAccount('acct-2', 'USD');
      expect(draft.hasDestinationAccount, isTrue);
    });

    test('unknown currencies are treated as not cross-currency', () {
      final draft = CloseoutTransferDraft(sourceCurrency: null)
        ..setDestinationAccount('acct-2', 'EUR');
      expect(draft.isCrossCurrency, isFalse);
    });
  });
}
