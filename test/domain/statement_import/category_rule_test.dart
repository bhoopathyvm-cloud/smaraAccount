import 'package:smara_accounting/domain/statement_import/category_rule.dart';
import 'package:test/test.dart';

void main() {
  CategoryRule rule({
    required String keyword,
    required String categoryId,
    required DateTime createdAt,
  }) {
    return CategoryRule(
      id: keyword,
      keyword: keyword,
      categoryId: categoryId,
      createdAt: createdAt,
    );
  }

  group('normalizeDescription', () {
    test('trims and lowercases', () {
      expect(normalizeDescription('  AMAZON.COM  '), 'amazon.com');
    });
  });

  group('matchCategoryRule', () {
    test('matches a description containing the keyword', () {
      final rules = [
        rule(keyword: 'AMAZON', categoryId: 'cat-1', createdAt: DateTime(2026)),
      ];

      expect(matchCategoryRule('AMAZON.COM*A1B2C3 SEATTLE WA', rules), 'cat-1');
    });

    test('matching is case-insensitive', () {
      final rules = [
        rule(keyword: 'amazon', categoryId: 'cat-1', createdAt: DateTime(2026)),
      ];

      expect(matchCategoryRule('AMAZON.COM', rules), 'cat-1');
    });

    test('matching tolerates surrounding whitespace in the description', () {
      final rules = [
        rule(keyword: 'AMAZON', categoryId: 'cat-1', createdAt: DateTime(2026)),
      ];

      expect(matchCategoryRule('  amazon.com  ', rules), 'cat-1');
    });

    test('returns null when no rule matches', () {
      final rules = [
        rule(keyword: 'AMAZON', categoryId: 'cat-1', createdAt: DateTime(2026)),
      ];

      expect(matchCategoryRule('STARBUCKS #123', rules), isNull);
    });

    test('returns null for an empty rule list', () {
      expect(matchCategoryRule('AMAZON.COM', const []), isNull);
    });

    test('a rule with a blank keyword never matches', () {
      final rules = [
        rule(keyword: '   ', categoryId: 'cat-1', createdAt: DateTime(2026)),
      ];

      expect(matchCategoryRule('Anything at all', rules), isNull);
    });

    test('when multiple rules match, the most recently created one wins', () {
      final rules = [
        rule(
          keyword: 'AMAZON',
          categoryId: 'cat-old',
          createdAt: DateTime(2026, 1, 1),
        ),
        rule(
          keyword: 'AMAZON.COM',
          categoryId: 'cat-new',
          createdAt: DateTime(2026, 2, 1),
        ),
      ];

      expect(matchCategoryRule('AMAZON.COM PURCHASE', rules), 'cat-new');
    });

    test(
      'creation order in the input list does not affect the most-recent-wins outcome',
      () {
        final rules = [
          rule(
            keyword: 'AMAZON.COM',
            categoryId: 'cat-new',
            createdAt: DateTime(2026, 2, 1),
          ),
          rule(
            keyword: 'AMAZON',
            categoryId: 'cat-old',
            createdAt: DateTime(2026, 1, 1),
          ),
        ];

        expect(matchCategoryRule('AMAZON.COM PURCHASE', rules), 'cat-new');
      },
    );
  });
}
