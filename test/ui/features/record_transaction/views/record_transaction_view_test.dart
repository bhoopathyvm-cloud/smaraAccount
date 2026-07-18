import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/ui/features/record_transaction/view_models/record_transaction_view_model.dart';
import 'package:smara_accounting/ui/features/record_transaction/views/record_transaction_view.dart';

import '../../../../mocks.mocks.dart';

// Mocks the Repository rather than using a real Drift database: see
// register_view_test.dart's file comment for why testWidgets + real
// native DB I/O hangs indefinitely instead of settling.
void main() {
  testWidgets('archived category does not appear in the category picker', (
    tester,
  ) async {
    // "Salary" was archived - watchCategories() (default: active only)
    // no longer includes it, matching what LedgerRepository.watchCategories
    // actually does after archiveCategory() (verified in
    // ledger_repository_test.dart's "archived category is excluded"
    // test).
    final repository = MockLedgerRepository();
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer(
      (_) => Stream.value([
        const Account(
          id: 'income-2',
          name: 'Other Income',
          type: AccountType.income,
          archived: false,
        ),
      ]),
    );

    final viewModel = RecordTransactionViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: RecordTransactionView(
          viewModel: viewModel,
          ledgerRepository: repository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Salary'), findsNothing);
    expect(find.text('Other Income'), findsWidgets);
  });
}
