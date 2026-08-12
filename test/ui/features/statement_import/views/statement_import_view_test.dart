import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/data/database/tables/ofx_import_records_table.dart'
    show ImportSource;
import 'package:smara_accounting/domain/csv/csv_column_mapping.dart';
import 'package:smara_accounting/domain/csv/csv_import_profile.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/statement_import/parsed_statement_transaction.dart';
import 'package:smara_accounting/domain/statement_import/statement_import_batch.dart';
import 'package:smara_accounting/ui/features/statement_import/view_models/statement_import_view_model.dart';
import 'package:smara_accounting/ui/features/statement_import/views/statement_import_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository ledgerRepository;
  late MockStatementImportRepository importRepository;

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

  final rowA = ParsedStatementTransaction(
    transactionDate: DateTime(2026, 1, 5),
    amountMinor: 1000,
    direction: TransactionDirection.moneyOut,
    description: 'Row A',
    currency: 'USD',
    externalReferenceId: 'FIT-A',
  );
  final rowB = ParsedStatementTransaction(
    transactionDate: DateTime(2026, 1, 6),
    amountMinor: 2000,
    direction: TransactionDirection.moneyOut,
    description: 'Row B',
    currency: 'USD',
    externalReferenceId: 'FIT-B',
  );

  setUp(() {
    ledgerRepository = MockLedgerRepository();
    importRepository = MockStatementImportRepository();

    when(
      ledgerRepository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking]));
    when(
      ledgerRepository.watchCategories(),
    ).thenAnswer((_) => Stream.value([groceries]));
    when(
      importRepository.watchProfiles(),
    ).thenAnswer((_) => Stream.value(const []));
  });

  StatementImportViewModel buildViewModel() {
    return StatementImportViewModel(
      importRepository: importRepository,
      ledgerRepository: ledgerRepository,
    );
  }

  Future<StatementImportViewModel> pumpAtPreview(
    WidgetTester tester, {
    Set<int> duplicateIndexes = const {},
  }) async {
    when(importRepository.parseOfxFile(any)).thenReturn(
      StatementParseResult(
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
      MaterialApp(home: StatementImportView(viewModel: viewModel)),
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
        source: anyNamed('source'),
      ),
    ).thenAnswer(
      (_) async => StatementImportBatchResult(
        results: [StatementPostedRow(transaction: rowA)],
      ),
    );

    await tester.tap(find.text('Confirm import'));
    await tester.pumpAndSettle();

    expect(find.text('1 posted'), findsOneWidget);
    verify(
      importRepository.postAcceptedRows(
        financialAccountId: checking.id,
        rows: anyNamed('rows'),
        source: ImportSource.ofx,
      ),
    ).called(1);
  });

  group('CSV import', () {
    const csvFixture = 'Date,Description,Amount\n01/02/2026,Coffee,-4.50\n';

    const csvMapping = CsvColumnMapping(
      hasHeaderRow: true,
      dateColumnIndex: 0,
      datePattern: 'dd/MM/yyyy',
      descriptionColumnIndexes: [1],
      amountConvention: CsvAmountConvention.signedColumn,
      signedAmountColumnIndex: 2,
      currency: 'USD',
    );

    final savedProfile = CsvImportProfile(
      id: 'profile-1',
      name: 'My Bank',
      headerFingerprint: const ['date', 'description', 'amount'],
      mapping: csvMapping,
      createdAt: DateTime(2026, 1, 1),
    );

    Future<StatementImportViewModel> pumpAtCsvStep(
      WidgetTester tester, {
      CsvImportProfile? matchedProfile,
      List<CsvImportProfile> profiles = const [],
    }) async {
      when(
        importRepository.watchProfiles(),
      ).thenAnswer((_) => Stream.value(profiles));
      when(
        importRepository.findProfileForHeaderRow(any),
      ).thenAnswer((_) async => matchedProfile);
      when(
        importRepository.groupCurrencyFor(any),
      ).thenAnswer((_) async => 'USD');
      when(importRepository.parseCsvFile(any, any)).thenReturn(
        StatementParseResult(
          transactions: [rowA],
          skippedRows: const [],
          statementCurrency: 'USD',
        ),
      );
      when(
        importRepository.findDuplicateIndexes(
          financialAccountId: anyNamed('financialAccountId'),
          transactions: anyNamed('transactions'),
        ),
      ).thenAnswer((_) async => const {});
      when(
        importRepository.suggestCategoryFor(
          financialAccountId: anyNamed('financialAccountId'),
          description: anyNamed('description'),
        ),
      ).thenAnswer((_) async => null);

      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);
      viewModel.chooseSource(StatementSource.csv);
      await viewModel.loadFile(
        name: 'statement.csv',
        bytes: utf8.encode(csvFixture),
      );
      await viewModel.selectAccount(checking.id);

      await tester.pumpWidget(
        MaterialApp(home: StatementImportView(viewModel: viewModel)),
      );
      await tester.pump();
      return viewModel;
    }

    testWidgets(
      'no matching profile lands on the column-mapping step with Continue disabled',
      (tester) async {
        final viewModel = await pumpAtCsvStep(tester);

        expect(viewModel.step, StatementImportStep.mapColumns);
        final continueButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Continue'),
        );
        expect(continueButton.onPressed, isNull);
      },
    );

    testWidgets(
      'selecting a single column via the real dropdown does not throw or '
      'overflow before the rest of the mapping is complete',
      (tester) async {
        await pumpAtCsvStep(tester);

        // Reproduces the reported bug: pick just the date column (via the
        // actual dropdown, not driving the ViewModel directly) while the
        // amount convention still defaults to "Signed amount column" and
        // no amount column is chosen yet. The live preview re-evaluates
        // on this rebuild; it must not throw the CsvColumnMapping
        // constructor's amount-column assertion. "Date column" is the
        // first int-typed dropdown on the screen (the amount-convention
        // dropdown is CsvAmountConvention-typed, not int).
        await tester.tap(find.byType(DropdownButtonFormField<int>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Date').last);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final continueButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Continue'),
        );
        expect(continueButton.onPressed, isNull);
      },
    );

    testWidgets(
      'a matching profile pre-fills the mapping screen, and confirming it '
      'skips to preview without re-mapping',
      (tester) async {
        final viewModel = await pumpAtCsvStep(
          tester,
          matchedProfile: savedProfile,
        );

        // Pre-filled from the matched profile, not yet posted to preview.
        expect(viewModel.step, StatementImportStep.mapColumns);
        expect(viewModel.matchedProfile, savedProfile);
        expect(viewModel.csvDateColumnIndex, 0);
        expect(viewModel.canConfirmCsvMapping, isTrue);

        final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
        await tester.ensureVisible(continueButton);
        await tester.tap(continueButton);
        await tester.pumpAndSettle();

        expect(viewModel.step, StatementImportStep.preview);
        expect(find.byType(Checkbox), findsWidgets);
      },
    );

    testWidgets('selecting description and amount columns enables Continue', (
      tester,
    ) async {
      final viewModel = await pumpAtCsvStep(tester);

      viewModel.updateCsvMapping(
        dateColumnIndex: 0,
        descriptionColumnIndexes: [1],
        signedAmountColumnIndex: 2,
      );
      await tester.pump();

      expect(viewModel.canConfirmCsvMapping, isTrue);
      final continueButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Continue'),
      );
      expect(continueButton.onPressed, isNotNull);
    });

    testWidgets(
      'the mapping screen shows a live preview once the mapping is complete',
      (tester) async {
        final viewModel = await pumpAtCsvStep(tester);

        viewModel.updateCsvMapping(
          dateColumnIndex: 0,
          descriptionColumnIndexes: [1],
          signedAmountColumnIndex: 2,
        );
        await tester.pump();

        expect(viewModel.csvMappingPreviewRows, isNotEmpty);
      },
    );

    testWidgets(
      'choosing a saved profile from the dropdown applies its mapping',
      (tester) async {
        final viewModel = await pumpAtCsvStep(tester, profiles: [savedProfile]);

        expect(find.text('Use a saved profile'), findsOneWidget);
        await tester.tap(find.text('Use a saved profile'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('My Bank').last);
        await tester.pumpAndSettle();

        expect(viewModel.csvDateColumnIndex, 0);
        expect(viewModel.csvDatePattern, 'dd/MM/yyyy');
        expect(viewModel.canConfirmCsvMapping, isTrue);
      },
    );

    testWidgets('renaming a saved profile calls through to the repository', (
      tester,
    ) async {
      when(
        importRepository.renameProfile(
          id: anyNamed('id'),
          newName: anyNamed('newName'),
        ),
      ).thenAnswer((_) async {});

      await pumpAtCsvStep(tester, profiles: [savedProfile]);

      await tester.tap(
        find.byWidgetPredicate((widget) => widget is PopupMenuButton).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Renamed Bank');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      verify(
        importRepository.renameProfile(
          id: 'profile-1',
          newName: 'Renamed Bank',
        ),
      ).called(1);
    });

    testWidgets('deleting a saved profile calls through to the repository', (
      tester,
    ) async {
      when(importRepository.deleteProfile(any)).thenAnswer((_) async {});

      await pumpAtCsvStep(tester, profiles: [savedProfile]);

      await tester.tap(
        find.byWidgetPredicate((widget) => widget is PopupMenuButton).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(importRepository.deleteProfile('profile-1')).called(1);
    });
  });
}
