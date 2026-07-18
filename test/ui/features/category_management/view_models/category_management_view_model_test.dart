import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/ui/features/category_management/view_models/category_management_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;

  const salary = Account(
    id: 'income-1',
    name: 'Salary',
    type: AccountType.income,
    archived: false,
  );

  setUp(() {
    repository = MockLedgerRepository();
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer((_) => Stream.value([salary]));
  });

  test(
    'exposes categories from watchCategories(includeArchived: true)',
    () async {
      final viewModel = CategoryManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);
      // Stream.value(...) emits asynchronously (via a microtask), not
      // synchronously on listen - let it deliver before asserting.
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.categories, equals([salary]));
      verify(repository.watchCategories(includeArchived: true)).called(1);
    },
  );

  test('addCategory delegates to the Repository', () async {
    when(
      repository.addCategory(name: anyNamed('name'), type: anyNamed('type')),
    ).thenAnswer((_) async {});
    final viewModel = CategoryManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await viewModel.addCategory(name: 'Freelance', type: AccountType.income);

    verify(
      repository.addCategory(name: 'Freelance', type: AccountType.income),
    ).called(1);
    expect(viewModel.errorMessage, isNull);
  });

  test('addCategory surfaces ArgumentError as errorMessage', () async {
    when(
      repository.addCategory(name: anyNamed('name'), type: anyNamed('type')),
    ).thenThrow(ArgumentError('must be income or expense'));
    final viewModel = CategoryManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await viewModel.addCategory(name: 'Nope', type: AccountType.asset);

    expect(viewModel.errorMessage, isNotNull);
  });

  test(
    'renameCategory and archiveCategory delegate to the Repository',
    () async {
      when(
        repository.renameCategory(
          id: anyNamed('id'),
          newName: anyNamed('newName'),
        ),
      ).thenAnswer((_) async {});
      when(repository.archiveCategory(any)).thenAnswer((_) async {});
      final viewModel = CategoryManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await viewModel.renameCategory(id: 'income-1', newName: 'Freelance');
      await viewModel.archiveCategory('income-1');

      verify(
        repository.renameCategory(id: 'income-1', newName: 'Freelance'),
      ).called(1);
      verify(repository.archiveCategory('income-1')).called(1);
    },
  );
}
