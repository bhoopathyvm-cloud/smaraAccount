import '../models/transaction_direction.dart';

/// One normalized transaction parsed out of an OFX `STMTTRN`/`CCSTMTTRN`
/// aggregate, independent of whether the source file was OFX 1.x or 2.x.
class ParsedOfxTransaction {
  const ParsedOfxTransaction({
    required this.transactionDate,
    required this.amountMinor,
    required this.direction,
    required this.description,
    required this.currency,
    this.fitid,
  });

  final DateTime transactionDate;
  final int amountMinor;
  final TransactionDirection direction;
  final String description;

  /// Denormalized from the statement's `CURDEF`.
  final String currency;

  /// The bank's own stable transaction id (`FITID`), when present.
  final String? fitid;

  /// Fallback de-duplication key used when [fitid] is absent (design.md
  /// Decision 2): `transactionDate|amountMinor|direction|description`.
  String get fallbackMatchKey {
    final date = transactionDate.toIso8601String().substring(0, 10);
    return '$date|$amountMinor|${direction.name}|$description';
  }
}

/// A transaction row that failed to parse; the row is skipped rather than
/// aborting the rest of the file.
class OfxSkippedRow {
  const OfxSkippedRow({required this.rawFragment, required this.reason});

  final String rawFragment;
  final String reason;
}

/// Result of parsing one OFX file: successfully parsed transactions plus
/// any rows that had to be skipped, and the statement's declared currency
/// (`CURDEF`), if present.
class OfxParseResult {
  const OfxParseResult({
    required this.transactions,
    required this.skippedRows,
    required this.statementCurrency,
  });

  final List<ParsedOfxTransaction> transactions;
  final List<OfxSkippedRow> skippedRows;
  final String? statementCurrency;
}
