import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/summary.dart';
import 'package:smara_accounting/ui/features/summary/view_models/summary_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;

  setUp(() {
    repository = MockLedgerRepository();
  });

  test('subscribes with the default (current month) range on construction', () {
    when(
      repository.watchSummary(start: anyNamed('start'), end: anyNamed('end')),
    ).thenAnswer(
      (_) => Stream.value(
        const LedgerSummary(totalIncomeMinor: 0, totalExpenseMinor: 0),
      ),
    );

    final viewModel = SummaryViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    expect(viewModel.start.day, equals(1));
    verify(
      repository.watchSummary(start: anyNamed('start'), end: anyNamed('end')),
    ).called(1);
  });

  test(
    'setDateRange re-subscribes with the new range and updates summary',
    () async {
      when(
        repository.watchSummary(start: anyNamed('start'), end: anyNamed('end')),
      ).thenAnswer(
        (_) => Stream.value(
          const LedgerSummary(totalIncomeMinor: 100, totalExpenseMinor: 50),
        ),
      );

      final viewModel = SummaryViewModel(ledgerRepository: repository);
      addTearDown(viewModel.dispose);

      final start = DateTime(2026, 2, 1);
      final end = DateTime(2026, 2, 28);
      viewModel.setDateRange(start: start, end: end);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.start, equals(start));
      expect(viewModel.end, equals(end));
      expect(viewModel.summary.totalIncomeMinor, equals(100));
      expect(viewModel.summary.totalExpenseMinor, equals(50));
      verify(
        repository.watchSummary(start: anyNamed('start'), end: anyNamed('end')),
      ).called(2);
    },
  );
}
