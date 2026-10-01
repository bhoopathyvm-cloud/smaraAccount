import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/data/repositories/claim_repository.dart';
import 'package:smara_accounting/domain/models/claim.dart';
import 'package:smara_accounting/domain/models/claim_status.dart';
import 'package:smara_accounting/ui/features/claims/view_models/claims_list_view_model.dart';
import 'package:smara_accounting/ui/features/claims/views/claims_list_view.dart';

class _NoopClaims extends Fake implements ClaimRepository {}

void main() {
  testWidgets('Claimant list shows balance copy and claim status', (
    tester,
  ) async {
    final vm = ClaimsListViewModel(
      claims: _NoopClaims(),
      localDeviceId: 'ravi',
      companyDisplayName: 'Acme',
    );
    vm.loading = false;
    vm.balanceMinor = 12000;
    vm.items = [
      Claim(
        id: 'claim-aaaaaaaa',
        claimantDeviceId: 'ravi',
        status: ClaimStatus.submitted,
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
        submittedAt: DateTime(2026, 3, 1),
      ),
    ];

    await tester.pumpWidget(MaterialApp(home: ClaimsListView(viewModel: vm)));
    expect(find.text('Acme owes you'), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('Register'), findsNothing);
    expect(find.text('Accounts'), findsNothing);
  });
}
