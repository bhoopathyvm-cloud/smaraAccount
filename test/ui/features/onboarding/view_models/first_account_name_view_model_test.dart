import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/first_account_name_view_model.dart';

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

  Future<FirstAccountNameViewModel> viewModelAfterLoad() async {
    final viewModel = FirstAccountNameViewModel(accountRepository: repository);
    await Future<void>.delayed(Duration.zero);
    return viewModel;
  }

  test('prefills the seeded account name', () async {
    final viewModel = await viewModelAfterLoad();
    addTearDown(viewModel.dispose);

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.name, equals('Cash & Bank'));
  });

  test('submit refuses a blank name', () async {
    final viewModel = await viewModelAfterLoad();
    addTearDown(viewModel.dispose);
    viewModel.setName('   ');

    final ok = await viewModel.submit();

    expect(ok, isFalse);
    expect(viewModel.errorMessage, isNotEmpty);
    verifyNever(
      repository.renameFinancialAccount(
        id: anyNamed('id'),
        newName: anyNamed('newName'),
      ),
    );
  });

  test('submit renames the seeded account', () async {
    final viewModel = await viewModelAfterLoad();
    addTearDown(viewModel.dispose);
    viewModel.setName('Chase Checking');
    when(
      repository.renameFinancialAccount(
        id: anyNamed('id'),
        newName: anyNamed('newName'),
      ),
    ).thenAnswer((_) async {});

    final ok = await viewModel.submit();

    expect(ok, isTrue);
    verify(
      repository.renameFinancialAccount(
        id: 'asset-seed',
        newName: 'Chase Checking',
      ),
    ).called(1);
  });
}
