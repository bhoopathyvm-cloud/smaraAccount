import 'package:test/test.dart';

import 'package:smara_accounting/domain/ledger_export/ledger_csv_exporter.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/register/register_projection.dart';
import 'package:smara_accounting/domain/register/register_row.dart';

RegisterProjectedEntry _entry({
  required DateTime date,
  required String description,
  required TransactionDirection direction,
  required List<RegisterExportLeg> legs,
  bool isVerified = true,
}) {
  return RegisterProjectedEntry(
    row: RegisterRow(
      entryId: 'e',
      categoryName: legs.first.label,
      counterpartAccountIds: const ['c1'],
      direction: direction,
      amountMinor: legs.fold(0, (s, l) => s + l.amountMinor),
      currency: 'USD',
      transactionDate: date,
      description: description,
      runningBalanceMinor: 0,
      isReversal: false,
      isVerified: isVerified,
      breakReason: null,
      isSupersededByMigration: false,
    ),
    legs: legs,
  );
}

void main() {
  group('ledger csv exporter', () {
    test('escapeCsvField quotes commas and doubles quotes', () {
      expect(escapeCsvField('plain'), 'plain');
      expect(escapeCsvField('a,b'), '"a,b"');
      expect(escapeCsvField('say "hi"'), '"say ""hi"""');
    });

    test('formatCsvAmount is locale-independent with currency digits', () {
      expect(formatCsvAmount(12345, 'USD'), '123.45');
      expect(formatCsvAmount(12345, 'JPY'), '12345');
    });

    test('buildLedgerCsv emits header and oldest-first rows', () {
      final csv = buildLedgerCsv(
        projected: [
          _entry(
            date: DateTime(2026, 1, 20),
            description: 'Paycheck',
            direction: TransactionDirection.moneyIn,
            legs: const [
              RegisterExportLeg(label: 'Salary', amountMinor: 300000),
            ],
          ),
          _entry(
            date: DateTime(2026, 1, 5),
            description: 'Groceries, run',
            direction: TransactionDirection.moneyOut,
            legs: const [RegisterExportLeg(label: 'Food', amountMinor: 5000)],
          ),
        ],
        currency: 'USD',
      );
      final lines = csv.trim().split('\n');
      expect(
        lines[0],
        'Date,Description,Category,Direction,Amount,Currency,Verified',
      );
      expect(
        lines[1],
        startsWith('2026-01-05,"Groceries, run",Food,Spent,50.00'),
      );
      expect(lines[2], endsWith(',USD,Yes'));
      expect(lines[2], contains('Received'));
    });
  });
}
