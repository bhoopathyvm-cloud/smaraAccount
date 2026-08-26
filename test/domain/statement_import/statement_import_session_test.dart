import 'package:smara_accounting/domain/csv/csv_column_mapping.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/statement_import/parsed_statement_transaction.dart';
import 'package:smara_accounting/domain/statement_import/statement_import_session.dart';
import 'package:test/test.dart';

void main() {
  test('chooseSource advances to pick-file', () {
    final session = StatementImportSession();
    expect(session.step, StatementImportStep.chooseSource);
    session.chooseSource(StatementSource.csv);
    expect(session.source, StatementSource.csv);
    expect(session.step, StatementImportStep.pickFile);
  });

  test(
    'CSV mapping is incomplete until date, description, amount, currency',
    () {
      final draft = CsvMappingDraft();
      expect(draft.isComplete, isFalse);
      draft.dateColumnIndex = 0;
      draft.descriptionColumnIndexes = [1];
      draft.signedAmountColumnIndex = 2;
      expect(draft.isComplete, isFalse);
      draft.currency = 'USD';
      expect(draft.isComplete, isTrue);
      expect(draft.toMapping(), isNotNull);
    },
  );

  test('debit/credit mapping needs both amount columns', () {
    final draft = CsvMappingDraft()
      ..dateColumnIndex = 0
      ..descriptionColumnIndexes = [1]
      ..amountConvention = CsvAmountConvention.debitCreditColumns
      ..debitColumnIndex = 2
      ..currency = 'EUR';
    expect(draft.isComplete, isFalse);
    draft.creditColumnIndex = 3;
    expect(draft.isComplete, isTrue);
  });

  test('groupPreviewRows keys on normalized description', () {
    ParsedStatementTransaction tx(String description) {
      return ParsedStatementTransaction(
        transactionDate: DateTime(2026, 1, 1),
        amountMinor: 100,
        direction: TransactionDirection.moneyOut,
        description: description,
        currency: 'USD',
      );
    }

    final groups = groupPreviewRows([
      StatementImportPreviewRow(transaction: tx('Coffee'), isDuplicate: false),
      StatementImportPreviewRow(
        transaction: tx(' coffee '),
        isDuplicate: false,
      ),
      StatementImportPreviewRow(transaction: tx('Rent'), isDuplicate: false),
    ]);
    expect(groups, hasLength(2));
    expect(groups.first.rowIndexes, [0, 1]);
    expect(groups.last.isSingleRow, isTrue);
  });
}
