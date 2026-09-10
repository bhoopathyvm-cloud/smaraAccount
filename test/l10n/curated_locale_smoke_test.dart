import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/l10n/l10n.dart';

import '../../integration_test/acceptance/support/acceptance_locale.dart';
import '../../integration_test/acceptance/support/locale_fixtures.dart';

const _smokeLocaleTag = String.fromEnvironment(
  'SMOKE_LOCALE',
  defaultValue: 'ja', // 'en' isn't in kCuratedAcceptanceLocales
);

void main() {
  test('smoke locale is supported and curated', () {
    expect(kSupportedLocaleTags, contains(_smokeLocaleTag));
    expect(kCuratedAcceptanceLocales, contains(_smokeLocaleTag));
  });

  test('smoke locale loads core app chrome and acceptance fixtures', () {
    final l10n = l10nFor(_smokeLocaleTag);
    final fixtures = fixturesForTag(_smokeLocaleTag);

    expect(l10n.navHome, isNotEmpty);
    expect(l10n.settingsTitle, isNotEmpty);
    expect(l10n.errorGeneric, isNotEmpty);
    expect(endonymForLocaleTag(_smokeLocaleTag), isNot(_smokeLocaleTag));
    expect(fixtures.payeeName, isNotEmpty);
    expect(fixtures.coffeeRunDescription, contains(fixtures.coffeeSearchTerm));
    expect(fixtures.payeeName, contains(fixtures.payeeSearchQuery));
  });

  testWidgets('smoke locale resolves in MaterialApp', (tester) async {
    final expected = l10nFor(_smokeLocaleTag).navHome;

    await tester.pumpWidget(
      MaterialApp(
        locale: localeFromTag(_smokeLocaleTag),
        localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
        supportedLocales: supportedAppLocales,
        home: Builder(builder: (context) => Text(l10nOf(context).navHome)),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text(expected), findsOneWidget);

    if (_smokeLocaleTag == 'ar' || _smokeLocaleTag == 'ur') {
      expect(
        Directionality.of(tester.element(find.text(expected))),
        TextDirection.rtl,
      );
    }
  });
}
