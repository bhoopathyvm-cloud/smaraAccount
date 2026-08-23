import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/domain/models/research_tool.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'support/acceptance_harness.dart';

const _brokerage = 'Trading Account';
const _instrument = 'Acme Corp';
const _ticker = 'ACME';

/// Real-build acceptance coverage for investment-research-enablement:
/// Settings' favourite-tool picker and tap-instrument-name research, driven
/// through the real GUI against the real on-disk database.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();

  setUpAll(() async {
    await resetToFreshDevice();
  });

  testWidgets(
    'Settings offers only predefined research tools, no API key or custom URL field',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '25',
        categoryName: 'Salary',
      );

      await tapReliably(
        tester,
        () => shellNavIcon(TablerIcons.home),
        () => find.byTooltip(l10n.settingsTitle).evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.byTooltip(l10n.settingsTitle).hitTestable(),
        () =>
            find.text(l10n.settingsFavouriteResearchTool).evaluate().isNotEmpty,
        innerTries: 150,
      );

      await tapReliably(
        tester,
        () => _researchToolDropdown(l10n).hitTestable(),
        dropdownOverlayOpen,
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.descendant(
          of: dropdownMenu(),
          matching: find.text(l10n.researchChatGpt),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dropdownMenu(),
          matching: find.text(l10n.researchClaude),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dropdownMenu(),
          matching: find.text(l10n.researchGemini),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dropdownMenu(),
          matching: find.text(l10n.researchMetaAi),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('API key'), findsNothing);
      expect(find.textContaining('API Key'), findsNothing);
      expect(find.textContaining('Custom URL'), findsNothing);

      // Select a non-default tool (default is ChatGPT, the first enum value).
      await tapReliably(
        tester,
        () => find.descendant(
          of: dropdownMenu(),
          matching: find.text(l10n.researchClaude),
        ),
        () => !dropdownOverlayOpen(),
        scrollIntoView: false,
      );
      expect(
        find.descendant(
          of: _researchToolDropdown(l10n),
          matching: find.text(l10n.researchClaude),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('API key'), findsNothing);
      expect(find.textContaining('Custom URL'), findsNothing);

      await tapReliably(
        tester,
        () => find.byTooltip('Back'),
        () => find.text(l10n.settingsFavouriteResearchTool).evaluate().isEmpty,
      );
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'tapping an instrument name starts research without sending the ledger',
    (tester) async {
      addTearDown(() {
        UrlLauncherPlatform.instance = _defaultUrlLauncherPlatform;
        return resetToFreshDevice(tester);
      });
      final fakeLauncher = _RecordingUrlLauncherPlatform();
      UrlLauncherPlatform.instance = fakeLauncher;

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '25',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        name: _brokerage,
        openingBalanceText: '2500.00',
      );
      await openHoldingsFor(tester, _brokerage);
      await recordCashFundedBuyThroughGui(
        tester,
        instrumentName: _instrument,
        tickerText: _ticker,
        quantityText: '7',
        unitPriceText: '250.00',
      );

      await tapReliably(
        tester,
        () => find.text(_instrument).hitTestable(),
        () =>
            find.text(l10n.openedFavouriteResearchTool).evaluate().isNotEmpty ||
            find.text(l10n.copiedResearchPrompt).evaluate().isNotEmpty,
      );
      expect(find.text(l10n.openedFavouriteResearchTool), findsOneWidget);

      final launchedUri = fakeLauncher.lastLaunchedUri;
      expect(
        launchedUri,
        isNotNull,
        reason:
            'tapping the instrument name should launch the favourite '
            'research tool with a packed query',
      );
      final prompt = launchedUri!.queryParameters['q'] ?? '';

      expect(prompt, contains(_instrument));
      expect(prompt, contains(_ticker));
      expect(prompt, contains('news'));
      expect(prompt, contains('downside'));
      expect(prompt, contains('upside'));
      expect(prompt, contains('Do not give buy, sell, or hold advice'));

      // Must not leak the ledger: no quantity, no cost, no account name.
      expect(prompt, isNot(contains('7')));
      expect(prompt, isNot(contains('250.00')));
      expect(prompt, isNot(contains(_brokerage)));

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

final _defaultUrlLauncherPlatform = UrlLauncherPlatform.instance;

Finder _researchToolDropdown(AppLocalizationsEn l10n) =>
    find.byWidgetPredicate((widget) {
      if (widget is! DropdownButtonFormField<ResearchTool>) return false;
      return widget.decoration.labelText == l10n.settingsFavouriteResearchTool;
    });

/// Substitutes the platform-interface singleton `HoldingsViewModel`'s
/// default `launchUrlFn` calls into (`launchUrl` from `package:url_launcher`
/// -> `UrlLauncherPlatform.instance.launchUrl`), so the acceptance test can
/// assert the packed research query in-process rather than depending on a
/// real browser actually opening (design.md Decision 2, option 1) - no
/// `lib/` production code changes required.
class _RecordingUrlLauncherPlatform extends UrlLauncherPlatform {
  Uri? lastLaunchedUri;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunchedUri = Uri.parse(url);
    return true;
  }
}
