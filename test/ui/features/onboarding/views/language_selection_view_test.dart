import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/onboarding/views/language_selection_view.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  // The MaterialApp's locale follows the controller (as main.dart wires it),
  // so selecting a language rebuilds the visible copy immediately.
  Widget harness(LocaleController controller, {VoidCallback? onFinished}) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => MaterialApp(
        locale: controller.resolve(const Locale('en')),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedAppLocales,
        home: LanguageSelectionView(
          localeController: controller,
          onFinished: onFinished ?? () {},
        ),
      ),
    );
  }

  Future<LocaleController> loadedController() async {
    final controller = LocaleController(settingsRepository: SettingsRepository());
    await controller.load();
    return controller;
  }

  ElevatedButton continueButton(WidgetTester tester) {
    final en = lookupAppLocalizations(const Locale('en'));
    return tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, en.actionContinue),
    );
  }

  testWidgets('lists supported locales by their native names', (tester) async {
    final controller = await loadedController();
    await tester.pumpWidget(harness(controller));
    await tester.pump();

    expect(find.text('English'), findsOneWidget);
    expect(find.text('தமிழ்'), findsOneWidget);
    expect(find.text('हिन्दी'), findsOneWidget);
    // Arabic sits far down the lazily-built list; scroll it into view to
    // prove its own RTL native-script name is used too.
    await tester.scrollUntilVisible(find.text('العربية'), 300);
    expect(find.text('العربية'), findsOneWidget);
  });

  testWidgets('pre-highlights "device language" when no override is set', (
    tester,
  ) async {
    final controller = await loadedController();
    await tester.pumpWidget(harness(controller));
    await tester.pump();

    final en = lookupAppLocalizations(const Locale('en'));
    final systemTile = find.ancestor(
      of: find.text(en.settingsLanguageSystem),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: systemTile, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });

  testWidgets('Continue is disabled until a row is tapped', (tester) async {
    final controller = await loadedController();
    await tester.pumpWidget(harness(controller));
    await tester.pump();

    expect(continueButton(tester).onPressed, isNull);
  });

  testWidgets(
    'tapping the pre-highlighted device row enables Continue without changing '
    'the locale',
    (tester) async {
      final controller = await loadedController();
      await tester.pumpWidget(harness(controller));
      await tester.pump();

      final en = lookupAppLocalizations(const Locale('en'));
      await tester.tap(find.text(en.settingsLanguageSystem));
      await tester.pump();

      expect(continueButton(tester).onPressed, isNotNull);
      // "Device language" writes the system sentinel, so no concrete override.
      expect(controller.overrideLocale, isNull);
    },
  );

  testWidgets(
    'tapping a language applies it to the visible copy immediately and enables '
    'Continue',
    (tester) async {
      final controller = await loadedController();
      await tester.pumpWidget(harness(controller));
      await tester.pump();

      await tester.tap(find.text('தமிழ்'));
      await tester.pump();

      final tamil = lookupAppLocalizations(const Locale('ta'));
      // The Continue button re-renders in Tamil, proving the locale switched.
      expect(find.text(tamil.actionContinue), findsOneWidget);
      expect(controller.overrideLocale, const Locale('ta'));
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, tamil.actionContinue),
            )
            .onPressed,
        isNotNull,
      );

      // The selected row now carries the check mark.
      final tamilTile = find.ancestor(
        of: find.text('தமிழ்'),
        matching: find.byType(ListTile),
      );
      expect(
        find.descendant(of: tamilTile, matching: find.byIcon(Icons.check)),
        findsOneWidget,
      );
    },
  );

  testWidgets('Continue invokes onFinished once a selection has been made', (
    tester,
  ) async {
    var finished = false;
    final controller = await loadedController();
    await tester.pumpWidget(
      harness(controller, onFinished: () => finished = true),
    );
    await tester.pump();

    final en = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.text(en.settingsLanguageSystem));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, en.actionContinue));
    await tester.pump();

    expect(finished, isTrue);
  });
}
