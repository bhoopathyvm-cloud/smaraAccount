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
}
