import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/data/database/tables/ofx_import_records_table.dart'
    show ImportSource;
import 'package:smara_accounting/domain/csv/csv_column_mapping.dart';
import 'package:smara_accounting/domain/csv/csv_import_profile.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/payee.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/statement_import/category_rule.dart';
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
  const transport = Account(
    id: 'cat-2',
    name: 'Transport',
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
  // Shares rowA's description (a duplicate within the same import) so the
  // 'Row A' group has two rows - used by the row-grouping/save-as-rule
  // widget tests.
  final rowC = ParsedStatementTransaction(
    transactionDate: DateTime(2026, 1, 7),
    amountMinor: 3000,
    direction: TransactionDirection.moneyOut,
    description: 'Row A',
    currency: 'USD',
    externalReferenceId: 'FIT-C',
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
    ).thenAnswer((_) => Stream.value([groceries, transport]));
    when(
      importRepository.watchProfiles(),
    ).thenAnswer((_) => Stream.value(const []));
    when(
      importRepository.watchCategoryRules(),
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

  /// Like [pumpAtPreview], but with [rowA] duplicated as [rowC] so the
  /// preview has a genuine multi-row group ('Row A') alongside a
  /// single-row group ('Row B').
  Future<StatementImportViewModel> pumpAtPreviewWithGroup(
    WidgetTester tester,
  ) async {
    when(importRepository.parseOfxFile(any)).thenReturn(
      StatementParseResult(
        transactions: [rowA, rowC, rowB],
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
    ).thenAnswer((_) async => const {});
    when(
      importRepository.suggestCategoryFor(
        financialAccountId: anyNamed('financialAccountId'),
        description: anyNamed('description'),
      ),
    ).thenAnswer((_) async => null);
    when(
      importRepository.saveCategoryRule(
        keyword: anyNamed('keyword'),
        categoryId: anyNamed('categoryId'),
      ),
    ).thenAnswer((_) async {});

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
    'a file with one bad row shows its reason and still offers the good rows '
    'on the account-select step',
    (tester) async {
      when(importRepository.parseOfxFile(any)).thenReturn(
        StatementParseResult(
          transactions: [rowA],
          skippedRows: const [
            StatementSkippedRow(
              rawFragment: '<STMTTRN>...</STMTTRN>',
              reason: 'Missing transaction amount',
            ),
          ],
          statementCurrency: 'USD',
        ),
      );

      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);
      await viewModel.loadFile(name: 'statement.ofx', bytes: const [1, 2, 3]);

      expect(viewModel.skippedRows, hasLength(1));
      expect(viewModel.skippedRows.single.reason, 'Missing transaction amount');
      expect(viewModel.parsedTransactionCount, 1);

      await tester.pumpWidget(
        MaterialApp(home: StatementImportView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.text('1 transactions parsed'), findsOneWidget);
      expect(find.text('1 skipped or excluded'), findsOneWidget);
      expect(find.text('Skipped rows'), findsOneWidget);
      expect(find.text('Missing transaction amount'), findsOneWidget);
      expect(find.text('Import into account'), findsOneWidget);
    },
  );

  testWidgets(
    'register-launched OFX with a skipped row shows the reason on preview '
    'alongside the good rows (account-select is auto-skipped)',
    (tester) async {
      when(importRepository.parseOfxFile(any)).thenReturn(
        StatementParseResult(
          transactions: [rowA],
          skippedRows: const [
            StatementSkippedRow(
              rawFragment: '<STMTTRN>...</STMTTRN>',
              reason: 'Missing transaction amount',
            ),
          ],
          statementCurrency: 'USD',
        ),
      );
      when(
        importRepository.groupCurrencyFor(any),
      ).thenAnswer((_) async => 'USD');
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

      final viewModel = StatementImportViewModel(
        importRepository: importRepository,
        ledgerRepository: ledgerRepository,
        initialFinancialAccountId: checking.id,
      );
      addTearDown(viewModel.dispose);

      // Mount first so stream subscriptions deliver under the test binder,
      // then load - mirrors register launch with a pre-selected account.
      await tester.pumpWidget(
        MaterialApp(home: StatementImportView(viewModel: viewModel)),
      );
      await tester.pump();

      viewModel.chooseSource(StatementSource.ofx);
      await tester.pump();
      await viewModel.loadFile(name: 'statement.ofx', bytes: const [1, 2, 3]);
      await tester.pump();

      expect(viewModel.step, StatementImportStep.preview);
      expect(viewModel.skippedRows, hasLength(1));
      expect(viewModel.rows, hasLength(1));

      expect(find.text('Skipped rows'), findsOneWidget);
      expect(find.text('Missing transaction amount'), findsOneWidget);
      expect(find.text('Row A'), findsOneWidget);
      expect(find.text('Confirm import'), findsOneWidget);
      expect(find.text('Import into account'), findsNothing);
    },
  );

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

    expect(find.text('1 posted, 0 failed'), findsOneWidget);
    verify(
      importRepository.postAcceptedRows(
        financialAccountId: checking.id,
        rows: anyNamed('rows'),
        source: ImportSource.ofx,
      ),
    ).called(1);
  });

  group('category rule grouping and bulk assignment', () {
    testWidgets(
      'assigning a category to a multi-row group sets it on every row in the group',
      (tester) async {
        final viewModel = await pumpAtPreviewWithGroup(tester);

        // The 'Row A' group (2 rows) renders first; its group-level
        // picker is the first EntityPickerField in the tree.
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Groceries').last);
        await tester.pumpAndSettle();

        // Dismiss the "Save as a rule?" prompt without saving.
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        final rowAIndexes = [
          for (var i = 0; i < viewModel.rows.length; i++)
            if (viewModel.rows[i].transaction.description == 'Row A') i,
        ];
        expect(rowAIndexes, hasLength(2));
        for (final index in rowAIndexes) {
          expect(viewModel.rows[index].categoryId, groceries.id);
        }
        // The unrelated single-row group is untouched.
        final rowBIndex = viewModel.rows.indexWhere(
          (r) => r.transaction.description == 'Row B',
        );
        expect(viewModel.rows[rowBIndex].categoryId, isNull);
      },
    );

    testWidgets(
      'saving a multi-row group assignment as a rule pre-fills the keyword '
      'from the shared description',
      (tester) async {
        await pumpAtPreviewWithGroup(tester);

        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Groceries').last);
        await tester.pumpAndSettle();

        expect(find.text('Save as a rule?'), findsOneWidget);
        final keywordField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'row a'),
        );
        expect(keywordField.controller?.text, 'row a');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Save rule'));
        await tester.pumpAndSettle();

        verify(
          importRepository.saveCategoryRule(
            keyword: 'row a',
            categoryId: groceries.id,
          ),
        ).called(1);
      },
    );

    testWidgets(
      'saving a single-row group assignment as a rule requires an explicit keyword',
      (tester) async {
        await pumpAtPreviewWithGroup(tester);

        // 'Row B' is a single-row group; its per-row picker is the last
        // EntityPickerField in the tree (after the 'Row A' group's picker
        // and its two per-row pickers).
        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Groceries').last);
        await tester.pumpAndSettle();

        expect(find.text('Save as a rule?'), findsOneWidget);
        final keywordField = tester.widget<TextField>(
          find.byType(TextField).last,
        );
        expect(keywordField.controller?.text, isEmpty);

        // Tapping Save with no keyword typed does nothing - the dialog
        // stays open rather than silently saving an empty-keyword rule.
        await tester.tap(find.widgetWithText(ElevatedButton, 'Save rule'));
        await tester.pumpAndSettle();
        expect(find.text('Save as a rule?'), findsOneWidget);
        verifyNever(
          importRepository.saveCategoryRule(
            keyword: anyNamed('keyword'),
            categoryId: anyNamed('categoryId'),
          ),
        );

        await tester.enterText(find.byType(TextField).last, 'ROW B KEYWORD');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Save rule'));
        await tester.pumpAndSettle();

        verify(
          importRepository.saveCategoryRule(
            keyword: 'ROW B KEYWORD',
            categoryId: groceries.id,
          ),
        ).called(1);
      },
    );
  });

  group(
    'payees-and-spending-memory: link a payee from the save-rule dialog',
    () {
      testWidgets(
        'accepting the pre-checked offer links a payee named after the '
        'keyword, defaulting to the rule\'s category',
        (tester) async {
          await pumpAtPreviewWithGroup(tester);

          await tester.tap(find.byType(DropdownButtonFormField<String>).first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Groceries').last);
          await tester.pumpAndSettle();

          when(
            ledgerRepository.findOrCreatePayeeByName(
              name: anyNamed('name'),
              defaultCategoryId: anyNamed('defaultCategoryId'),
            ),
          ).thenAnswer(
            (_) async => const Payee(
              id: 'payee-1',
              name: 'row a',
              defaultCategoryId: 'cat-1',
            ),
          );

          expect(find.text('Also remember as a payee'), findsOneWidget);
          await tester.tap(find.widgetWithText(ElevatedButton, 'Save rule'));
          await tester.pumpAndSettle();

          verify(
            ledgerRepository.findOrCreatePayeeByName(
              name: 'row a',
              defaultCategoryId: groceries.id,
            ),
          ).called(1);
        },
      );

      testWidgets(
        'unchecking the offer still saves the rule, but links no payee',
        (tester) async {
          await pumpAtPreviewWithGroup(tester);

          await tester.tap(find.byType(DropdownButtonFormField<String>).first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Groceries').last);
          await tester.pumpAndSettle();

          await tester.tap(find.text('Also remember as a payee'));
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(ElevatedButton, 'Save rule'));
          await tester.pumpAndSettle();

          verify(
            importRepository.saveCategoryRule(
              keyword: 'row a',
              categoryId: groceries.id,
            ),
          ).called(1);
          verifyNever(
            ledgerRepository.findOrCreatePayeeByName(
              name: anyNamed('name'),
              defaultCategoryId: anyNamed('defaultCategoryId'),
            ),
          );
        },
      );

      testWidgets('skipping the rule entirely links no payee either', (
        tester,
      ) async {
        await pumpAtPreviewWithGroup(tester);

        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Groceries').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        verifyNever(
          importRepository.saveCategoryRule(
            keyword: anyNamed('keyword'),
            categoryId: anyNamed('categoryId'),
          ),
        );
        verifyNever(
          ledgerRepository.findOrCreatePayeeByName(
            name: anyNamed('name'),
            defaultCategoryId: anyNamed('defaultCategoryId'),
          ),
        );
      });
    },
  );

  group('category rule management', () {
    testWidgets('lists every saved rule with its category', (tester) async {
      when(importRepository.watchCategoryRules()).thenAnswer(
        (_) => Stream.value([
          CategoryRule(
            id: 'rule-1',
            keyword: 'AMAZON',
            categoryId: groceries.id,
            createdAt: DateTime(2026, 1, 1),
          ),
        ]),
      );
      await pumpAtPreview(tester);

      await tester.tap(find.byTooltip('Manage Saved Category Rules'));
      await tester.pumpAndSettle();

      expect(find.text('AMAZON'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('deleting a rule calls through to the repository', (
      tester,
    ) async {
      when(importRepository.watchCategoryRules()).thenAnswer(
        (_) => Stream.value([
          CategoryRule(
            id: 'rule-1',
            keyword: 'AMAZON',
            categoryId: groceries.id,
            createdAt: DateTime(2026, 1, 1),
          ),
        ]),
      );
      when(importRepository.deleteCategoryRule(any)).thenAnswer((_) async {});
      await pumpAtPreview(tester);

      await tester.tap(find.byTooltip('Manage Saved Category Rules'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate((widget) => widget is PopupMenuButton),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(importRepository.deleteCategoryRule('rule-1')).called(1);
    });
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

    testWidgets(
      'a CSV file with one bad row shows its reason on preview and still '
      'offers the good rows',
      (tester) async {
        final viewModel = await pumpAtCsvStep(
          tester,
          matchedProfile: savedProfile,
        );

        // Override after pumpAtCsvStep's default empty-skipped stub: CSV
        // parsing only runs when Continue confirms the mapping.
        when(importRepository.parseCsvFile(any, any)).thenReturn(
          StatementParseResult(
            transactions: [rowA],
            skippedRows: const [
              StatementSkippedRow(
                rawFragment: '01/02/2026,Bad,-not-a-number',
                reason: 'Could not parse amount',
              ),
            ],
            statementCurrency: 'USD',
          ),
        );

        final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
        await tester.ensureVisible(continueButton);
        await tester.tap(continueButton);
        await tester.pumpAndSettle();

        expect(viewModel.step, StatementImportStep.preview);
        expect(viewModel.skippedRows, hasLength(1));
        expect(viewModel.skippedRows.single.reason, 'Could not parse amount');
        expect(viewModel.rows, hasLength(1));

        expect(find.text('Skipped rows'), findsOneWidget);
        expect(find.text('Could not parse amount'), findsOneWidget);
        expect(find.text('Row A'), findsOneWidget);
        expect(find.text('Confirm import'), findsOneWidget);
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

    testWidgets(
      'deleting a saved profile confirms then calls through to the repository',
      (tester) async {
        when(importRepository.deleteProfile(any)).thenAnswer((_) async {});

        await pumpAtCsvStep(tester, profiles: [savedProfile]);

        await tester.tap(
          find.byWidgetPredicate((widget) => widget is PopupMenuButton).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Delete profile?'), findsOneWidget);
        verifyNever(importRepository.deleteProfile(any));

        await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
        await tester.pumpAndSettle();

        verify(importRepository.deleteProfile('profile-1')).called(1);
      },
    );

    testWidgets('cancelling the delete confirmation keeps the profile', (
      tester,
    ) async {
      await pumpAtCsvStep(tester, profiles: [savedProfile]);

      await tester.tap(
        find.byWidgetPredicate((widget) => widget is PopupMenuButton).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(importRepository.deleteProfile(any));
    });
  });
}
