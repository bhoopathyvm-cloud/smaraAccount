import 'dart:async';

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

  const asset = Account(
    id: 'asset-1',
    name: 'Cash & Bank',
    type: AccountType.asset,
    archived: false,
  );

  setUp(() {
    repository = MockLedgerRepository();
    when(
      repository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([asset]));
  });

  JournalEntry testEntry({
    required String id,
    required DateTime transactionDate,
    required List<Posting> postings,
    bool isVerified = true,
  }) {
    return JournalEntry(
      id: id,
      transactionDate: transactionDate,
      recordedAt: transactionDate,
      description: null,
      reversesEntryId: null,
      postings: postings,
      deviceChainSequence: 0,
      entryHash: const [],
      signedByIdentityId: 'identity-1',
      signature: const [],
      migratedFromEntryId: null,
      isVerified: isVerified,
      breakReason: isVerified ? null : VerificationBreakReason.hashMismatch,
      isSupersededByMigration: false,
    );
  }

  test('computes rows with running balance, newest entry first', () async {
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer((_) => Stream.value([income]));
    when(repository.watchEntriesForAccount(any)).thenAnswer(
      (_) => Stream.value([
        testEntry(
          id: 'e1',
          transactionDate: DateTime(2026, 1, 1),
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
        testEntry(
          id: 'e2',
          transactionDate: DateTime(2026, 1, 2),
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
    // e2 (Jan 2) is the most recent entry, so it's first - its running
    // balance is the account's current balance.
    expect(viewModel.rows[0].runningBalanceMinor, equals(700));
    expect(viewModel.rows[0].direction, equals(TransactionDirection.moneyOut));
    expect(viewModel.rows[1].runningBalanceMinor, equals(1000));
    expect(viewModel.rows[1].direction, equals(TransactionDirection.moneyIn));
  });

  test(
    'a quarantined entry is shown but excluded from the running balance',
    () async {
      when(
        repository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([income]));
      when(repository.watchEntriesForAccount(any)).thenAnswer(
        (_) => Stream.value([
          testEntry(
            id: 'e1',
            transactionDate: DateTime(2026, 1, 1),
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
          testEntry(
            id: 'e2',
            transactionDate: DateTime(2026, 1, 2),
            isVerified: false,
            postings: const [
              Posting(
                id: 'p3',
                entryId: 'e2',
                accountId: 'asset-1',
                amountMinor: 5000,
                lineNumber: 1,
              ),
              Posting(
                id: 'p4',
                entryId: 'e2',
                accountId: 'income-1',
                amountMinor: -5000,
                lineNumber: 2,
              ),
            ],
          ),
        ]),
      );

      final viewModel = RegisterViewModel(ledgerRepository: repository);
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.rows, hasLength(2));
      // e2 (Jan 2, quarantined) is the most recent entry, so it's first -
      // still shown, but excluded from the running balance.
      expect(viewModel.rows[0].isVerified, isFalse);
      expect(viewModel.rows[0].runningBalanceMinor, equals(1000));
      // The quarantined entry's 5000 never lands in the running balance.
      expect(viewModel.rows[1].runningBalanceMinor, equals(1000));
    },
  );

  test(
    'a newly recorded entry appears first, with the account\'s current balance',
    () async {
      when(
        repository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([income]));
      final entriesController = StreamController<List<JournalEntry>>();
      addTearDown(entriesController.close);
      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => entriesController.stream);

      final viewModel = RegisterViewModel(ledgerRepository: repository);
      addTearDown(viewModel.dispose);

      final existing = testEntry(
        id: 'e1',
        transactionDate: DateTime(2026, 1, 1),
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
      );
      entriesController.add([existing]);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.rows, hasLength(1));
      expect(viewModel.rows.first.entryId, equals('e1'));
      expect(viewModel.rows.first.runningBalanceMinor, equals(1000));

      final justRecorded = testEntry(
        id: 'e2',
        transactionDate: DateTime(2026, 1, 15),
        postings: const [
          Posting(
            id: 'p3',
            entryId: 'e2',
            accountId: 'asset-1',
            amountMinor: 500,
            lineNumber: 1,
          ),
          Posting(
            id: 'p4',
            entryId: 'e2',
            accountId: 'income-1',
            amountMinor: -500,
            lineNumber: 2,
          ),
        ],
      );
      entriesController.add([existing, justRecorded]);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.rows, hasLength(2));
      expect(viewModel.rows.first.entryId, equals('e2'));
      // The newly recorded entry's running balance is the account's
      // current balance (1000 + 500).
      expect(viewModel.rows.first.runningBalanceMinor, equals(1500));
    },
  );

  test('reverseEntry delegates to the Repository', () async {
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer((_) => Stream.value([income]));
    when(
      repository.watchEntriesForAccount(any),
    ).thenAnswer((_) => Stream.value(const []));
    when(repository.reverseEntry(any)).thenAnswer((_) async {});

    final viewModel = RegisterViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await viewModel.reverseEntry('e1');

    verify(repository.reverseEntry('e1')).called(1);
  });
}
