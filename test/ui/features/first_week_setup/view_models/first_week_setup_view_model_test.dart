import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/ui/features/first_week_setup/view_models/first_week_setup_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockAccountRepository accountRepository;
  late MockSettingsRepository settingsRepository;

  setUp(() {
    accountRepository = MockAccountRepository();
    settingsRepository = MockSettingsRepository();
  });

  FirstWeekSetupViewModel viewModel() => FirstWeekSetupViewModel(
    accountRepository: accountRepository,
    settingsRepository: settingsRepository,
  );

  test('finish marks setup complete and creates nothing when both optional '
      'steps are skipped', () async {
    final vm = viewModel();
    addTearDown(vm.dispose);
    when(
      settingsRepository.setFirstWeekSetupCompleted(true),
    ).thenAnswer((_) async {});

    final result = await vm.finish();

    expect(result, isTrue);
    verifyNever(
      accountRepository.createFinancialAccount(
        name: anyNamed('name'),
        type: anyNamed('type'),
        groupId: anyNamed('groupId'),
      ),
    );
    verify(settingsRepository.setFirstWeekSetupCompleted(true)).called(1);
  });

  test('finish creates a credit card and a cash account when both optional '
      'steps are filled in', () async {
    final vm = viewModel();
    addTearDown(vm.dispose);
    vm.setHasCreditCard(true);
    vm.setCreditCardName('Chase Sapphire');
    vm.setHasCashAccount(true);
    vm.setCashAccountName('Wallet cash');
    when(
      accountRepository.createFinancialAccount(
        name: anyNamed('name'),
        type: anyNamed('type'),
        groupId: anyNamed('groupId'),
      ),
    ).thenAnswer(
      (_) async => const Account(
        id: 'new',
        name: 'x',
        type: AccountType.asset,
        archived: false,
      ),
    );
    when(
      settingsRepository.setFirstWeekSetupCompleted(true),
    ).thenAnswer((_) async {});

    final result = await vm.finish();

    expect(result, isTrue);
    verify(
      accountRepository.createFinancialAccount(
        name: 'Chase Sapphire',
        type: AccountType.liability,
        groupId: groupCreditShortTermId,
      ),
    ).called(1);
    verify(
      accountRepository.createFinancialAccount(
        name: 'Wallet cash',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
      ),
    ).called(1);
  });

  test('toggling an optional step on without naming it creates no account for '
      'that step', () async {
    final vm = viewModel();
    addTearDown(vm.dispose);
    vm.setHasCreditCard(true);
    // No card name entered - the toggle alone doesn't create anything.
    when(
      settingsRepository.setFirstWeekSetupCompleted(true),
    ).thenAnswer((_) async {});

    final result = await vm.finish();

    expect(result, isTrue);
    verifyNever(
      accountRepository.createFinancialAccount(
        name: anyNamed('name'),
        type: anyNamed('type'),
        groupId: anyNamed('groupId'),
      ),
    );
  });
}
