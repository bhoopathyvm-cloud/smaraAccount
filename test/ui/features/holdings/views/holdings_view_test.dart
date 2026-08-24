import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
import 'package:smara_accounting/domain/models/instrument.dart';
import 'package:smara_accounting/domain/models/instrument_holding.dart';
import 'package:smara_accounting/domain/models/research_tool.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/holdings/view_models/holdings_view_model.dart';
import 'package:smara_accounting/ui/features/holdings/views/holdings_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository ledger;
  late MockSettingsRepository settings;

  const apple = Instrument(
    id: 'inst-1',
    name: 'Apple Inc',
    kind: InstrumentKind.stock,
    ticker: 'AAPL',
    archived: false,
  );

  const holding = InstrumentHolding(
    instrument: apple,
    quantityScaled: 10000,
    averageCostMinor: 10000,
    totalCostMinor: 10000,
    sellableQuantityScaled: 10000,
    marketValueMinor: 12000,
    unrealizedGainLossMinor: 2000,
  );

  const account = Account(
    id: 'inv-1',
    name: 'Brokerage',
    type: AccountType.asset,
    archived: false,
    groupId: 'group_investments',
    holdsInvestments: true,
  );

  const group = AccountGroup(
    id: 'group_investments',
    name: 'Investments',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 4,
    isSystem: true,
    currency: 'USD',
    archived: false,
  );

  setUp(() {
    ledger = MockLedgerRepository();
    settings = MockSettingsRepository();
    when(
      ledger.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([account]));
    when(
      ledger.watchHoldingsForAccount(any),
    ).thenAnswer((_) => Stream.value([holding]));
    when(ledger.watchInstruments()).thenAnswer((_) => Stream.value([apple]));
    when(
      ledger.watchInstrumentsHeldInAccount(any),
    ).thenAnswer((_) => Stream.value([apple]));
    when(ledger.watchCategories()).thenAnswer((_) => Stream.value(const []));
    when(ledger.watchAccountGroups()).thenAnswer((_) => Stream.value([group]));
    when(ledger.displayBalanceMinor(any)).thenAnswer((_) async => 40000);
    when(settings.isMarketPriceFetchEnabled()).thenAnswer((_) async => false);
    when(
      settings.selectedResearchTool(),
    ).thenAnswer((_) async => ResearchTool.chatGpt);
  });

  testWidgets('tapping the instrument name launches research', (tester) async {
    Uri? launched;
    final viewModel = HoldingsViewModel(
      ledgerRepository: ledger,
      settingsRepository: settings,
      accountId: 'inv-1',
      launchUrlFn: (uri) async {
        launched = uri;
        return true;
      },
    );

    await tester.pumpWidget(
      MaterialApp(home: HoldingsView(viewModel: viewModel)),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Apple Inc'));
    await tester.pump();
    await tester.pump();

    expect(launched, isNotNull);
    expect(launched!.queryParameters['q'], contains('Apple Inc'));
    expect(
      launched!.queryParameters['q']!.toLowerCase(),
      isNot(contains('40000')),
    );
    viewModel.dispose();
  });

  testWidgets(
    'in Tamil, the tap-to-research hint and the research prompt itself '
    'follow the active locale',
    (tester) async {
      Uri? launched;
      final viewModel = HoldingsViewModel(
        ledgerRepository: ledger,
        settingsRepository: settings,
        accountId: 'inv-1',
        launchUrlFn: (uri) async {
          launched = uri;
          return true;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ta'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedAppLocales,
          home: HoldingsView(viewModel: viewModel),
        ),
      );
      await tester.pump();
      await tester.pump();

      final ta = lookupAppLocalizations(const Locale('ta'));
      expect(find.text(ta.holdingsTapNameToResearch), findsOneWidget);

      await tester.tap(find.text('Apple Inc'));
      await tester.pump();
      await tester.pump();

      expect(launched, isNotNull);
      final prompt = launched!.queryParameters['q']!;
      expect(prompt, contains('Apple Inc'));
      expect(prompt, contains(ta.researchPromptIntro));
      viewModel.dispose();
    },
  );

  testWidgets(
    'dividend dialog only offers instruments this account has held, not every global instrument',
    (tester) async {
      const microsoft = Instrument(
        id: 'inst-2',
        name: 'Microsoft Corp',
        kind: InstrumentKind.stock,
        ticker: 'MSFT',
        archived: false,
      );
      // Globally known (e.g. bought in a different investment account) but
      // never held in THIS account - watchInstrumentsHeldInAccount excludes
      // it from setUp()'s stubbed [apple] stream.
      when(
        ledger.watchInstruments(),
      ).thenAnswer((_) => Stream.value([apple, microsoft]));

      final viewModel = HoldingsViewModel(
        ledgerRepository: ledger,
        settingsRepository: settings,
        accountId: 'inv-1',
      );

      await tester.pumpWidget(
        MaterialApp(home: HoldingsView(viewModel: viewModel)),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Dividend'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is DropdownButtonFormField<String> &&
              widget.decoration.labelText == 'Instrument',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Apple Inc'), findsWidgets);
      expect(find.text('Microsoft Corp'), findsNothing);

      viewModel.dispose();
    },
  );
}
