import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/core/app_theme.dart';

const _scheduledIndianTags = [
  'as', 'bn', 'brx', 'doi', 'gu', 'hi', 'kn', 'ks', 'kok', 'mai', 'ml',
  'mni', 'mr', 'ne', 'or', 'pa', 'sa', 'sat', 'sd', 'ta', 'te', 'ur',
];

void main() {
  test('supported locales include English, 22 Indian languages, and pack tags', () {
    expect(kSupportedLocaleTags, contains('en'));
    for (final tag in _scheduledIndianTags) {
      expect(kSupportedLocaleTags, contains(tag), reason: tag);
    }
    expect(kSupportedLocaleTags, containsAll(['de', 'fr', 'ja', 'zh', 'ko', 'ar', 'ru']));
    expect(
      kSupportedLocaleTags.where((tag) => tag != 'en').toSet(),
      containsAll(_scheduledIndianTags),
    );
    expect(
      _scheduledIndianTags.toSet().length,
      22,
    );
  });

  test('language picker endonyms cover every supported tag in native script', () {
    for (final tag in kSupportedLocaleTags) {
      expect(kLocaleEndonyms[tag], isNotNull, reason: tag);
      expect(endonymForLocaleTag(tag), isNot(equals(tag)));
    }
    expect(endonymForLocaleTag('ta'), 'தமிழ்');
    expect(endonymForLocaleTag('hi'), 'हिन्दी');
    expect(endonymForLocaleTag('ur'), 'اردو');
    expect(endonymForLocaleTag('ar'), 'العربية');
    expect(endonymForLocaleTag('ja'), '日本語');
    expect(endonymForLocaleTag('mni'), 'ꯃꯤꯇꯩ ꯂꯣꯟ');
    expect(endonymForLocaleTag('sat'), 'ᱥᱟᱱᱛᱟᱲᱤ');
    expect(endonymForLocaleTag('sd'), 'سنڌي');
  });

  test('key parity: every English ARB getter exists for all pack locales', () {
    final en = lookupAppLocalizations(const Locale('en'));
    for (final tag in kSupportedLocaleTags) {
      final l10n = lookupAppLocalizations(localeFromTag(tag));
      expect(l10n.navHome, isNotEmpty, reason: tag);
      expect(l10n.settingsTitle, isNotEmpty, reason: tag);
      expect(l10n.errorGeneric, isNotEmpty, reason: tag);
      expect(l10n.errorAmountMustBePositive, isNotEmpty, reason: tag);
    }
    expect(en.errorAmountMustBePositive, 'Amount must be positive.');
  });

  test('Tamil localizes a sample error instead of leaving the English ARB', () {
    final ta = lookupAppLocalizations(const Locale('ta'));
    expect(
      localizeError(ta, AppErrorCode.amountMustBePositive),
      equals('தொகை நேர்மறையாக இருக்க வேண்டும்.'),
    );
    expect(
      localizeError(ta, AppErrorCode.amountMustBePositive),
      isNot(equals(englishAppLocalizations.errorAmountMustBePositive)),
    );
  });

  test('untranslated Tamil keys still fall back to the English template text', () {
    final ta = lookupAppLocalizations(const Locale('ta'));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(ta.settingsFetchFxRatesSubtitle, equals(en.settingsFetchFxRatesSubtitle));
  });

  testWidgets('Arabic and Urdu activate RTL on a MaterialApp', (tester) async {
    for (final tag in ['ar', 'ur']) {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(tag),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedAppLocales,
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) {
              return Scaffold(
                appBar: AppBar(title: Text(l10nOf(context).navHome)),
                body: Text(l10nOf(context).settingsTitle),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(Directionality.of(tester.element(find.byType(Scaffold))), TextDirection.rtl);
    }
  });

  testWidgets('German, French, Hindi, Japanese, and Marathi switch chrome text',
      (tester) async {
    Future<void> pumpLocale(String tag, String expectedHome) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: localeFromTag(tag),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedAppLocales,
          home: Builder(
            builder: (context) => Text(l10nOf(context).navHome),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(expectedHome), findsOneWidget);
    }

    await pumpLocale('de', 'Start');
    await pumpLocale('fr', 'Accueil');
    await pumpLocale('hi', 'होम');
    await pumpLocale('ja', 'ホーム');
    await pumpLocale('mr', 'मुख्यपृष्ठ');
    await pumpLocale('gu', 'હોમ');
    await pumpLocale('bn', 'হোম');
  });

  test('theme font fallback lists Indic, Arabic, CJK, Thai, Meitei, and Ol Chiki', () {
    expect(
      kFontFamilyFallback,
      containsAll([
        'Noto Sans Devanagari',
        'Noto Sans Tamil',
        'Noto Naskh Arabic',
        'Noto Sans CJK SC',
        'Noto Sans Thai',
        'Noto Sans Meetei Mayek',
        'Noto Sans Ol Chiki',
      ]),
    );
  });
}
