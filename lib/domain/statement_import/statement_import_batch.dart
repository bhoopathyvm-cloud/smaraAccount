import 'parsed_statement_transaction.dart';

/// One previewed row the user has selected and categorized, ready to post.
/// Deselected, uncategorized, and unparseable rows never become one of
/// these - they're filtered out before `postAcceptedRows` is called.
class StatementAcceptedRow {
  const StatementAcceptedRow({
    required this.transaction,
    required this.categoryId,
  });

  final ParsedStatementTransaction transaction;
  final String categoryId;
}

/// The outcome of posting one accepted row.
class StatementPostedRow {
  const StatementPostedRow({required this.transaction, this.error});

  final ParsedStatementTransaction transaction;

  /// Null on success.
  final String? error;

  bool get succeeded => error == null;
}

/// The outcome of posting a whole batch of accepted rows
/// (ofx-transaction-import design.md Decision 5): posting is sequential
/// and per-row, so one row's failure never prevents the others from
/// posting.
class StatementImportBatchResult {
  const StatementImportBatchResult({required this.results});

  final List<StatementPostedRow> results;

  int get postedCount => results.where((r) => r.succeeded).length;
  int get failedCount => results.where((r) => !r.succeeded).length;
}
