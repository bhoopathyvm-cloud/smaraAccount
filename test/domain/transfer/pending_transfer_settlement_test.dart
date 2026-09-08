import 'package:test/test.dart';

import 'package:smara_accounting/domain/models/pending_transfer_kind.dart';
import 'package:smara_accounting/domain/transfer/pending_transfer_settlement.dart';

void main() {
  group('PendingTransferSettlement.resolve', () {
    test('transfer returning to its source is the shortfall path', () {
      final settlement = PendingTransferSettlement.resolve(
        kind: PendingTransferKind.transfer,
        sourceAccountId: 'src',
        settledToAccountId: 'src',
      );
      expect(settlement.resolvedTargetAccountId, 'src');
      expect(settlement.isShortfallComparable, isTrue);
    });

    test('transfer delivered to its destination is not shortfall path', () {
      final settlement = PendingTransferSettlement.resolve(
        kind: PendingTransferKind.transfer,
        sourceAccountId: 'src',
        settledToAccountId: 'dst',
      );
      expect(settlement.resolvedTargetAccountId, 'dst');
      expect(settlement.isShortfallComparable, isFalse);
    });

    test('foreign transaction always resolves to source, never shortfall', () {
      final settlement = PendingTransferSettlement.resolve(
        kind: PendingTransferKind.foreignTransaction,
        sourceAccountId: 'src',
        // Even if a caller passes some other account, it is ignored.
        settledToAccountId: 'dst',
      );
      expect(settlement.resolvedTargetAccountId, 'src');
      expect(settlement.isShortfallComparable, isFalse);
    });

    test('transfer target is null (and not shortfall) before one is chosen', () {
      final settlement = PendingTransferSettlement.resolve(
        kind: PendingTransferKind.transfer,
        sourceAccountId: 'src',
        settledToAccountId: null,
      );
      expect(settlement.resolvedTargetAccountId, isNull);
      expect(settlement.isShortfallComparable, isFalse);
    });
  });
}
