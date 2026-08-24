import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/ui/features/first_week_setup/view_models/first_week_setup_view_model.dart';
import 'package:smara_accounting/ui/features/first_week_setup/views/first_week_setup_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockAccountRepository accountRepository;
  late MockSettingsRepository settingsRepository;

  setUp(() {
    accountRepository = MockAccountRepository();
    settingsRepository = MockSettingsRepository();
  });

  testWidgets('Finish with both optional steps skipped calls onFinished', (
    tester,
  ) async {
    when(
      settingsRepository.setFirstWeekSetupCompleted(true),
    ).thenAnswer((_) async {});

    final viewModel = FirstWeekSetupViewModel(
      accountRepository: accountRepository,
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

    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Finish'));
    await tester.pump();

    verifyNever(
      accountRepository.createFinancialAccount(
        name: anyNamed('name'),
        type: anyNamed('type'),
        groupId: anyNamed('groupId'),
      ),
    );
    expect(finished, isTrue);
  });

  testWidgets('toggling "Add a credit card" reveals its name field', (
    tester,
  ) async {
    final viewModel = FirstWeekSetupViewModel(
      accountRepository: accountRepository,
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
