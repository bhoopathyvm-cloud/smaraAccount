import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/statement_import/category_rule.dart';
import 'package:smara_accounting/domain/statement_import/parsed_statement_transaction.dart';
import 'package:smara_accounting/domain/statement_import/statement_import_preview.dart';
import 'package:test/test.dart';

void main() {
  final groceries = ParsedStatementTransaction(
    transactionDate: DateTime(2026, 2, 2),
    amountMinor: 6453,
    direction: TransactionDirection.moneyOut,
    description: 'WHOLE FOODS MARKET',
    currency: 'USD',
    externalReferenceId: 'FIT-1',
  );
  final coffee = ParsedStatementTransaction(
    transactionDate: DateTime(2026, 2, 4),
    amountMinor: 575,
    direction: TransactionDirection.moneyOut,
    description: 'BLUE BOTTLE COFFEE',
    currency: 'USD',
    externalReferenceId: 'FIT-2',
  );

  test('rule match takes priority over memo suggestion', () {
    final drafts = buildStatementImportPreviewDrafts(
      transactions: [groceries, coffee],
      duplicateIndexes: const {},
      rules: [
        CategoryRule(
          id: 'rule-1',
          keyword: 'WHOLE FOODS',
          categoryId: 'cat-groceries',
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      suggestionsByDescription: {
        'WHOLE FOODS MARKET': 'cat-transport',
        'BLUE BOTTLE COFFEE': 'cat-coffee',
      },
    );

    expect(drafts, hasLength(2));
    expect(drafts[0].suggestedCategoryId, 'cat-groceries');
    expect(drafts[1].suggestedCategoryId, 'cat-coffee');
    expect(drafts[0].isDuplicate, isFalse);
  });

  test('duplicate flags and missing suggestions are preserved', () {
    final drafts = buildStatementImportPreviewDrafts(
      transactions: [groceries, coffee],
      duplicateIndexes: {1},
      rules: const [],
      suggestionsByDescription: const {},
    );

    expect(drafts[0].isDuplicate, isFalse);
    expect(drafts[1].isDuplicate, isTrue);
    expect(drafts[0].suggestedCategoryId, isNull);
    expect(drafts[1].suggestedCategoryId, isNull);
  });
}
