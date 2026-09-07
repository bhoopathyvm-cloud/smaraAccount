import 'package:test/test.dart';

import 'package:smara_accounting/domain/models/home_overview.dart';
import 'package:smara_accounting/domain/models/pending_transfer.dart';
import 'package:smara_accounting/domain/transfer/settle_pending_draft.dart';

PendingTransferSummary _summary({
  PendingTransferKind kind = PendingTransferKind.transfer,
  String source = 'src',
  String? destination = 'dst',
  int amountMinor = 1000,
  String currency = 'USD',
}) {
  return PendingTransferSummary(
    pendingTransfer: PendingTransfer(
      id: 'p1',
      kind: kind,
      sourceAccountId: source,
      currency: currency,
      provisionalEntryId: 'e1',
      status: PendingTransferStatus.pending,
      initiatedAt: DateTime(2026, 1, 1),
      destinationAccountId: destination,
      categoryId: kind == PendingTransferKind.foreignTransaction ? 'cat' : null,
    ),
    sourceAccountName: 'Source',
    currency: currency,
    amountMinor: amountMinor,
    destinationLabel: 'Dest',
  );
}

void main() {
  group('SettlePendingDraft', () {
    test('defaults transfer settled-to to planned destination', () {
      final draft = SettlePendingDraft(summary: _summary());
      expect(draft.settledToAccountId, 'dst');
      expect(draft.isShortfallComparable, isFalse);
    });

    test('shortfall comparable when settling to source', () {
      final draft = SettlePendingDraft(summary: _summary())
        ..settledToAccountId = 'src'
        ..settledAmountMinor = 700;
      expect(draft.isShortfallComparable, isTrue);
      expect(draft.shortfallMinor, 300);
      expect(draft.settledAmountCurrency, 'USD');
    });

    test('no shortfall when settled amount exceeds provisional', () {
      final draft = SettlePendingDraft(summary: _summary())
        ..settledToAccountId = 'src'
        ..settledAmountMinor = 1200;
      expect(draft.shortfallMinor, 0);
    });

    test('foreign transaction settles to source', () {
      final draft = SettlePendingDraft(
        summary: _summary(
          kind: PendingTransferKind.foreignTransaction,
          destination: null,
        ),
      )..targetAccountCurrency = 'EUR';
      expect(draft.isTransfer, isFalse);
      expect(draft.effectiveSettledToAccountId, 'src');
      expect(draft.settledAmountCurrency, 'EUR');
      expect(draft.isShortfallComparable, isFalse);
    });
  });
}
