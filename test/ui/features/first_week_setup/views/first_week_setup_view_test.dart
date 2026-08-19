import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/ui/features/first_week_setup/view_models/first_week_setup_view_model.dart';
import 'package:smara_accounting/ui/features/first_week_setup/views/first_week_setup_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository ledgerRepository;
  late MockSettingsRepository settingsRepository;

  const seededAccount = Account(
    id: 'asset-seed',
    name: 'Cash & Bank',
    type: AccountType.asset,
    archived: false,
    groupId: 'group_cash_equivalents',
  );

  setUp(() {
    ledgerRepository = MockLedgerRepository();
    settingsRepository = MockSettingsRepository();
    when(
      ledgerRepository.watchFinancialAccounts(),
    ).thenAnswer((_) => Stream.value(const [seededAccount]));
  });

  testWidgets(
    'prefills the seeded account name; Finish renames it and calls onFinished',
    (tester) async {
      when(
        ledgerRepository.renameFinancialAccount(
          id: anyNamed('id'),
          newName: anyNamed('newName'),
        ),
      ).thenAnswer((_) async {});
      when(
        settingsRepository.setFirstWeekSetupCompleted(true),
      ).thenAnswer((_) async {});

      final viewModel = FirstWeekSetupViewModel(
        ledgerRepository: ledgerRepository,
        settingsRepository: settingsRepository,
      );
      addTearDown(viewModel.dispose);
      var finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FirstWeekSetupView(
            viewModel: viewModel,
            onFinished: () => finished = true,
          ),
        ),
      );
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.controller?.text, equals('Cash & Bank'));

      await tester.enterText(find.byType(TextField).first, 'Chase Checking');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Finish'));
      await tester.pump();

      verify(
        ledgerRepository.renameFinancialAccount(
          id: 'asset-seed',
          newName: 'Chase Checking',
        ),
      ).called(1);
      expect(finished, isTrue);
    },
  );

  testWidgets('toggling "Add a credit card" reveals its name field', (
    tester,
  ) async {
    final viewModel = FirstWeekSetupViewModel(
      ledgerRepository: ledgerRepository,
      settingsRepository: settingsRepository,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: FirstWeekSetupView(viewModel: viewModel, onFinished: () {}),
      ),
    );
    await tester.pump();

    expect(find.text('Card name'), findsNothing);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Add a credit card'));
    await tester.pump();

    expect(find.text('Card name'), findsOneWidget);
  });
}
