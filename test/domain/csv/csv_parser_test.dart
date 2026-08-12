import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/csv/csv_column_mapping.dart';
import 'package:smara_accounting/domain/csv/csv_parser.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';

void main() {
  group('readCsvRows', () {
    test('returns rows including the header row', () {
      const fixture = 'Date,Description,Amount\n01/02/2026,Coffee,-4.50\n';
      final rows = readCsvRows(utf8.encode(fixture));
      expect(rows, [
        ['Date', 'Description', 'Amount'],
        ['01/02/2026', 'Coffee', '-4.50'],
      ]);
    });

    test('strips a UTF-8 BOM before parsing', () {
      const bom = [0xEF, 0xBB, 0xBF];
      final bytes = [...bom, ...utf8.encode('Date,Amount\n01/02/2026,-4.50\n')];
      final rows = readCsvRows(bytes);
      expect(rows.first, ['Date', 'Amount']);
    });

    test('throws CsvParseException for an empty file', () {
      expect(
        () => readCsvRows(utf8.encode('')),
        throwsA(isA<CsvParseException>()),
      );
    });
  });

  group('parseCsvDocument: signed-amount convention', () {
    const mapping = CsvColumnMapping(
      hasHeaderRow: true,
      dateColumnIndex: 0,
      datePattern: 'dd/MM/yyyy',
      descriptionColumnIndexes: [1],
      amountConvention: CsvAmountConvention.signedColumn,
      signedAmountColumnIndex: 2,
      currency: 'USD',
    );

    test('parses a signed-amount row as money out', () {
      const fixture = 'Date,Description,Amount\n01/02/2026,Coffee,-4.50\n';
      final result = parseCsvDocument(utf8.encode(fixture), mapping);

      expect(result.transactions, hasLength(1));
      final row = result.transactions.single;
      expect(row.transactionDate, DateTime(2026, 2, 1));
      expect(row.amountMinor, 450);
      expect(row.direction, TransactionDirection.moneyOut);
      expect(row.description, 'Coffee');
      expect(row.currency, 'USD');
    });

    test('parses a positive signed amount as money in', () {
      const fixture = 'Date,Description,Amount\n01/02/2026,Payroll,2500.00\n';
      final result = parseCsvDocument(utf8.encode(fixture), mapping);

      expect(
        result.transactions.single.direction,
        TransactionDirection.moneyIn,
      );
      expect(result.transactions.single.amountMinor, 250000);
    });

    test(
      'skips a row with an unparseable amount without aborting the file',
      () {
        const fixture =
            'Date,Description,Amount\n'
            '01/02/2026,Bad Row,notanumber\n'
            '02/02/2026,Good Row,-10.00\n';
        final result = parseCsvDocument(utf8.encode(fixture), mapping);

        expect(result.transactions, hasLength(1));
        expect(result.transactions.single.description, 'Good Row');
        expect(result.skippedRows, hasLength(1));
        expect(result.skippedRows.single.reason, contains('amount'));
      },
    );

    test('skips a row with an unparseable date without aborting the file', () {
      const fixture =
          'Date,Description,Amount\n'
          'not-a-date,Bad Row,-1.00\n'
          '02/02/2026,Good Row,-10.00\n';
      final result = parseCsvDocument(utf8.encode(fixture), mapping);

      expect(result.transactions, hasLength(1));
      expect(result.skippedRows, hasLength(1));
      expect(result.skippedRows.single.reason, contains('date'));
    });
  });

  group('parseCsvDocument: headerless positional mapping', () {
    test('parses a file with no header row using positional columns', () {
      const mapping = CsvColumnMapping(
        hasHeaderRow: false,
        dateColumnIndex: 0,
        datePattern: 'yyyy-MM-dd',
        descriptionColumnIndexes: [1],
        amountConvention: CsvAmountConvention.signedColumn,
        signedAmountColumnIndex: 2,
        currency: 'EUR',
      );
      const fixture =
          '2026-02-01,Groceries,-64.53\n2026-02-02,Salary,2500.00\n';

      final result = parseCsvDocument(utf8.encode(fixture), mapping);

      expect(result.transactions, hasLength(2));
      expect(result.transactions[0].transactionDate, DateTime(2026, 2, 1));
      expect(result.transactions[0].description, 'Groceries');
      expect(result.transactions[1].direction, TransactionDirection.moneyIn);
    });
  });

  group('parseCsvDocument: debit/credit-column convention', () {
    const mapping = CsvColumnMapping(
      hasHeaderRow: true,
      dateColumnIndex: 0,
      datePattern: 'dd-MM-yyyy',
      descriptionColumnIndexes: [1],
      amountConvention: CsvAmountConvention.debitCreditColumns,
      debitColumnIndex: 2,
      creditColumnIndex: 3,
      currency: 'INR',
    );

    test('a populated debit column posts as money out', () {
      const fixture =
          'Date,Narration,Withdrawal,Deposit\n05-02-2026,ATM,500.00,\n';
      final result = parseCsvDocument(utf8.encode(fixture), mapping);

      expect(
        result.transactions.single.direction,
        TransactionDirection.moneyOut,
      );
      expect(result.transactions.single.amountMinor, 50000);
    });

    test('a populated credit column posts as money in', () {
      const fixture =
          'Date,Narration,Withdrawal,Deposit\n05-02-2026,Salary,,2500.00\n';
      final result = parseCsvDocument(utf8.encode(fixture), mapping);

      expect(
        result.transactions.single.direction,
        TransactionDirection.moneyIn,
      );
      expect(result.transactions.single.amountMinor, 250000);
    });

    test('a row with both debit and credit populated is skipped', () {
      const fixture =
          'Date,Narration,Withdrawal,Deposit\n05-02-2026,Weird,100.00,50.00\n';
      final result = parseCsvDocument(utf8.encode(fixture), mapping);

      expect(result.transactions, isEmpty);
      expect(result.skippedRows, hasLength(1));
    });

    test('a row with neither debit nor credit populated is skipped', () {
      const fixture = 'Date,Narration,Withdrawal,Deposit\n05-02-2026,Empty,,\n';
      final result = parseCsvDocument(utf8.encode(fixture), mapping);

      expect(result.transactions, isEmpty);
      expect(result.skippedRows, hasLength(1));
    });
  });

  group('parseCsvDocument: decimal separator and reference id', () {
    test('a European decimal separator is parsed correctly', () {
      const mapping = CsvColumnMapping(
        hasHeaderRow: true,
        dateColumnIndex: 0,
        datePattern: 'dd.MM.yyyy',
        descriptionColumnIndexes: [1],
        amountConvention: CsvAmountConvention.signedColumn,
        signedAmountColumnIndex: 2,
        currency: 'CHF',
        decimalSeparator: ',',
      );
      // The amount field is quoted because it contains a literal comma
      // (the decimal separator here) that would otherwise collide with
      // the CSV field delimiter - the RFC 4180-correct way a real export
      // using comma decimals represents this.
      const fixture = 'Datum,Text,Betrag\n03.02.2026,Migros,"-1.234,56"\n';

      final result = parseCsvDocument(utf8.encode(fixture), mapping);

      expect(result.transactions.single.amountMinor, 123456);
    });

    test('concatenates multiple description columns', () {
      const mapping = CsvColumnMapping(
        hasHeaderRow: true,
        dateColumnIndex: 0,
        datePattern: 'dd/MM/yyyy',
        descriptionColumnIndexes: [1, 2],
        amountConvention: CsvAmountConvention.signedColumn,
        signedAmountColumnIndex: 3,
        currency: 'USD',
      );
      const fixture =
          'Date,Payee,Reference,Amount\n01/02/2026,ACME Corp,INV-42,-10.00\n';

      final result = parseCsvDocument(utf8.encode(fixture), mapping);

      expect(result.transactions.single.description, 'ACME Corp - INV-42');
    });

    test('maps a reference-id column to externalReferenceId', () {
      const mapping = CsvColumnMapping(
        hasHeaderRow: true,
        dateColumnIndex: 0,
        datePattern: 'dd/MM/yyyy',
        descriptionColumnIndexes: [1],
        amountConvention: CsvAmountConvention.signedColumn,
        signedAmountColumnIndex: 2,
        referenceIdColumnIndex: 3,
        currency: 'USD',
      );
      const fixture =
          'Date,Description,Amount,Ref\n01/02/2026,Coffee,-4.50,TXN-001\n';

      final result = parseCsvDocument(utf8.encode(fixture), mapping);

      expect(result.transactions.single.externalReferenceId, 'TXN-001');
    });

    test(
      'a row with no reference-id column mapped has a null reference id',
      () {
        const mapping = CsvColumnMapping(
          hasHeaderRow: true,
          dateColumnIndex: 0,
          datePattern: 'dd/MM/yyyy',
          descriptionColumnIndexes: [1],
          amountConvention: CsvAmountConvention.signedColumn,
          signedAmountColumnIndex: 2,
          currency: 'USD',
        );
        const fixture = 'Date,Description,Amount\n01/02/2026,Coffee,-4.50\n';

        final result = parseCsvDocument(utf8.encode(fixture), mapping);

        expect(result.transactions.single.externalReferenceId, isNull);
      },
    );
  });
}
