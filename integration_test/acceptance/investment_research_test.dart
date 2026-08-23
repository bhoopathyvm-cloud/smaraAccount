import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/domain/models/research_tool.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/ui/features/holdings/view_models/holdings_view_model.dart';

import 'support/acceptance_harness.dart';

/// Real-build acceptance coverage for investment research enablement
/// (design.md, group tracked by `acceptance-investment-research`), walked
/// entirely through the real GUI against the real on-disk database - no
/// ViewModel/Repository backdoors. Independently runnable: does not
/// require any other acceptance file to run first (each test completes
/// its own onboarding from a fresh device).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();

  setUpAll(() async {
    await resetToFreshDevice();
  });

  testWidgets(
    'Settings favourite research tool is a fixed list with no API key or custom URL field',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );

      await tapReliably(
        tester,
        () => find.byTooltip(l10n.settingsTitle),
        () =>
            find.text(l10n.settingsFavouriteResearchTool).evaluate().isNotEmpty,
      );

      // No API-key or custom-URL field exists anywhere on Settings - the
      // product forbids both for research (design.md Non-Goals).
      expect(
        find.textContaining(RegExp('api.?key', caseSensitive: false)),
        findsNothing,
      );
      expect(
        find.textContaining(RegExp('custom.*url', caseSensitive: false)),
        findsNothing,
      );

      Finder researchDropdown() => find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<ResearchTool> &&
            widget.decoration.labelText == l10n.settingsFavouriteResearchTool,
      );
      bool isClaudeSelected() => find
          .descendant(
            of: researchDropdown(),
            matching: find.text(l10n.researchClaude),
          )
          .evaluate()
          .isNotEmpty;

      await tester.ensureVisible(researchDropdown());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(researchDropdown());
      await tester.pumpAndSettle();

      // The fixed predefined list - ChatGPT, Claude, Gemini, Meta AI.
      expect(find.text(l10n.researchChatGpt), findsWidgets);
      expect(find.text(l10n.researchClaude), findsWidgets);
      expect(find.text(l10n.researchGemini), findsWidgets);
      expect(find.text(l10n.researchMetaAi), findsWidgets);

      // Select a non-default tool (ChatGPT is default - ResearchTool.values.first).
      await tester.tap(find.text(l10n.researchClaude).last);
      await tester.pumpAndSettle();

      expect(isClaudeSelected(), isTrue);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets('tapping an instrument name launches a scoped research prompt', (
    tester,
  ) async {
    addTearDown(() => debugResearchLaunchInterceptor = null);
    addTearDown(() => resetToFreshDevice(tester));

    // The real url_launcher genuinely opens a system browser on a live
    // macOS run, which steals window focus and hangs the test
    // indefinitely (confirmed empirically) - app_router.dart builds
    // HoldingsViewModel without a launchUrlFn override, so this
    // debug-only interceptor is the only way to observe the launched
    // URI without opening a real browser (design.md Decision 2).
    Uri? capturedUri;
    debugResearchLaunchInterceptor = (uri) async {
      capturedUri = uri;
      return true;
    };

    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '1000',
      categoryName: 'Salary',
    );
    await createInvestmentAccountThroughGui(
      tester,
      accountName: 'Brokerage',
      openingCashText: '500',
    );
    await openHoldingsFor(tester, 'Brokerage');

    await recordCashFundedBuyThroughGui(
      tester,
      instrumentName: 'Acme Corp',
      quantityText: '5',
      unitPriceText: '20',
      ticker: 'ACME',
    );

    await tapReliably(
      tester,
      () => find.text('Acme Corp'),
      () => find.text(l10n.openedFavouriteResearchTool).evaluate().isNotEmpty,
    );

    expect(capturedUri, isNotNull);
    final prompt = capturedUri!.queryParameters['q'];
    expect(prompt, isNotNull);
    expect(prompt, contains('Acme Corp'));
    expect(prompt, contains('ACME'));
    expect(prompt, contains('news'));
    expect(prompt, contains('downside'));
    expect(prompt, contains('upside'));
    expect(prompt, contains('Do not give buy, sell, or hold advice'));
    // Identifiers only - never quantity, cost, or the account name.
    expect(prompt, isNot(contains('20.00')));
    expect(prompt, isNot(contains('Brokerage')));
  }, timeout: const Timeout(Duration(minutes: 5)));
}
