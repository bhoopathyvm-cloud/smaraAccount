import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/summary.dart';
import 'package:smara_accounting/ui/features/summary/view_models/summary_view_model.dart';
import 'package:smara_accounting/ui/features/summary/views/summary_view.dart';

import '../../../../mocks.mocks.dart';

// Mocks the Repository rather than using a real Drift database: see
// register_view_test.dart's file comment for why testWidgets + real
// native DB I/O hangs indefinitely instead of settling.
void main() {
  testWidgets('renders total income and total expense for the range', (
    tester,
  ) async {
    final repository = MockLedgerRepository();
    when(
      repository.watchSummary(start: anyNamed('start'), end: anyNamed('end')),
    ).thenAnswer(
      (_) => Stream.value(
        const LedgerSummary(totalIncomeMinor: 150000, totalExpenseMinor: 4250),
      ),
    );

    final viewModel = SummaryViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: SummaryView(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.text('Total income'), findsOneWidget);
    expect(find.text('Total expense'), findsOneWidget);
    expect(find.text('1500.00'), findsOneWidget);
    expect(find.text('42.50'), findsOneWidget);
  });
}
