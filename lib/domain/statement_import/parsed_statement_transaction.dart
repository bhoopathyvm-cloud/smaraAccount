import '../models/transaction_direction.dart';

/// One normalized transaction parsed out of an imported statement file -
/// OFX or CSV (csv-transaction-import design.md Decision 4: source-agnostic
/// so both feed the same review/dedupe/categorize/post pipeline).
class ParsedStatementTransaction {
  const ParsedStatementTransaction({
    required this.transactionDate,
    required this.amountMinor,
    required this.direction,
    required this.description,
    required this.currency,
    this.externalReferenceId,
  });

  final DateTime transactionDate;
  final int amountMinor;
  final TransactionDirection direction;
  final String description;

  /// OFX: denormalized from the statement's `CURDEF`. CSV: user-supplied
  /// during column mapping, since a CSV file never embeds a currency.
  final String currency;

  /// The source's own stable transaction id, when present - OFX's `FITID`,
  /// or a CSV column the user mapped as a reference id. Authoritative
  /// de-duplication key when present; falls back to [fallbackMatchKey]
  /// when absent.
  final String? externalReferenceId;

  /// Fallback de-duplication key used when [externalReferenceId] is absent
  /// (ofx-transaction-import design.md Decision 2):
  /// `transactionDate|amountMinor|direction|description`.
  String get fallbackMatchKey {
    final date = transactionDate.toIso8601String().substring(0, 10);
    return '$date|$amountMinor|${direction.name}|$description';
  }
}

/// A transaction row that failed to parse; the row is skipped rather than
/// aborting the rest of the file.
class StatementSkippedRow {
  const StatementSkippedRow({required this.rawFragment, required this.reason});

  final String rawFragment;
  final String reason;
}

/// Result of parsing one statement file: successfully parsed transactions
/// plus any rows that had to be skipped, and the statement's currency, if
/// known (OFX: from `CURDEF`; CSV: from the user's mapping-step selection).
class StatementParseResult {
  const StatementParseResult({
    required this.transactions,
    required this.skippedRows,
    required this.statementCurrency,
  });

  final List<ParsedStatementTransaction> transactions;
  final List<StatementSkippedRow> skippedRows;
  final String? statementCurrency;
}
