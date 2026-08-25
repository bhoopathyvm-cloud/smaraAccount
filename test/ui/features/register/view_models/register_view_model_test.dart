import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/journal_entry.dart';
import 'package:smara_accounting/domain/models/posting.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/register/view_models/register_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late MockAccountRepository accountRepository;
  late MockCategoryRepository categoryRepository;

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
    accountRepository = MockAccountRepository();
    categoryRepository = MockCategoryRepository();
    when(
      accountRepository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([asset]));
  });

  JournalEntry testEntry({
    required String id,
    required DateTime transactionDate,
    required List<Posting> postings,
    bool isVerified = true,
    bool isSupersededByMigration = false,
    String? reversesEntryId,
  }) {
    return JournalEntry(
      id: id,
      transactionDate: transactionDate,
      recordedAt: transactionDate,
      description: null,
      reversesEntryId: reversesEntryId,
      postings: postings,
      deviceChainSequence: 0,
      entryHash: const [],
      signedByIdentityId: 'identity-1',
      signature: const [],
      migratedFromEntryId: null,
      isVerified: isVerified,
      breakReason: isVerified ? null : VerificationBreakReason.hashMismatch,
      isSupersededByMigration: isSupersededByMigration,
    );
  }

  test('computes rows with running balance, newest entry first', () async {
    when(
      categoryRepository.watchCategories(
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

    final viewModel = RegisterViewModel(
      ledgerRepository: repository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
    );
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
        categoryRepository.watchCategories(
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

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
      );
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

  test('a migration-superseded entry is shown, labeled, and excluded from the '
      'running balance', () async {
    when(
      categoryRepository.watchCategories(
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
          isSupersededByMigration: true,
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

    final viewModel = RegisterViewModel(
      ledgerRepository: repository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
    );
    addTearDown(viewModel.dispose);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.rows, hasLength(2));
    // e2 (Jan 2, superseded) is the most recent entry, so it's first -
    // still shown and still verified, but excluded from the balance.
    expect(viewModel.rows[0].isSupersededByMigration, isTrue);
    expect(viewModel.rows[0].isVerified, isTrue);
    expect(viewModel.rows[0].runningBalanceMinor, equals(1000));
    expect(viewModel.rows[1].isSupersededByMigration, isFalse);
    expect(viewModel.rows[1].runningBalanceMinor, equals(1000));
  });

  test(
    'a newly recorded entry appears first, with the account\'s current balance',
    () async {
      when(
        categoryRepository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([income]));
      final entriesController = StreamController<List<JournalEntry>>();
      addTearDown(entriesController.close);
      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => entriesController.stream);

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
      );
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

  group('isRowFixable', () {
    const otherAsset = Account(
      id: 'asset-2',
      name: 'Savings',
      type: AccountType.asset,
      archived: false,
    );

    test(
      'true for an ordinary, verified, non-reversal category transaction',
      () async {
        when(
          categoryRepository.watchCategories(
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
          ]),
        );

        final viewModel = RegisterViewModel(
          ledgerRepository: repository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
        );
        addTearDown(viewModel.dispose);
        await Future<void>.delayed(Duration.zero);

        expect(viewModel.isRowFixable(viewModel.rows.single), isTrue);
      },
    );

    test(
      'false for a transfer row (counterpart is another financial account)',
      () async {
        when(
          accountRepository.watchFinancialAccounts(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer((_) => Stream.value([asset, otherAsset]));
        when(
          categoryRepository.watchCategories(
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
                  amountMinor: -1000,
                  lineNumber: 1,
                ),
                Posting(
                  id: 'p2',
                  entryId: 'e1',
                  accountId: 'asset-2',
                  amountMinor: 1000,
                  lineNumber: 2,
                ),
              ],
            ),
          ]),
        );

        final viewModel = RegisterViewModel(
          ledgerRepository: repository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
        );
        addTearDown(viewModel.dispose);
        await Future<void>.delayed(Duration.zero);

        expect(viewModel.isRowFixable(viewModel.rows.single), isFalse);
      },
    );

    test('false for a quarantined (unverified) entry', () async {
      when(
        categoryRepository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([income]));
      when(repository.watchEntriesForAccount(any)).thenAnswer(
        (_) => Stream.value([
          testEntry(
            id: 'e1',
            transactionDate: DateTime(2026, 1, 1),
            isVerified: false,
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
        ]),
      );

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.isRowFixable(viewModel.rows.single), isFalse);
    });

    test('false for an original that already has a reversal posted', () async {
      when(
        categoryRepository.watchCategories(
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
            id: 'e1-rev',
            transactionDate: DateTime(2026, 1, 2),
            reversesEntryId: 'e1',
            postings: const [
              Posting(
                id: 'p3',
                entryId: 'e1-rev',
                accountId: 'asset-1',
                amountMinor: -1000,
                lineNumber: 1,
              ),
              Posting(
                id: 'p4',
                entryId: 'e1-rev',
                accountId: 'income-1',
                amountMinor: 1000,
                lineNumber: 2,
              ),
            ],
          ),
        ]),
      );

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      final original = viewModel.rows.firstWhere((r) => r.entryId == 'e1');
      expect(viewModel.isRowFixable(original), isFalse);
    });
  });

  group('register-search', () {
    const groceries = Account(
      id: 'expense-1',
      name: 'Groceries',
      type: AccountType.expense,
      archived: false,
    );
    const rent = Account(
      id: 'expense-2',
      name: 'Rent',
      type: AccountType.expense,
      archived: false,
    );

    Future<RegisterViewModel> viewModelWithThreeRows() async {
      when(
        categoryRepository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([income, groceries, rent]));
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
                amountMinor: -1000,
                lineNumber: 1,
              ),
              Posting(
                id: 'p2',
                entryId: 'e1',
                accountId: 'expense-1',
                amountMinor: 1000,
                lineNumber: 2,
              ),
            ],
          ),
          testEntry(
            id: 'e2',
            transactionDate: DateTime(2026, 1, 10),
            postings: const [
              Posting(
                id: 'p3',
                entryId: 'e2',
                accountId: 'asset-1',
                amountMinor: 300000,
                lineNumber: 1,
              ),
              Posting(
                id: 'p4',
                entryId: 'e2',
                accountId: 'income-1',
                amountMinor: -300000,
                lineNumber: 2,
              ),
            ],
          ),
          testEntry(
            id: 'e3',
            transactionDate: DateTime(2026, 1, 20),
            postings: const [
              Posting(
                id: 'p5',
                entryId: 'e3',
                accountId: 'asset-1',
                amountMinor: -150000,
                lineNumber: 1,
              ),
              Posting(
                id: 'p6',
                entryId: 'e3',
                accountId: 'expense-2',
                amountMinor: 150000,
                lineNumber: 2,
              ),
            ],
          ),
        ]),
      );

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
      );
      await Future<void>.delayed(Duration.zero);
      return viewModel;
    }

    test('text search matches by category name (case-insensitive)', () async {
      final viewModel = await viewModelWithThreeRows();
      addTearDown(viewModel.dispose);
      expect(viewModel.rows, hasLength(3));

      viewModel.setSearchText('groc');

      expect(viewModel.rows, hasLength(1));
      expect(viewModel.rows.single.entryId, equals('e1'));
    });

    test('text search matches by amount', () async {
      final viewModel = await viewModelWithThreeRows();
      addTearDown(viewModel.dispose);

      viewModel.setSearchText('3,000.00');

      expect(viewModel.rows, hasLength(1));
      expect(viewModel.rows.single.entryId, equals('e2'));
    });

    test('direction filter narrows to spent-only or received-only', () async {
      final viewModel = await viewModelWithThreeRows();
      addTearDown(viewModel.dispose);

      viewModel.setDirectionFilter(TransactionDirection.moneyOut);
      expect(
        viewModel.rows.map((r) => r.entryId),
        unorderedEquals(['e1', 'e3']),
      );

      viewModel.setDirectionFilter(TransactionDirection.moneyIn);
      expect(viewModel.rows.map((r) => r.entryId), equals(['e2']));
    });

    test('date range filter combines with an active text search', () async {
      final viewModel = await viewModelWithThreeRows();
      addTearDown(viewModel.dispose);

      // Rent (e3) falls in this range but doesn't match the text search;
      // Groceries (e1) matches the text but falls outside the range.
      viewModel.setDateRangeFilter(
        start: DateTime(2026, 1, 15),
        end: DateTime(2026, 1, 25),
      );
      viewModel.setSearchText('groceries');
      expect(viewModel.rows, isEmpty);

      viewModel.setSearchText('rent');
      expect(viewModel.rows.map((r) => r.entryId), equals(['e3']));
    });

    test('clearing search and filters restores the full register', () async {
      final viewModel = await viewModelWithThreeRows();
      addTearDown(viewModel.dispose);

      viewModel.setSearchText('rent');
      viewModel.setDirectionFilter(TransactionDirection.moneyOut);
      viewModel.setDateRangeFilter(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );
      expect(viewModel.rows, hasLength(1));

      viewModel.clearSearchAndFilters();

      expect(viewModel.rows, hasLength(3));
      expect(viewModel.hasActiveSearchOrFilters, isFalse);
    });
  });

  group('split-transactions: multi-category register rows', () {
    const groceries = Account(
      id: 'expense-1',
      name: 'Groceries',
      type: AccountType.expense,
      archived: false,
    );
    const household = Account(
      id: 'expense-2',
      name: 'Household',
      type: AccountType.expense,
      archived: false,
    );

    JournalEntry splitEntry() {
      return testEntry(
        id: 'e1',
        transactionDate: DateTime(2026, 1, 15),
        postings: const [
          Posting(
            id: 'p1',
            entryId: 'e1',
            accountId: 'asset-1',
            amountMinor: -10000,
            lineNumber: 1,
          ),
          Posting(
            id: 'p2',
            entryId: 'e1',
            accountId: 'expense-1',
            amountMinor: 6000,
            lineNumber: 2,
          ),
          Posting(
            id: 'p3',
            entryId: 'e1',
            accountId: 'expense-2',
            amountMinor: 4000,
            lineNumber: 3,
          ),
        ],
      );
    }

    test('the row label summarizes every category, and counterpartAccountIds '
        'lists all of them', () async {
      when(
        categoryRepository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([groceries, household]));
      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => Stream.value([splitEntry()]));

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      final row = viewModel.rows.single;
      expect(row.categoryName, equals('Groceries +1 more'));
      expect(row.counterpartAccountIds, equals(['expense-1', 'expense-2']));
      // The amount shown is the full financial-account leg, unaffected
      // by how many category legs it has (spec: multi-account-ledger's
      // "A split entry's register row shows every category").
      expect(row.amountMinor, equals(10000));
    });

    test('a split row is not offered a Fix tap target', () async {
      when(
        categoryRepository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([groceries, household]));
      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => Stream.value([splitEntry()]));

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.isRowFixable(viewModel.rows.single), isFalse);
    });

    test(
      'an ordinary single-category row is unaffected: full name, one id, fixable',
      () async {
        when(
          categoryRepository.watchCategories(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer((_) => Stream.value([income]));
        when(repository.watchEntriesForAccount(any)).thenAnswer(
          (_) => Stream.value([
            testEntry(
              id: 'e2',
              transactionDate: DateTime(2026, 1, 1),
              postings: const [
                Posting(
                  id: 'p1',
                  entryId: 'e2',
                  accountId: 'asset-1',
                  amountMinor: 1000,
                  lineNumber: 1,
                ),
                Posting(
                  id: 'p2',
                  entryId: 'e2',
                  accountId: 'income-1',
                  amountMinor: -1000,
                  lineNumber: 2,
                ),
              ],
            ),
          ]),
        );

        final viewModel = RegisterViewModel(
          ledgerRepository: repository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
        );
        addTearDown(viewModel.dispose);
        await Future<void>.delayed(Duration.zero);

        final row = viewModel.rows.single;
        expect(row.categoryName, equals('Salary'));
        expect(row.counterpartAccountIds, equals(['income-1']));
        expect(viewModel.isRowFixable(row), isTrue);
      },
    );
  });

  test('reverseEntry delegates to the Repository', () async {
    when(
      categoryRepository.watchCategories(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([income]));
    when(
      repository.watchEntriesForAccount(any),
    ).thenAnswer((_) => Stream.value(const []));
    when(repository.reverseEntry(any)).thenAnswer((_) async {});

    final viewModel = RegisterViewModel(
      ledgerRepository: repository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
    );
    addTearDown(viewModel.dispose);

    await viewModel.reverseEntry('e1');

    verify(repository.reverseEntry('e1')).called(1);
  });

  test('closeoutSelectedAccount success notifies listeners; failure surfaces '
      'an error without changing selectedAccountId', () async {
    const archivedAsset = Account(
      id: 'asset-1',
      name: 'Cash & Bank',
      type: AccountType.asset,
      archived: true,
      groupId: 'group-1',
    );
    const other = Account(
      id: 'asset-2',
      name: 'Savings',
      type: AccountType.asset,
      archived: false,
      groupId: 'group-1',
    );
    when(
      accountRepository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([archivedAsset, other]));
    when(
      categoryRepository.watchCategories(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([income]));
    when(
      repository.watchEntriesForAccount(any),
    ).thenAnswer((_) => Stream.value(const []));
    when(
      accountRepository.recordArchivedAccountCloseoutTransfer(
        fromAccountId: anyNamed('fromAccountId'),
        toAccountId: anyNamed('toAccountId'),
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
        destinationAmountMinor: anyNamed('destinationAmountMinor'),
      ),
    ).thenAnswer((_) async {});

    final viewModel = RegisterViewModel(
      ledgerRepository: repository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
      initialAccountId: archivedAsset.id,
    );
    addTearDown(viewModel.dispose);
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.selectedAccountId, 'asset-1');

    var notified = 0;
    viewModel.addListener(() => notified++);
    final ok = await viewModel.closeoutSelectedAccount(
      toAccountId: 'asset-2',
      transactionDate: DateTime(2026, 1, 15),
    );
    expect(ok, isTrue);
    expect(notified, greaterThan(0));
    expect(viewModel.selectedAccountId, 'asset-1');
    expect(viewModel.errorMessage, isNull);

    when(
      accountRepository.recordArchivedAccountCloseoutTransfer(
        fromAccountId: anyNamed('fromAccountId'),
        toAccountId: anyNamed('toAccountId'),
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
        destinationAmountMinor: anyNamed('destinationAmountMinor'),
      ),
    ).thenThrow(AccountGroupException('Account asset-1 is archived.'));

    notified = 0;
    final failed = await viewModel.closeoutSelectedAccount(
      toAccountId: 'asset-2',
      transactionDate: DateTime(2026, 1, 15),
    );
    expect(failed, isFalse);
    expect(viewModel.errorMessage, isNotNull);
    expect(viewModel.selectedAccountId, 'asset-1');
    expect(notified, greaterThan(0));
  });

  group('ledger-data-export', () {
    test(
      'exportCsv delegates to the Repository for the selected account',
      () async {
        when(
          categoryRepository.watchCategories(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          repository.watchEntriesForAccount(any),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          repository.exportLedgerCsv(
            financialAccountId: anyNamed('financialAccountId'),
            start: anyNamed('start'),
            end: anyNamed('end'),
          ),
        ).thenAnswer(
          (_) async =>
              'Date,Description,Category,Direction,Amount,Currency,Verified\n',
        );

        final viewModel = RegisterViewModel(
          ledgerRepository: repository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
          initialAccountId: 'asset-1',
        );
        addTearDown(viewModel.dispose);
        await Future<void>.delayed(Duration.zero);

        final start = DateTime(2026, 1, 1);
        final end = DateTime(2026, 1, 31);
        final csv = await viewModel.exportCsv(start: start, end: end);

        expect(csv, isNotNull);
        verify(
          repository.exportLedgerCsv(
            financialAccountId: 'asset-1',
            start: start,
            end: end,
          ),
        ).called(1);
      },
    );

    test(
      'exportCsv surfaces an AccountGroupException as errorMessage',
      () async {
        when(
          categoryRepository.watchCategories(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          repository.watchEntriesForAccount(any),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          repository.exportLedgerCsv(
            financialAccountId: anyNamed('financialAccountId'),
            start: anyNamed('start'),
            end: anyNamed('end'),
          ),
        ).thenThrow(
          AccountGroupException(
            'not a financial account',
            code: AppErrorCode.accountNotFinancial,
          ),
        );

        final viewModel = RegisterViewModel(
          ledgerRepository: repository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
          initialAccountId: 'asset-1',
        );
        addTearDown(viewModel.dispose);
        await Future<void>.delayed(Duration.zero);

        final csv = await viewModel.exportCsv(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 1, 31),
        );

        expect(csv, isNull);
        expect(
          viewModel.errorMessage,
          equals('That is not a financial account.'),
        );
      },
    );
  });
}
