import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/journal_entry.dart';
import 'package:smara_accounting/domain/models/posting.dart';
import 'package:smara_accounting/ui/features/register/view_models/register_view_model.dart';
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
      repository.watchEntries(),
    ).thenAnswer((_) => Stream.value([entryWithAssetAmount(250000)]));

    final viewModel = RegisterViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: RegisterView(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('+2500.00'), findsOneWidget);
    // Running balance appears twice: once as the row's trailing balance,
    // once implicitly equal to the amount for a single-entry register.
    expect(find.text('2500.00'), findsOneWidget);
  });

  testWidgets('direction is shown via icon and sign, not a hardcoded color', (
    tester,
  ) async {
    when(
      repository.watchEntries(),
    ).thenAnswer((_) => Stream.value([entryWithAssetAmount(1000)]));

    final viewModel = RegisterViewModel(ledgerRepository: repository);
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
        repository.watchEntries(),
      ).thenAnswer((_) => Stream.value([quarantined]));

      final viewModel = RegisterViewModel(ledgerRepository: repository);
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
}
