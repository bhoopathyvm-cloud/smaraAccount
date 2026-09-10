import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/l10n/supported_locales.dart';

import '../integration_test/acceptance/support/locale_fixtures.dart';

void main() {
  test('every curated locale tag is a supported app locale', () {
    for (final tag in kCuratedAcceptanceLocales) {
      expect(kSupportedLocaleTags, contains(tag));
    }
  });

  test('coffeeSearchTerm is a substring of coffeeRunDescription for every '
      'curated locale', () {
    for (final tag in kCuratedAcceptanceLocales) {
      final fixtures = fixturesForTag(tag);
      expect(
        fixtures.coffeeRunDescription.contains(fixtures.coffeeSearchTerm),
        isTrue,
        reason:
            'locale "$tag": "${fixtures.coffeeSearchTerm}" is not a '
            'substring of "${fixtures.coffeeRunDescription}"',
      );
    }
  });

  test('payeeSearchQuery is a substring of payeeName for every curated '
      'locale', () {
    for (final tag in kCuratedAcceptanceLocales) {
      final fixtures = fixturesForTag(tag);
      expect(
        fixtures.payeeName.contains(fixtures.payeeSearchQuery),
        isTrue,
        reason:
            'locale "$tag": "${fixtures.payeeSearchQuery}" is not a '
            'substring of "${fixtures.payeeName}"',
      );
    }
  });

  test('an uncurated tag falls back to the English fixtures', () {
    final fixtures = fixturesForTag('pl');
    expect(fixtures.newGroupName, 'Euro Group');
  });
}
