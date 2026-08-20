import 'dart:convert';

import 'package:csv/csv.dart';

import '../exceptions.dart';
import '../models/transaction_direction.dart';
import '../statement_import/parsed_statement_transaction.dart';
import 'csv_column_mapping.dart';

const _bom = [0xEF, 0xBB, 0xBF];

/// Reads [bytes] as CSV and returns its rows as raw string cells, with no
/// column mapping applied yet - used both to sniff a file's header row
/// (for account-currency defaults and profile matching) and as the first
/// step of [parseCsvDocument]. Blank rows are dropped.
///
/// Throws [CsvParseException] when the file can't be read as delimited
/// CSV data at all (spec: "A file that isn't CSV at all is rejected").
List<List<String>> readCsvRows(List<int> bytes) {
  final content = _decode(bytes);
  if (content.trim().isEmpty) {
    throw CsvParseException('The selected file is empty.', code: AppErrorCode.csvEmpty);
  }

  final List<List<dynamic>> rawRows;
  try {
    rawRows = const CsvDecoder().convert(content);
  } catch (error) {
    throw CsvParseException('Could not read this file as CSV: $error', code: AppErrorCode.csvUnreadable);
  }

  final rows = rawRows
      .map((row) => row.map((cell) => cell.toString()).toList())
      .where((row) => row.any((cell) => cell.trim().isNotEmpty))
      .toList();

  if (rows.isEmpty) {
    throw CsvParseException('The selected file has no rows.', code: AppErrorCode.csvNoRows);
  }
  return rows;
}

/// Applies [mapping] to [bytes] and produces a normalized
/// [StatementParseResult], the CSV counterpart to `parseOfxDocument`. A
/// row that doesn't fit the mapping is reported as a [StatementSkippedRow]
/// rather than aborting the rest of the file.
StatementParseResult parseCsvDocument(
  List<int> bytes,
  CsvColumnMapping mapping,
) {
  final rows = readCsvRows(bytes);
  final dataRows = mapping.hasHeaderRow ? rows.skip(1) : rows;

  final transactions = <ParsedStatementTransaction>[];
  final skippedRows = <StatementSkippedRow>[];

  for (final row in dataRows) {
    final parsed = _parseRow(row, mapping);
    final transaction = parsed.transaction;
    final skipReason = parsed.skipReason;
    if (transaction != null) {
      transactions.add(transaction);
    } else if (skipReason != null) {
      skippedRows.add(
        StatementSkippedRow(rawFragment: row.join(','), reason: skipReason),
      );
    }
  }

  return StatementParseResult(
    transactions: transactions,
    skippedRows: skippedRows,
    statementCurrency: mapping.currency,
  );
}

/// Strips a UTF-8 BOM if present and decodes permissively (matching
/// ofx-transaction-import's approach to non-clean-UTF-8 bank exports).
String _decode(List<int> bytes) {
  final withoutBom =
      bytes.length >= 3 &&
          bytes[0] == _bom[0] &&
          bytes[1] == _bom[1] &&
          bytes[2] == _bom[2]
      ? bytes.sublist(3)
      : bytes;
  return utf8.decode(withoutBom, allowMalformed: true);
}

class _ParsedRow {
  const _ParsedRow.ok(this.transaction) : skipReason = null;
  const _ParsedRow.skip(this.skipReason) : transaction = null;

  final ParsedStatementTransaction? transaction;
  final String? skipReason;
}

_ParsedRow _parseRow(List<String> row, CsvColumnMapping mapping) {
  String field(int index) {
    if (index < 0 || index >= row.length) return '';
    return row[index].trim();
  }

  final dateRaw = field(mapping.dateColumnIndex);
  if (dateRaw.isEmpty) {
    return const _ParsedRow.skip('Missing date.');
  }
  final date = _parseDateWithPattern(dateRaw, mapping.datePattern);
  if (date == null) {
    return _ParsedRow.skip(
      'Could not parse date "$dateRaw" with pattern "${mapping.datePattern}".',
    );
  }

  int amountMinor;
  TransactionDirection direction;
  switch (mapping.amountConvention) {
    case CsvAmountConvention.signedColumn:
      final raw = field(mapping.signedAmountColumnIndex!);
      final parsed = _parseAmount(raw, mapping.decimalSeparator);
      if (parsed == null) {
        return _ParsedRow.skip('Could not parse amount "$raw".');
      }
      if (parsed == 0) {
        return const _ParsedRow.skip('Amount is zero.');
      }
      amountMinor = parsed.abs();
      direction = parsed > 0
          ? TransactionDirection.moneyIn
          : TransactionDirection.moneyOut;

    case CsvAmountConvention.debitCreditColumns:
      final debitRaw = field(mapping.debitColumnIndex!);
      final creditRaw = field(mapping.creditColumnIndex!);
      final debit = debitRaw.isEmpty
          ? 0
          : _parseAmount(debitRaw, mapping.decimalSeparator)?.abs();
      final credit = creditRaw.isEmpty
          ? 0
          : _parseAmount(creditRaw, mapping.decimalSeparator)?.abs();
      if (debit == null || credit == null) {
        return const _ParsedRow.skip('Could not parse debit/credit amount.');
      }
      if (debit > 0 && credit > 0) {
        return const _ParsedRow.skip(
          'Both debit and credit columns are non-zero.',
        );
      }
      if (debit == 0 && credit == 0) {
        return const _ParsedRow.skip('Both debit and credit columns are zero.');
      }
      amountMinor = debit > 0 ? debit : credit;
      direction = debit > 0
          ? TransactionDirection.moneyOut
          : TransactionDirection.moneyIn;
  }

  final description = mapping.descriptionColumnIndexes
      .map(field)
      .where((s) => s.isNotEmpty)
      .join(' - ');

  final referenceIdIndex = mapping.referenceIdColumnIndex;
  final referenceId = referenceIdIndex == null ? null : field(referenceIdIndex);

  return _ParsedRow.ok(
    ParsedStatementTransaction(
      transactionDate: date,
      amountMinor: amountMinor,
      direction: direction,
      description: description.isEmpty ? 'CSV import' : description,
      currency: mapping.currency,
      externalReferenceId: (referenceId == null || referenceId.isEmpty)
          ? null
          : referenceId,
    ),
  );
}

/// A small pattern language of `d`/`M`/`y` tokens separated by any
/// non-letter character - never inferred, always the mapping's explicit
/// choice (design.md Risk: date-format ambiguity).
DateTime? _parseDateWithPattern(String value, String pattern) {
  final patternParts = pattern
      .split(RegExp('[^a-zA-Z]+'))
      .where((s) => s.isNotEmpty)
      .toList();
  final valueParts = value
      .split(RegExp('[^0-9]+'))
      .where((s) => s.isNotEmpty)
      .toList();
  if (patternParts.isEmpty || patternParts.length != valueParts.length) {
    return null;
  }

  int? day;
  int? month;
  int? year;
  for (var i = 0; i < patternParts.length; i++) {
    final token = patternParts[i].toLowerCase();
    final number = int.tryParse(valueParts[i]);
    if (number == null) return null;
    if (token.startsWith('d')) {
      day = number;
    } else if (token.startsWith('m')) {
      month = number;
    } else if (token.startsWith('y')) {
      year = valueParts[i].length <= 2 ? _expandTwoDigitYear(number) : number;
    }
  }
  if (day == null || month == null || year == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return DateTime(year, month, day);
}

int _expandTwoDigitYear(int year) => year < 70 ? 2000 + year : 1900 + year;

/// Parses a decimal amount string into signed minor units without going
/// through `double` (avoids binary-float rounding), tolerating currency
/// symbols, thousands separators, whitespace, a leading `+`/`-`, and
/// parenthesized negatives (e.g. `(12.34)`), per [decimalSeparator]
/// (design.md Risk: decimal-separator ambiguity).
int? _parseAmount(String raw, String decimalSeparator) {
  var value = raw.trim();
  if (value.isEmpty) return null;

  var negative = false;
  if (value.startsWith('(') && value.endsWith(')')) {
    negative = true;
    value = value.substring(1, value.length - 1);
  }
  if (value.startsWith('-')) {
    negative = true;
    value = value.substring(1);
  } else if (value.startsWith('+')) {
    value = value.substring(1);
  }

  final buffer = StringBuffer();
  for (final char in value.split('')) {
    if (RegExp(r'\d').hasMatch(char) || char == decimalSeparator) {
      buffer.write(char == decimalSeparator ? '.' : char);
    }
  }
  final normalized = buffer.toString();
  if (normalized.isEmpty) return null;

  final match = RegExp(r'^(\d+)(?:\.(\d+))?$').firstMatch(normalized);
  if (match == null) return null;

  final whole = int.parse(match.group(1)!);
  final fractionRaw = match.group(2) ?? '';
  final paddedFraction = '$fractionRaw${'0' * 2}'.substring(0, 2);
  final fractionMinor = int.parse(paddedFraction);
  final minor = whole * 100 + fractionMinor;
  return negative ? -minor : minor;
}
