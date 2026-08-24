import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/journal_entry.dart';
import 'package:smara_accounting/domain/models/posting.dart';
import 'package:smara_accounting/ui/features/register/view_models/register_view_model.dart';
import 'package:smara_accounting/ui/features/register/views/register_row_tile.dart';
import 'package:smara_accounting/ui/features/register/views/register_view.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../mocks.mocks.dart';

// Widget tests mock the Repository (dart-generate-test-mocks) rather than
// using a real Drift database: real native I/O (Drift/SQLite via FFI)
// inside testWidgets' fake-async zone hangs indefinitely instead of
// settling - discovered the hard way when an earlier version of this test
// used AppDatabase.forTesting(NativeDatabase.memory()) and never
// completed. Actual Repository/database correctness is covered by
// test/data/repositories/ledger_repository_test.dart, which uses plain
// test() (not testWidgets()) against a real in-memory database.
void main() {
  late MockLedgerRepository repository;
  late MockAccountRepository accountRepository;

  const salary = Account(
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
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer((_) => Stream.value([salary]));
    when(
      accountRepository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([asset]));
  });

  JournalEntry entryWithAssetAmount(int assetAmountMinor) {
    return JournalEntry(
      id: 'entry-1',
      transactionDate: DateTime(2026, 1, 15),
      recordedAt: DateTime(2026, 1, 15),
      description: null,
      reversesEntryId: null,
      postings: [
        Posting(
          id: 'p1',
          entryId: 'entry-1',
          accountId: 'asset-1',
          amountMinor: assetAmountMinor,
          lineNumber: 1,
        ),
        Posting(
          id: 'p2',
          entryId: 'entry-1',
          accountId: 'income-1',
          amountMinor: -assetAmountMinor,
          lineNumber: 2,
        ),
      ],
      deviceChainSequence: 0,
      entryHash: const [],
      signedByIdentityId: 'identity-1',
      signature: const [],
      migratedFromEntryId: null,
      isVerified: true,
      breakReason: null,
      isSupersededByMigration: false,
    );
  }

  testWidgets('renders category, amount, and running balance per row', (
    tester,
  ) async {
    when(
      repository.watchEntriesForAccount(any),
    ).thenAnswer((_) => Stream.value([entryWithAssetAmount(250000)]));

    final viewModel = RegisterViewModel(
      ledgerRepository: repository,
      accountRepository: accountRepository,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: RegisterView(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('+2,500.00'), findsOneWidget);
    // Running balance appears twice: once as the row's trailing balance,
    // once implicitly equal to the amount for a single-entry register.
    expect(find.text('2,500.00'), findsOneWidget);
  });

  testWidgets('direction is shown via icon and sign, not a hardcoded color', (
    tester,
  ) async {
    when(
      repository.watchEntriesForAccount(any),
    ).thenAnswer((_) => Stream.value([entryWithAssetAmount(1000)]));

    final viewModel = RegisterViewModel(
      ledgerRepository: repository,
      accountRepository: accountRepository,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: RegisterView(viewModel: viewModel)),
    );
    await tester.pump();

    final amountText = tester.widget<Text>(find.text('+10.00'));
    // Neutral primary text, never a green/red "money in" color (design
    // system: direction is never color-coded).
    expect(amountText.style?.color, isNot(equals(Colors.green)));
    expect(amountText.style?.color, isNot(equals(Colors.red)));
  });

  testWidgets(
    'a quarantined entry renders with the error treatment, never hidden',
    (tester) async {
      final quarantined = JournalEntry(
        id: 'entry-1',
        transactionDate: DateTime(2026, 1, 15),
        recordedAt: DateTime(2026, 1, 15),
        description: null,
        reversesEntryId: null,
        postings: [
          Posting(
            id: 'p1',
            entryId: 'entry-1',
            accountId: 'asset-1',
            amountMinor: 1000,
            lineNumber: 1,
          ),
          Posting(
            id: 'p2',
            entryId: 'entry-1',
            accountId: 'income-1',
            amountMinor: -1000,
            lineNumber: 2,
          ),
        ],
        deviceChainSequence: 0,
        entryHash: const [],
        signedByIdentityId: 'identity-1',
        signature: const [],
        migratedFromEntryId: null,
        isVerified: false,
        breakReason: VerificationBreakReason.hashMismatch,
        isSupersededByMigration: false,
      );
      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => Stream.value([quarantined]));

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: RegisterView(viewModel: viewModel)),
      );
      await tester.pump();

      // Still visible for review (never hidden) ...
      expect(find.text('Salary'), findsOneWidget);
      // ... but flagged, and excluded from the running balance.
      expect(find.byIcon(TablerIcons.lock), findsOneWidget);
      expect(find.text('0.00'), findsOneWidget);
    },
  );

  testWidgets(
    'a migration-superseded entry renders with a muted historical label, '
    'never hidden, distinct from the quarantine treatment',
    (tester) async {
      final superseded = JournalEntry(
        id: 'entry-1',
        transactionDate: DateTime(2026, 1, 15),
        recordedAt: DateTime(2026, 1, 15),
        description: null,
        reversesEntryId: null,
        postings: [
          Posting(
            id: 'p1',
            entryId: 'entry-1',
            accountId: 'asset-1',
            amountMinor: 1000,
            lineNumber: 1,
          ),
          Posting(
            id: 'p2',
            entryId: 'entry-1',
            accountId: 'income-1',
            amountMinor: -1000,
            lineNumber: 2,
          ),
        ],
        deviceChainSequence: 0,
        entryHash: const [],
        signedByIdentityId: 'identity-1',
        signature: const [],
        migratedFromEntryId: null,
        isVerified: true,
        breakReason: null,
        isSupersededByMigration: true,
      );
      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => Stream.value([superseded]));

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: RegisterView(viewModel: viewModel)),
      );
      await tester.pump();

      // Still visible for review (never hidden) ...
      expect(find.text('Salary'), findsOneWidget);
      // ... labeled distinctly from the quarantine treatment ...
      expect(
        find.text('Superseded by migration - excluded from totals'),
        findsOneWidget,
      );
      expect(find.byIcon(TablerIcons.history), findsOneWidget);
      expect(find.byIcon(TablerIcons.lock), findsNothing);
      // ... and excluded from the running balance.
      expect(find.text('0.00'), findsOneWidget);
    },
  );

  testWidgets('the most recently posted entry renders above an older one', (
    tester,
  ) async {
    when(repository.watchEntriesForAccount(any)).thenAnswer(
      (_) => Stream.value([
        JournalEntry(
          id: 'entry-older',
          transactionDate: DateTime(2026, 1, 1),
          recordedAt: DateTime(2026, 1, 1),
          description: null,
          reversesEntryId: null,
          postings: const [
            Posting(
              id: 'p1',
              entryId: 'entry-older',
              accountId: 'asset-1',
              amountMinor: 1000,
              lineNumber: 1,
            ),
            Posting(
              id: 'p2',
              entryId: 'entry-older',
              accountId: 'income-1',
              amountMinor: -1000,
              lineNumber: 2,
            ),
          ],
          deviceChainSequence: 0,
          entryHash: const [],
          signedByIdentityId: 'identity-1',
          signature: const [],
          migratedFromEntryId: null,
          isVerified: true,
          breakReason: null,
          isSupersededByMigration: false,
        ),
        JournalEntry(
          id: 'entry-newer',
          transactionDate: DateTime(2026, 1, 15),
          recordedAt: DateTime(2026, 1, 15),
          description: null,
          reversesEntryId: null,
          postings: const [
            Posting(
              id: 'p3',
              entryId: 'entry-newer',
              accountId: 'asset-1',
              amountMinor: 500,
              lineNumber: 1,
            ),
            Posting(
              id: 'p4',
              entryId: 'entry-newer',
              accountId: 'income-1',
              amountMinor: -500,
              lineNumber: 2,
            ),
          ],
          deviceChainSequence: 0,
          entryHash: const [],
          signedByIdentityId: 'identity-1',
          signature: const [],
          migratedFromEntryId: null,
          isVerified: true,
          breakReason: null,
          isSupersededByMigration: false,
        ),
      ]),
    );

    final viewModel = RegisterViewModel(
      ledgerRepository: repository,
      accountRepository: accountRepository,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: RegisterView(viewModel: viewModel)),
    );
    await tester.pump();

    final newerTop = tester.getTopLeft(find.text('+5.00')).dy;
    final olderTop = tester.getTopLeft(find.text('+10.00')).dy;
    expect(newerTop, lessThan(olderTop));
  });

  testWidgets('tapping a fixable row invokes onFixEntry with that row', (
    tester,
  ) async {
    when(
      repository.watchEntriesForAccount(any),
    ).thenAnswer((_) => Stream.value([entryWithAssetAmount(1000)]));

    final viewModel = RegisterViewModel(
      ledgerRepository: repository,
      accountRepository: accountRepository,
    );
    addTearDown(viewModel.dispose);
    String? fixedEntryId;

    await tester.pumpWidget(
      MaterialApp(
        home: RegisterView(
          viewModel: viewModel,
          onFixEntry: (row) => fixedEntryId = row.entryId,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Salary'));
    await tester.pump();

    expect(fixedEntryId, equals('entry-1'));
    expect(find.text('Fix'), findsOneWidget);
  });

  testWidgets(
    'a transfer row (counterpart is another financial account) has no tap target',
    (tester) async {
      const otherAsset = Account(
        id: 'asset-2',
        name: 'Savings',
        type: AccountType.asset,
        archived: false,
      );
      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([asset, otherAsset]));
      when(repository.watchEntriesForAccount(any)).thenAnswer(
        (_) => Stream.value([
          JournalEntry(
            id: 'entry-1',
            transactionDate: DateTime(2026, 1, 15),
            recordedAt: DateTime(2026, 1, 15),
            description: null,
            reversesEntryId: null,
            postings: const [
              Posting(
                id: 'p1',
                entryId: 'entry-1',
                accountId: 'asset-1',
                amountMinor: -1000,
                lineNumber: 1,
              ),
              Posting(
                id: 'p2',
                entryId: 'entry-1',
                accountId: 'asset-2',
                amountMinor: 1000,
                lineNumber: 2,
              ),
            ],
            deviceChainSequence: 0,
            entryHash: const [],
            signedByIdentityId: 'identity-1',
            signature: const [],
            migratedFromEntryId: null,
            isVerified: true,
            breakReason: null,
            isSupersededByMigration: false,
          ),
        ]),
      );

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
      );
      addTearDown(viewModel.dispose);
      var fixCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RegisterView(
            viewModel: viewModel,
            onFixEntry: (_) => fixCalled = true,
          ),
        ),
      );
      await tester.pump();

      final rowInkWell = find.descendant(
        of: find.byType(RegisterRowTile),
        matching: find.byType(InkWell),
      );
      final inkWell = tester.widget<InkWell>(rowInkWell);
      expect(inkWell.onTap, isNull);
      expect(find.text('Fix'), findsNothing);

      await tester.tap(rowInkWell);
      await tester.pump();
      expect(fixCalled, isFalse);
    },
  );

  testWidgets(
    'the single Add action opens a sheet whose Moved money choice invokes '
    'onTransfer',
    (tester) async {
      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => Stream.value(const []));

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
      );
      addTearDown(viewModel.dispose);
      var transferTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RegisterView(
            viewModel: viewModel,
            onTransfer: () => transferTapped = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(FloatingActionButton, 'Add'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Moved money'));
      await tester.pumpAndSettle();

      expect(transferTapped, isTrue);
    },
  );

  testWidgets(
    'the single Add action is disabled when the selected account is archived, '
    'enabled when active',
    (tester) async {
      const archivedAsset = Account(
        id: 'asset-1',
        name: 'Cash & Bank',
        type: AccountType.asset,
        archived: true,
      );
      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([archivedAsset]));
      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => Stream.value(const []));

      final archivedViewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
      );
      addTearDown(archivedViewModel.dispose);
      var spentTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RegisterView(
            viewModel: archivedViewModel,
            onSpent: () => spentTapped = true,
          ),
        ),
      );
      await tester.pump();

      final archivedFab = tester.widget<FloatingActionButton>(
        find.widgetWithText(FloatingActionButton, 'Add'),
      );
      expect(archivedFab.onPressed, isNull);
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Add'));
      await tester.pumpAndSettle();
      expect(find.text('Spent'), findsNothing);
      expect(spentTapped, isFalse);

      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([asset]));
      final activeViewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
      );
      addTearDown(activeViewModel.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterView(
            viewModel: activeViewModel,
            onSpent: () => spentTapped = true,
          ),
        ),
      );
      await tester.pump();

      final activeFab = tester.widget<FloatingActionButton>(
        find.widgetWithText(FloatingActionButton, 'Add'),
      );
      expect(activeFab.onPressed, isNotNull);
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Add'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spent'));
      await tester.pumpAndSettle();
      expect(spentTapped, isTrue);
    },
  );

  testWidgets(
    'closeout is offered only when the selected account is archived with a '
    'positive balance',
    (tester) async {
      const archivedAsset = Account(
        id: 'asset-1',
        name: 'Cash & Bank',
        type: AccountType.asset,
        archived: true,
      );
      const other = Account(
        id: 'asset-2',
        name: 'Savings',
        type: AccountType.asset,
        archived: false,
      );
      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([archivedAsset, other]));
      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => Stream.value([entryWithAssetAmount(10000)]));

      final withBalance = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        initialAccountId: archivedAsset.id,
      );
      addTearDown(withBalance.dispose);
      await tester.pumpWidget(
        MaterialApp(home: RegisterView(viewModel: withBalance)),
      );
      await tester.pump();
      expect(find.text('Transfer remaining balance'), findsOneWidget);

      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => Stream.value(const []));
      final zeroBalance = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        initialAccountId: archivedAsset.id,
      );
      addTearDown(zeroBalance.dispose);
      await tester.pumpWidget(
        MaterialApp(home: RegisterView(viewModel: zeroBalance)),
      );
      await tester.pump();
      expect(find.text('Transfer remaining balance'), findsNothing);

      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([asset, other]));
      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => Stream.value([entryWithAssetAmount(10000)]));
      final active = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
      );
      addTearDown(active.dispose);
      await tester.pumpWidget(
        MaterialApp(home: RegisterView(viewModel: active)),
      );
      await tester.pump();
      expect(find.text('Transfer remaining balance'), findsNothing);
    },
  );

  testWidgets(
    'typing in the search box narrows visible rows; the clear button restores '
    'them',
    (tester) async {
      when(repository.watchEntriesForAccount(any)).thenAnswer(
        (_) => Stream.value([
          entryWithAssetAmount(1000),
          JournalEntry(
            id: 'entry-2',
            transactionDate: DateTime(2026, 1, 20),
            recordedAt: DateTime(2026, 1, 20),
            description: 'Rent',
            reversesEntryId: null,
            postings: const [
              Posting(
                id: 'p3',
                entryId: 'entry-2',
                accountId: 'asset-1',
                amountMinor: -500,
                lineNumber: 1,
              ),
              Posting(
                id: 'p4',
                entryId: 'entry-2',
                accountId: 'income-1',
                amountMinor: 500,
                lineNumber: 2,
              ),
            ],
            deviceChainSequence: 0,
            entryHash: const [],
            signedByIdentityId: 'identity-1',
            signature: const [],
            migratedFromEntryId: null,
            isVerified: true,
            breakReason: null,
            isSupersededByMigration: false,
          ),
        ]),
      );

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: RegisterView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.byType(RegisterRowTile), findsNWidgets(2));

      await tester.enterText(find.byType(TextField).first, 'rent');
      await tester.pump();

      expect(find.byType(RegisterRowTile), findsOneWidget);
      expect(find.textContaining('Rent'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear search and filters'));
      await tester.pump();

      expect(find.byType(RegisterRowTile), findsNWidgets(2));
    },
  );

  group('credit-card-household-flow', () {
    const visaCard = Account(
      id: 'liability-1',
      name: 'Visa',
      type: AccountType.liability,
      archived: false,
      isCreditCard: true,
    );

    testWidgets(
      '"Pay card" is offered for an active credit-card account and invokes '
      'onPayCard',
      (tester) async {
        when(
          accountRepository.watchFinancialAccounts(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer((_) => Stream.value([visaCard]));
        when(
          repository.watchEntriesForAccount(any),
        ).thenAnswer((_) => Stream.value(const []));

        final viewModel = RegisterViewModel(
          ledgerRepository: repository,
          accountRepository: accountRepository,
        );
        addTearDown(viewModel.dispose);
        var payCardTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: RegisterView(
              viewModel: viewModel,
              onPayCard: () => payCardTapped = true,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Pay card'), findsOneWidget);
        await tester.tap(find.text('Pay card'));
        await tester.pump();

        expect(payCardTapped, isTrue);
      },
    );

    testWidgets('no "Pay card" for an ordinary (non-card) account', (
      tester,
    ) async {
      when(
        repository.watchEntriesForAccount(any),
      ).thenAnswer((_) => Stream.value(const []));

      final viewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: RegisterView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.text('Pay card'), findsNothing);
    });
  });

  group('ledger-data-export', () {
    testWidgets(
      'the app bar offers an Export CSV action, which opens a date range picker',
      (tester) async {
        when(
          repository.watchEntriesForAccount(any),
        ).thenAnswer((_) => Stream.value(const []));

        final viewModel = RegisterViewModel(
          ledgerRepository: repository,
          accountRepository: accountRepository,
        );
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: RegisterView(viewModel: viewModel)),
        );
        await tester.pump();

        expect(find.byTooltip('Export CSV'), findsOneWidget);

        await tester.tap(find.byTooltip('Export CSV'));
        await tester.pumpAndSettle();

        // showDateRangePicker's dialog is now open, without going further
        // into picking dates and triggering the real file_picker platform
        // channel (same depth settings_view_test.dart's backup-export
        // tests use).
        expect(find.byType(Dialog), findsOneWidget);
      },
    );
  });
}
