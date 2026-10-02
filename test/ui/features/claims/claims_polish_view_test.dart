import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/data/repositories/claim_repository.dart';
import 'package:smara_accounting/domain/models/claim.dart';
import 'package:smara_accounting/domain/models/claim_advance.dart';
import 'package:smara_accounting/domain/models/claim_item.dart';
import 'package:smara_accounting/domain/models/claim_receipt.dart';
import 'package:smara_accounting/domain/models/claim_status.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/core/money_formatter.dart';
import 'package:smara_accounting/ui/features/claims/view_models/approver_queue_view_model.dart';
import 'package:smara_accounting/ui/features/claims/view_models/claims_list_view_model.dart';
import 'package:smara_accounting/ui/features/claims/views/approver_queue_view.dart';
import 'package:smara_accounting/ui/features/claims/views/claims_list_view.dart';

class _NoopClaims extends Fake implements ClaimRepository {}

void main() {
  testWidgets('Claimant list formats balance/advances and omits raw ids', (
    tester,
  ) async {
    final vm = ClaimsListViewModel(
      claims: _NoopClaims(),
      localDeviceId: 'ravi',
      companyDisplayName: 'Acme',
    );
    vm.loading = false;
    vm.balanceMinor = 12345;
    vm.advances = [
      ClaimAdvance(
        id: 'adv-1',
        claimantDeviceId: 'ravi',
        amountMinor: 20000,
        paidFromAccountId: 'bank',
        postedEntryId: 'e1',
        recordedAt: DateTime(2026, 2, 1),
        description: 'March advance',
      ),
    ];
    vm.items = [
      Claim(
        id: 'claim-aaaaaaaa',
        claimantDeviceId: 'ravi',
        status: ClaimStatus.submitted,
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
        submittedAt: DateTime(2026, 3, 1),
        items: const [],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
        supportedLocales: supportedAppLocales,
        home: ClaimsListView(viewModel: vm, companyCurrency: 'USD'),
      ),
    );

    expect(find.text('Acme owes you'), findsOneWidget);
    expect(
      find.textContaining(formatAmountMinor(12345, 'USD')),
      findsOneWidget,
    );
    expect(
      find.textContaining(formatAmountMinor(20000, 'USD')),
      findsOneWidget,
    );
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.textContaining('claim-aa'), findsNothing);
    expect(find.textContaining('2026-03-01'), findsOneWidget);
  });

  testWidgets('Approver queue formats money, status, category, approve-diff', (
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
            paidCurrency: 'EUR',
            paidAmountMinor: 10000,
            companyCurrencyAmountMinor: 12000,
            sortOrder: 0,
            createdAt: DateTime(2026, 3, 1),
            description: 'Hotel',
            receipt: ClaimReceipt(
              id: 'r1',
              claimItemId: 'item-1',
              contentType: 'image/jpeg',
              fileName: 'hotel.jpg',
              byteSize: 12,
              contentHash: 'h',
              createdAt: DateTime(2026, 3, 1),
            ),
          ),
        ],
      ),
    ];

    final thumb = Uint8List.fromList(
      // Minimal 1x1 JPEG
      [0xFF, 0xD8, 0xFF, 0xD9],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
        supportedLocales: supportedAppLocales,
        home: ApproverQueueView(
          viewModel: vm,
          companyCurrency: 'USD',
          categoryNames: const {'travel': 'Travel'},
          receiptThumbnails: {'item-1': thumb},
        ),
      ),
    );

    expect(find.text('Review claims'), findsOneWidget);
    expect(find.textContaining('Submitted'), findsOneWidget);
    expect(find.textContaining('claim-bb'), findsNothing);
    expect(
      find.textContaining(formatAmountMinor(10000, 'EUR')),
      findsOneWidget,
    );
    expect(
      find.textContaining(formatAmountMinor(12000, 'USD')),
      findsOneWidget,
    );
    expect(find.textContaining('Travel'), findsOneWidget);
    expect(find.text('Approve different amount'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.text('Approve different amount'));
    await tester.pumpAndSettle();
    expect(find.text('Approve different amount reason'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}
