import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/data/repositories/claim_repository.dart';
import 'package:smara_accounting/domain/models/claim.dart';
import 'package:smara_accounting/domain/models/claim_item.dart';
import 'package:smara_accounting/domain/models/claim_status.dart';
import 'package:smara_accounting/ui/features/claims/view_models/approver_queue_view_model.dart';
import 'package:smara_accounting/ui/features/claims/views/approver_queue_view.dart';

class _NoopClaims extends Fake implements ClaimRepository {}

void main() {
  testWidgets('Approver queue shows approve/reject for pending items', (
    tester,
  ) async {
    final vm = ApproverQueueViewModel(
      claims: _NoopClaims(),
      actorDeviceId: 'owner',
    );
    vm.loading = false;
    vm.queue = [
      Claim(
        id: 'claim-bbbbbbbb',
        claimantDeviceId: 'ravi',
        status: ClaimStatus.submitted,
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
        submittedAt: DateTime(2026, 3, 1),
        items: [
          ClaimItem(
            id: 'item-1',
            claimId: 'claim-bbbbbbbb',
            categoryId: 'travel',
            expenseDate: DateTime(2026, 3, 1),
            paidCurrency: 'USD',
            paidAmountMinor: 12000,
            companyCurrencyAmountMinor: 12000,
            sortOrder: 0,
            createdAt: DateTime(2026, 3, 1),
            description: 'Hotel',
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: ApproverQueueView(viewModel: vm)),
    );
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
    expect(find.textContaining('Hotel'), findsOneWidget);

    // Reject without reason surfaces required-reason error via dialog cancel.
    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();
    expect(find.text('Reject reason'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}
