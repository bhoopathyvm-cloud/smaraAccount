import 'parsed_ofx_transaction.dart';

/// One previewed row the user has selected and categorized, ready to post.
/// Deselected, uncategorized, and unparseable rows never become one of
/// these - they're filtered out before `postAcceptedRows` is called.
class OfxAcceptedRow {
  const OfxAcceptedRow({required this.transaction, required this.categoryId});

  final ParsedOfxTransaction transaction;
  final String categoryId;
}

/// The outcome of posting one accepted row.
class OfxPostedRow {
  const OfxPostedRow({required this.transaction, this.error});

  final ParsedOfxTransaction transaction;

  /// Null on success.
  final String? error;

  bool get succeeded => error == null;
}

/// The outcome of posting a whole batch of accepted rows
/// (ofx-transaction-import design.md Decision 5): posting is sequential
/// and per-row, so one row's failure never prevents the others from
/// posting.
class OfxImportBatchResult {
  const OfxImportBatchResult({required this.results});

  final List<OfxPostedRow> results;

  int get postedCount => results.where((r) => r.succeeded).length;
  int get failedCount => results.where((r) => !r.succeeded).length;
}
