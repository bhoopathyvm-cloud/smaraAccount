import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/first_account_name_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/views/first_account_name_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockAccountRepository repository;

  const seededAccount = Account(
    id: 'asset-seed',
    name: 'Cash & Bank',
    type: AccountType.asset,
    archived: false,
  );

  setUp(() {
    repository = MockAccountRepository();
    when(
      repository.watchFinancialAccounts(),
    ).thenAnswer((_) => Stream.value(const [seededAccount]));
  });

  testWidgets(
    'prefills the seeded name; Continue renames and calls onFinished',
    (tester) async {
      when(
        repository.renameFinancialAccount(
          id: anyNamed('id'),
          newName: anyNamed('newName'),
        ),
      ).thenAnswer((_) async {});

      final viewModel = FirstAccountNameViewModel(
        accountRepository: repository,
      );
      addTearDown(viewModel.dispose);
      var finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FirstAccountNameView(
            viewModel: viewModel,
            onFinished: () => finished = true,
          ),
        ),
      );
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, equals('Cash & Bank'));

      await tester.enterText(find.byType(TextField), 'Chase Checking');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pump();

      verify(
        repository.renameFinancialAccount(
          id: 'asset-seed',
          newName: 'Chase Checking',
        ),
      ).called(1);
      expect(finished, isTrue);
    },
  );

  testWidgets(
    'in Tamil, prefills the localized seed; saving without an edit persists '
    'the English seed, not the Tamil display text',
    (tester) async {
      when(
        repository.renameFinancialAccount(
          id: anyNamed('id'),
          newName: anyNamed('newName'),
        ),
      ).thenAnswer((_) async {});

      final viewModel = FirstAccountNameViewModel(
        accountRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ta'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedAppLocales,
          home: FirstAccountNameView(viewModel: viewModel, onFinished: () {}),
        ),
      );
      await tester.pump();

      final ta = lookupAppLocalizations(const Locale('ta'));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, equals(ta.systemAccountCashBank));
      expect(field.controller?.text, isNot(equals('Cash & Bank')));

      await tester.tap(find.widgetWithText(ElevatedButton, ta.actionContinue));
      await tester.pump();

      verify(
        repository.renameFinancialAccount(
          id: 'asset-seed',
          newName: 'Cash & Bank',
        ),
      ).called(1);
    },
  );
}
