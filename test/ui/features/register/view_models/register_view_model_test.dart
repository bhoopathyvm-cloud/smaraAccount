import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/journal_entry.dart';
import 'package:smara_accounting/domain/models/posting.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/register/view_models/register_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;

  const income = Account(
    id: 'income-1',
    name: 'Salary',
    type: AccountType.income,
    archived: false,
  );

  setUp(() {
    repository = MockLedgerRepository();
  });

  test('computes rows with running balance in emitted order', () async {
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer((_) => Stream.value([income]));
    when(repository.watchEntries()).thenAnswer(
      (_) => Stream.value([
        JournalEntry(
          id: 'e1',
          transactionDate: DateTime(2026, 1, 1),
          recordedAt: DateTime(2026, 1, 1),
          description: null,
          reversesEntryId: null,
          postings: const [
            Posting(
              id: 'p1',
              entryId: 'e1',
              accountId: 'asset-1',
              amountMinor: 1000,
              lineNumber: 1,
            ),
            Posting(
              id: 'p2',
              entryId: 'e1',
              accountId: 'income-1',
              amountMinor: -1000,
              lineNumber: 2,
            ),
          ],
        ),
        JournalEntry(
          id: 'e2',
          transactionDate: DateTime(2026, 1, 2),
          recordedAt: DateTime(2026, 1, 2),
          description: null,
          reversesEntryId: null,
          postings: const [
            Posting(
              id: 'p3',
              entryId: 'e2',
              accountId: 'asset-1',
              amountMinor: -300,
              lineNumber: 1,
            ),
            Posting(
              id: 'p4',
              entryId: 'e2',
              accountId: 'income-1',
              amountMinor: 300,
              lineNumber: 2,
            ),
          ],
        ),
      ]),
    );

    final viewModel = RegisterViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);
    // Stream.value(...) emits asynchronously (via a microtask), not
    // synchronously on listen - let it deliver before asserting.
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.rows, hasLength(2));
    expect(viewModel.rows[0].runningBalanceMinor, equals(1000));
    expect(viewModel.rows[0].direction, equals(TransactionDirection.moneyIn));
    expect(viewModel.rows[1].runningBalanceMinor, equals(700));
    expect(viewModel.rows[1].direction, equals(TransactionDirection.moneyOut));
  });

  test('reverseEntry delegates to the Repository', () async {
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer((_) => Stream.value([income]));
    when(repository.watchEntries()).thenAnswer((_) => Stream.value(const []));
    when(repository.reverseEntry(any)).thenAnswer((_) async {});

    final viewModel = RegisterViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await viewModel.reverseEntry('e1');

    verify(repository.reverseEntry('e1')).called(1);
  });
}
