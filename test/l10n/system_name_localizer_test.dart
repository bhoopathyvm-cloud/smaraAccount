import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/l10n/l10n.dart';

void main() {
  test(
    'unchanged seed names map through AppLocalizations; custom names pass through',
    () {
      final en = lookupAppLocalizations(const Locale('en'));
      expect(
        localizeStoredName(en, kSystemGroupCashEquivalents),
        equals(en.systemGroupCashEquivalents),
      );
      expect(localizeStoredName(en, 'My checking'), equals('My checking'));
    },
  );

  test('Tamil maps an unchanged seed name to the Tamil ARB label', () {
    final ta = lookupAppLocalizations(const Locale('ta'));
    expect(
      localizeStoredName(ta, kSystemGroupCashEquivalents),
      equals(ta.systemGroupCashEquivalents),
    );
    expect(
      ta.systemGroupCashEquivalents,
      isNot(equals(kSystemGroupCashEquivalents)),
    );
  });

  test('the CSV/OFX import description sentinels localize like seed names', () {
    final ta = lookupAppLocalizations(const Locale('ta'));
    expect(
      localizeStoredName(ta, kSystemDescriptionCsvImport),
      equals(ta.systemDescriptionCsvImport),
    );
    expect(
      localizeStoredName(ta, kSystemDescriptionOfxImport),
      equals(ta.systemDescriptionOfxImport),
    );
  });

  group('editingNameFor', () {
    test('is the same mapping as localizeStoredName', () {
      final ta = lookupAppLocalizations(const Locale('ta'));
      expect(
        editingNameFor(ta, kSystemAccountCashBank),
        equals(localizeStoredName(ta, kSystemAccountCashBank)),
      );
      expect(
        editingNameFor(ta, 'My custom account'),
        equals('My custom account'),
      );
    });
  });

  group('canonicalNameToPersist', () {
    test('leaving the Tamil-localized display of an unchanged seed persists '
        'the English seed', () {
      final ta = lookupAppLocalizations(const Locale('ta'));
      final edited = editingNameFor(ta, kSystemAccountCashBank);
      expect(
        canonicalNameToPersist(ta, kSystemAccountCashBank, edited),
        equals(kSystemAccountCashBank),
      );
    });

    test('retyping the English seed itself also persists the English seed', () {
      final ta = lookupAppLocalizations(const Locale('ta'));
      expect(
        canonicalNameToPersist(
          ta,
          kSystemAccountCashBank,
          kSystemAccountCashBank,
        ),
        equals(kSystemAccountCashBank),
      );
    });

    test('a real custom rename is persisted as typed, trimmed', () {
      final ta = lookupAppLocalizations(const Locale('ta'));
      expect(
        canonicalNameToPersist(ta, kSystemAccountCashBank, '  My Wallet  '),
        equals('My Wallet'),
      );
    });

    test('a Tamil rename that happens to differ from the localized seed is '
        'persisted as typed, not canonicalized away', () {
      final ta = lookupAppLocalizations(const Locale('ta'));
      const customTamilName = 'என் பணப்பை';
      expect(
        canonicalNameToPersist(ta, kSystemAccountCashBank, customTamilName),
        equals(customTamilName),
      );
    });

    test('an English-locale edit round-trips the same way', () {
      final en = lookupAppLocalizations(const Locale('en'));
      final edited = editingNameFor(en, kSystemGroupInvestments);
      expect(
        canonicalNameToPersist(en, kSystemGroupInvestments, edited),
        equals(kSystemGroupInvestments),
      );
      expect(
        canonicalNameToPersist(en, kSystemGroupInvestments, 'Brokerage'),
        equals('Brokerage'),
      );
    });
  });
}
