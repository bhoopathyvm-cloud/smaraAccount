import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/ui/features/category_management/view_models/category_management_view_model.dart';
import 'package:smara_accounting/ui/features/category_management/views/category_management_view.dart';

import '../../../../mocks.mocks.dart';

// Mocks the Repository rather than using a real Drift database: see
// register_view_test.dart's file comment for why testWidgets + real
// native DB I/O hangs indefinitely instead of settling.
void main() {
  testWidgets(
    'archived categories stay visible without rename/archive actions',
    (tester) async {
      final repository = MockLedgerRepository();
      when(
        repository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'income-1',
            name: 'Salary',
            type: AccountType.income,
            archived: false,
          ),
          Account(
            id: 'income-2',
            name: 'Other Income',
            type: AccountType.income,
            archived: true,
          ),
        ]),
      );

      final viewModel = CategoryManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: CategoryManagementView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Other Income'), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(Card, 'Salary'),
          matching: find.text('Archive'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.widgetWithText(Card, 'Other Income'),
          matching: find.text('Archive'),
        ),
        findsNothing,
      );
    },
  );
}
