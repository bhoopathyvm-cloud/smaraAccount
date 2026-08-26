import 'category_rule.dart';
import 'parsed_statement_transaction.dart';

/// Immutable preview row produced at the statement-import seam before the
/// ViewModel wraps it in editable UI state (statement-import-preview).
class StatementImportPreviewDraft {
  const StatementImportPreviewDraft({
    required this.transaction,
    required this.isDuplicate,
    this.suggestedCategoryId,
  });

  final ParsedStatementTransaction transaction;
  final bool isDuplicate;
  final String? suggestedCategoryId;
}

/// One-shot preview: account currency for the mismatch gate, plus a draft
/// per parsed transaction (duplicate flags and suggested categories).
class StatementImportPreview {
  const StatementImportPreview({
    required this.accountCurrency,
    required this.rows,
  });

  final String? accountCurrency;
  final List<StatementImportPreviewDraft> rows;
}

/// Combines duplicate flags, category-rule matches, and memo-suggestion
/// fallbacks into preview drafts. Pure so unit tests can exercise policy
/// without a repository or widgets.
List<StatementImportPreviewDraft> buildStatementImportPreviewDrafts({
  required List<ParsedStatementTransaction> transactions,
  required Set<int> duplicateIndexes,
  required List<CategoryRule> rules,
  required Map<String, String?> suggestionsByDescription,
}) {
  return [
    for (var i = 0; i < transactions.length; i++)
      StatementImportPreviewDraft(
        transaction: transactions[i],
        isDuplicate: duplicateIndexes.contains(i),
        suggestedCategoryId:
            matchCategoryRule(transactions[i].description, rules) ??
            suggestionsByDescription[transactions[i].description],
      ),
  ];
}
