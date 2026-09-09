import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/onboarding/views/language_selection_view.dart';

Future<LocaleController> _loadedController() async {
  final controller = LocaleController(settingsRepository: SettingsRepository());
  await controller.load();
  return controller;
}

Widget _harness(LocaleController controller, {VoidCallback? onFinished}) {
  return ChangeNotifierProvider<LocaleController>.value(
    value: controller,
    child: Builder(
      builder: (context) {
        final watched = context.watch<LocaleController>();
        return MaterialApp(
          locale: watched.overrideLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedAppLocales,
          localeListResolutionCallback: (locales, supported) => watched.resolve(
            locales?.isNotEmpty == true ? locales!.first : null,
          ),
          home: LanguageSelectionView(onFinished: onFinished ?? () {}),
        );
      },
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets(
    'renders every supported locale by endonym, plus Same as device',
    (tester) async {
      final controller = await _loadedController();
      await tester.pumpWidget(_harness(controller));
      await tester.pumpAndSettle();

      final en = lookupAppLocalizations(const Locale('en'));
      expect(find.text(en.settingsLanguageSystem), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);
      await tester.dragUntilVisible(
        find.text('Français'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      expect(find.text('Français'), findsOneWidget);
    },
  );

  testWidgets('pre-highlights the resolved locale without enabling Continue', (
    tester,
  ) async {
    final controller = await _loadedController();
    await tester.pumpWidget(_harness(controller));
    await tester.pumpAndSettle();

    final en = lookupAppLocalizations(const Locale('en'));
    final continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, en.actionContinue),
    );
    expect(continueButton.onPressed, isNull);

    final systemTile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, en.settingsLanguageSystem),
    );
    final icon = systemTile.leading! as Icon;
    expect(icon.icon, Icons.radio_button_checked);
  });

  testWidgets(
    'tapping a row enables Continue, updates the preference, and rebuilds '
    'visible copy in that language',
    (tester) async {
      final controller = await _loadedController();
      var finished = false;
      await tester.pumpWidget(
        _harness(controller, onFinished: () => finished = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('தமிழ்'));
      await tester.pumpAndSettle();

      final ta = lookupAppLocalizations(const Locale('ta'));
      expect(find.text(ta.chooseLanguageTitle), findsOneWidget);

      final continueButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, ta.actionContinue),
      );
      expect(continueButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(ElevatedButton, ta.actionContinue));
      await tester.pump();
      expect(finished, isTrue);

      expect(controller.overrideLocale, equals(const Locale('ta')));
    },
  );

  testWidgets(
    'confirming the already-highlighted device locale is a valid choice',
    (tester) async {
      final controller = await _loadedController();
      var finished = false;
      await tester.pumpWidget(
        _harness(controller, onFinished: () => finished = true),
      );
      await tester.pumpAndSettle();

      final en = lookupAppLocalizations(const Locale('en'));
      await tester.tap(find.text(en.settingsLanguageSystem));
      await tester.pump();

      final continueButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, en.actionContinue),
      );
      expect(continueButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(ElevatedButton, en.actionContinue));
      await tester.pump();
      expect(finished, isTrue);
    },
  );

  testWidgets(
    'shows the BIP39 English-fallback notice for a language without an '
    'official wordlist, but not for one that has one',
    (tester) async {
      final controller = await _loadedController();
      await tester.pumpWidget(_harness(controller));
      await tester.pumpAndSettle();

      final en = lookupAppLocalizations(const Locale('en'));
      expect(find.text(en.chooseLanguageBip39Notice), findsNothing);

      await tester.tap(find.text('हिन्दी'));
      await tester.pumpAndSettle();
      final hi = lookupAppLocalizations(const Locale('hi'));
      expect(find.text(hi.chooseLanguageBip39Notice), findsOneWidget);

      await tester.dragUntilVisible(
        find.text('Français'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle();
      final fr = lookupAppLocalizations(const Locale('fr'));
      expect(find.text(fr.chooseLanguageBip39Notice), findsNothing);
    },
  );
}
