import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/ui/features/first_week_setup/view_models/first_week_setup_view_model.dart';

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

  Future<FirstWeekSetupViewModel> viewModelAfterLoad() async {
    final viewModel = FirstWeekSetupViewModel(
      ledgerRepository: ledgerRepository,
      settingsRepository: settingsRepository,
    );
    await Future<void>.delayed(Duration.zero);
    return viewModel;
  }

  test(
    'loads with the seeded account\'s current name prefilled, not loading',
    () async {
      final viewModel = await viewModelAfterLoad();
      addTearDown(viewModel.dispose);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.mainAccountName, equals('Cash & Bank'));
    },
  );

  test(
    'finish fails with an errorMessage when the main account name is blank',
    () async {
      final viewModel = await viewModelAfterLoad();
      addTearDown(viewModel.dispose);
      viewModel.setMainAccountName('   ');

      final result = await viewModel.finish();

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotEmpty);
      verifyNever(
        ledgerRepository.renameFinancialAccount(
          id: anyNamed('id'),
          newName: anyNamed('newName'),
        ),
      );
    },
  );

  test('finish renames the seeded account and marks setup complete when both '
      'optional steps are skipped', () async {
    final viewModel = await viewModelAfterLoad();
    addTearDown(viewModel.dispose);
    viewModel.setMainAccountName('Chase Checking');
    when(
      ledgerRepository.renameFinancialAccount(
        id: anyNamed('id'),
        newName: anyNamed('newName'),
      ),
    ).thenAnswer((_) async {});
    when(
      settingsRepository.setFirstWeekSetupCompleted(true),
    ).thenAnswer((_) async {});

    final result = await viewModel.finish();

    expect(result, isTrue);
    verify(
      ledgerRepository.renameFinancialAccount(
        id: 'asset-seed',
        newName: 'Chase Checking',
      ),
    ).called(1);
    verifyNever(
      ledgerRepository.createFinancialAccount(
        name: anyNamed('name'),
        type: anyNamed('type'),
        groupId: anyNamed('groupId'),
      ),
    );
    verify(settingsRepository.setFirstWeekSetupCompleted(true)).called(1);
  });

  test('finish creates a credit card and a cash account when both optional '
      'steps are filled in', () async {
    final viewModel = await viewModelAfterLoad();
    addTearDown(viewModel.dispose);
    viewModel.setMainAccountName('Chase Checking');
    viewModel.setHasCreditCard(true);
    viewModel.setCreditCardName('Chase Sapphire');
    viewModel.setHasCashAccount(true);
    viewModel.setCashAccountName('Wallet cash');
    when(
      ledgerRepository.renameFinancialAccount(
        id: anyNamed('id'),
        newName: anyNamed('newName'),
      ),
    ).thenAnswer((_) async {});
    when(
      ledgerRepository.createFinancialAccount(
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

    final result = await viewModel.finish();

    expect(result, isTrue);
    verify(
      ledgerRepository.createFinancialAccount(
        name: 'Chase Sapphire',
        type: AccountType.liability,
        groupId: groupCreditShortTermId,
      ),
    ).called(1);
    verify(
      ledgerRepository.createFinancialAccount(
        name: 'Wallet cash',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
      ),
    ).called(1);
  });

  test('toggling an optional step on without naming it creates no account for '
      'that step', () async {
    final viewModel = await viewModelAfterLoad();
    addTearDown(viewModel.dispose);
    viewModel.setMainAccountName('Chase Checking');
    viewModel.setHasCreditCard(true);
    // No card name entered - the toggle alone doesn't create anything.
    when(
      ledgerRepository.renameFinancialAccount(
        id: anyNamed('id'),
        newName: anyNamed('newName'),
      ),
    ).thenAnswer((_) async {});
    when(
      settingsRepository.setFirstWeekSetupCompleted(true),
    ).thenAnswer((_) async {});

    final result = await viewModel.finish();

    expect(result, isTrue);
    verifyNever(
      ledgerRepository.createFinancialAccount(
        name: anyNamed('name'),
        type: anyNamed('type'),
        groupId: anyNamed('groupId'),
      ),
    );
  });
}
