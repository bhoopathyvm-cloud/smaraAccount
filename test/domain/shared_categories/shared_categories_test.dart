import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/shared_categories/category_display_name.dart';
import 'package:smara_accounting/domain/shared_categories/category_merge.dart';
import 'package:smara_accounting/domain/shared_categories/category_translate_prompt.dart';
import 'package:smara_accounting/domain/models/research_tool.dart';
import 'package:test/test.dart';

void main() {
  group('resolveCategoryDisplayName', () {
    test('prefers app-locale translation', () {
      expect(
        resolveCategoryDisplayName(
          defaultName: 'Groceries',
          appLocale: 'de',
          translationsByLocale: const {'de': 'Lebensmittel', 'fr': 'Épicerie'},
        ),
        'Lebensmittel',
      );
    });

    test('falls back to default when translation missing', () {
      expect(
        resolveCategoryDisplayName(
          defaultName: 'Groceries',
          appLocale: 'ta',
          translationsByLocale: const {'de': 'Lebensmittel'},
        ),
        'Groceries',
      );
    });

    test('matches language prefix of regional locale', () {
      expect(
        resolveCategoryDisplayName(
          defaultName: 'Groceries',
          appLocale: 'de-CH',
          translationsByLocale: const {'de': 'Lebensmittel'},
        ),
        'Lebensmittel',
      );
    });
  });

  group('buildCategoryTranslatePrompt', () {
    test('payload is only the category name', () {
      final prompt = buildCategoryTranslatePrompt('Lebensmittel');
      expect(prompt, 'Lebensmittel');
      expect(prompt.contains('amount'), isFalse);
      expect(prompt.contains('account'), isFalse);
      expect(prompt.contains('\n'), isFalse);
    });

    test('Research Tool URI encodes only that text', () {
      final uri = categoryTranslateQueryUri(
        ResearchTool.chatGpt,
        '  Lebensmittel  ',
      );
      expect(uri, isNotNull);
      expect(uri!.queryParameters['q'], 'Lebensmittel');
      expect(uri.toString().contains('500'), isFalse);
      expect(uri.toString().toLowerCase().contains('salary'), isFalse);
    });
  });

  group('category merge helpers', () {
    test('automatic merge on same name+type across languages', () {
      final candidates = findAutomaticMerges([
        const CategoryNameCatalogEntry(
          id: 'a',
          type: AccountType.expense,
          defaultName: 'Groceries',
          translatedNames: ['Lebensmittel'],
          createdAt: null,
        ),
        const CategoryNameCatalogEntry(
          id: 'b',
          type: AccountType.expense,
          defaultName: 'Lebensmittel',
          createdAt: null,
        ),
        const CategoryNameCatalogEntry(
          id: 'c',
          type: AccountType.income,
          defaultName: 'Lebensmittel',
        ),
      ]);
      expect(candidates, hasLength(1));
      expect(candidates.single.survivorId, 'a');
      expect(candidates.single.absorbedId, 'b');
      expect(candidates.single.automatic, isTrue);
    });

    test('translation match suggests merge', () {
      final suggestion = suggestMergeForTranslation(
        categoryId: 'a',
        type: AccountType.expense,
        newTranslation: 'Lebensmittel',
        others: const [
          CategoryNameCatalogEntry(
            id: 'b',
            type: AccountType.expense,
            defaultName: 'Lebensmittel',
          ),
        ],
      );
      expect(suggestion, isNotNull);
      expect(suggestion!.automatic, isFalse);
      expect({
        suggestion.survivorId,
        suggestion.absorbedId,
      }, equals({'a', 'b'}));
    });

    test('resolveSurvivorCategoryId walks the merge map', () {
      expect(resolveSurvivorCategoryId('c', {'c': 'b', 'b': 'a'}), 'a');
    });
  });
}
