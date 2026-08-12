import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/ofx/ofx_import_batch.dart';
import 'package:smara_accounting/domain/ofx/parsed_ofx_transaction.dart';
import 'package:smara_accounting/ui/features/ofx_import/view_models/ofx_import_view_model.dart';
import 'package:smara_accounting/ui/features/ofx_import/views/ofx_import_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository ledgerRepository;
  late MockOfxImportRepository importRepository;

  const checking = Account(
    id: 'asset-1',
    name: 'Checking',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-1',
  );
  const groceries = Account(
    id: 'cat-1',
    name: 'Groceries',
    type: AccountType.expense,
    archived: false,
  );

  final rowA = ParsedOfxTransaction(
    transactionDate: DateTime(2026, 1, 5),
    amountMinor: 1000,
    direction: TransactionDirection.moneyOut,
    description: 'Row A',
    currency: 'USD',
    fitid: 'FIT-A',
  );
  final rowB = ParsedOfxTransaction(
    transactionDate: DateTime(2026, 1, 6),
    amountMinor: 2000,
    direction: TransactionDirection.moneyOut,
    description: 'Row B',
    currency: 'USD',
    fitid: 'FIT-B',
  );

  setUp(() {
    ledgerRepository = MockLedgerRepository();
    importRepository = MockOfxImportRepository();

    when(
      ledgerRepository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking]));
    when(
      ledgerRepository.watchCategories(),
    ).thenAnswer((_) => Stream.value([groceries]));
  });

  OfxImportViewModel buildViewModel() {
    return OfxImportViewModel(
      importRepository: importRepository,
      ledgerRepository: ledgerRepository,
    );
  }

  Future<OfxImportViewModel> pumpAtPreview(
    WidgetTester tester, {
    Set<int> duplicateIndexes = const {},
  }) async {
    when(importRepository.parseFile(any)).thenReturn(
      OfxParseResult(
        transactions: [rowA, rowB],
        skippedRows: const [],
        statementCurrency: 'USD',
      ),
    );
    when(importRepository.groupCurrencyFor(any)).thenAnswer((_) async => 'USD');
    when(
      importRepository.findDuplicateIndexes(
        financialAccountId: anyNamed('financialAccountId'),
        transactions: anyNamed('transactions'),
      ),
    ).thenAnswer((_) async => duplicateIndexes);
    when(
      importRepository.suggestCategoryFor(
        financialAccountId: anyNamed('financialAccountId'),
        description: anyNamed('description'),
      ),
    ).thenAnswer((_) async => null);

    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);
    await viewModel.loadFile(name: 'statement.ofx', bytes: const [1, 2, 3]);
    await viewModel.selectAccount(checking.id);

    await tester.pumpWidget(
      MaterialApp(home: OfxImportView(viewModel: viewModel)),
    );
    await tester.pump();
    return viewModel;
  }

  testWidgets(
    'duplicate rows default unselected, non-duplicate rows default selected',
    (tester) async {
      await pumpAtPreview(tester, duplicateIndexes: {0});

      final checkboxes = tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .toList();
      expect(checkboxes[0].value, isFalse);
      expect(checkboxes[1].value, isTrue);
      expect(find.textContaining('possible duplicate'), findsOneWidget);
    },
  );

  testWidgets('tapping a row checkbox toggles its selection', (tester) async {
    final viewModel = await pumpAtPreview(tester);

    expect(viewModel.rows[0].selected, isTrue);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(viewModel.rows[0].selected, isFalse);
  });

  testWidgets('choosing a category from the dropdown updates that row', (
    tester,
  ) async {
    final viewModel = await pumpAtPreview(tester);

    expect(viewModel.rows[0].categoryId, isNull);
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groceries').last);
    await tester.pumpAndSettle();

    expect(viewModel.rows[0].categoryId, groceries.id);
  });

  testWidgets('confirming the import posts and renders the summary', (
    tester,
  ) async {
    final viewModel = await pumpAtPreview(tester, duplicateIndexes: {1});
    viewModel.setRowCategory(0, groceries.id);

    when(
      importRepository.postAcceptedRows(
        financialAccountId: anyNamed('financialAccountId'),
        rows: anyNamed('rows'),
      ),
    ).thenAnswer(
      (_) async =>
          OfxImportBatchResult(results: [OfxPostedRow(transaction: rowA)]),
    );

    await tester.tap(find.text('Confirm import'));
    await tester.pumpAndSettle();

    expect(find.text('1 posted'), findsOneWidget);
    verify(
      importRepository.postAcceptedRows(
        financialAccountId: checking.id,
        rows: anyNamed('rows'),
      ),
    ).called(1);
  });
}
