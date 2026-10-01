import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/first_account_name_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/first_identity_setup_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/views/currency_selection_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/first_account_name_view.dart';
import 'package:smara_accounting/ui/features/setup_choice/views/setup_choice_view.dart';

import '../../../../mocks.mocks.dart';

/// Onboarding no longer includes a recovery-phrase step. These widget tests
/// confirm the remaining screens still chain toward Home without one.
void main() {
  testWidgets(
    'setup choice, currency, and first-account screens omit recovery-phrase UI',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SetupChoiceView(onNewSetup: () {}, onRestoreFromCopy: () {}),
        ),
      );
      expect(find.text('New setup'), findsOneWidget);
      expect(find.text('Restore from a copy'), findsOneWidget);
      expect(find.textContaining('recovery phrase'), findsNothing);
      expect(find.textContaining('keystore'), findsNothing);

      final currencyVm = FirstIdentitySetupViewModel(
        identityRepository: MockIdentityRepository(),
        chainVerifier: MockLedgerChainVerifier(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: CurrencySelectionView(viewModel: currencyVm, onFinished: () {}),
        ),
      );
      expect(find.text('Choose your currency'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.textContaining('recovery phrase'), findsNothing);

      final accountRepository = MockAccountRepository();
      when(accountRepository.watchFinancialAccounts()).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'asset-seed',
            name: 'Cash & Bank',
            type: AccountType.asset,
            archived: false,
          ),
        ]),
      );
      var finishedTowardHome = false;
      final accountVm = FirstAccountNameViewModel(
        accountRepository: accountRepository,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: FirstAccountNameView(
            viewModel: accountVm,
            onFinished: () => finishedTowardHome = true,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Name your account'), findsOneWidget);
      expect(find.textContaining('recovery phrase'), findsNothing);
      expect(find.textContaining('keystore'), findsNothing);

      when(
        accountRepository.renameFinancialAccount(
          id: anyNamed('id'),
          newName: anyNamed('newName'),
        ),
      ).thenAnswer((_) async {});
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(finishedTowardHome, isTrue);
    },
  );
}
