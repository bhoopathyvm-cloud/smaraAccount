import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/ui/features/settings/view_models/settings_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/settings_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockSettingsRepository repository;

  setUp(() {
    repository = MockSettingsRepository();
    when(
      repository.isReferenceRateLookupEnabled(),
    ).thenAnswer((_) async => false);
    when(
      repository.selectedProvider(),
    ).thenAnswer((_) async => ExchangeRateProvider.frankfurter);
    when(
      repository.setReferenceRateLookupEnabled(any),
    ).thenAnswer((_) async {});
    when(repository.setSelectedProvider(any)).thenAnswer((_) async {});
  });

  Future<SettingsViewModel> pumpSettings(WidgetTester tester) async {
    final viewModel = SettingsViewModel(settingsRepository: repository);
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      MaterialApp(home: SettingsView(viewModel: viewModel)),
    );
    await tester.pump();
    return viewModel;
  }

  testWidgets('the provider dropdown lists exactly the predefined enum '
      'values, no custom option', (tester) async {
    when(
      repository.isReferenceRateLookupEnabled(),
    ).thenAnswer((_) async => true);
    await pumpSettings(tester);

    await tester.tap(
      find.byType(DropdownButtonFormField<ExchangeRateProvider>),
    );
    await tester.pumpAndSettle();

    for (final provider in ExchangeRateProvider.values) {
      expect(find.text(provider.displayName), findsWidgets);
    }
    // Every DropdownMenuItem's value is one of the enum's own values -
    // no custom/free-text provider is ever offered.
    final items = tester
        .widgetList<DropdownMenuItem<ExchangeRateProvider>>(
          find.byType(DropdownMenuItem<ExchangeRateProvider>),
        )
        .map((item) => item.value)
        .toSet();
    expect(items, equals(ExchangeRateProvider.values.toSet()));
  });

  testWidgets(
    'the provider dropdown is disabled while the lookup is off, enabled '
    'once turned on',
    (tester) async {
      await pumpSettings(tester);

      final disabledDropdown = tester
          .widget<DropdownButtonFormField<ExchangeRateProvider>>(
            find.byType(DropdownButtonFormField<ExchangeRateProvider>),
          );
      expect(disabledDropdown.onChanged, isNull);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      final enabledDropdown = tester
          .widget<DropdownButtonFormField<ExchangeRateProvider>>(
            find.byType(DropdownButtonFormField<ExchangeRateProvider>),
          );
      expect(enabledDropdown.onChanged, isNotNull);
    },
  );

  testWidgets('toggling the switch calls through to the repository', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    verify(repository.setReferenceRateLookupEnabled(true)).called(1);
  });

  testWidgets('choosing a provider calls through to the repository', (
    tester,
  ) async {
    when(
      repository.isReferenceRateLookupEnabled(),
    ).thenAnswer((_) async => true);
    await pumpSettings(tester);

    await tester.tap(
      find.byType(DropdownButtonFormField<ExchangeRateProvider>),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(ExchangeRateProvider.openErApi.displayName).last,
    );
    await tester.pumpAndSettle();

    verify(
      repository.setSelectedProvider(ExchangeRateProvider.openErApi),
    ).called(1);
  });
}
