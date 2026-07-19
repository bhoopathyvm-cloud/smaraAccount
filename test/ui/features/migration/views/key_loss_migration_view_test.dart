import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/crypto/ed25519_signing.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/journal_entry.dart';
import 'package:smara_accounting/domain/models/posting.dart';
import 'package:smara_accounting/ui/features/migration/view_models/key_loss_migration_view_model.dart';
import 'package:smara_accounting/ui/features/migration/views/key_loss_migration_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late KeyLossMigrationViewModel viewModel;

  JournalEntry entry(String id, int assetAmount) {
    return JournalEntry(
      id: id,
      transactionDate: DateTime(2026, 1, 15),
      recordedAt: DateTime(2026, 1, 15),
      description: 'test entry',
      reversesEntryId: null,
      postings: [
        Posting(
          id: '$id-p1',
          entryId: id,
          accountId: 'asset',
          amountMinor: assetAmount,
          lineNumber: 1,
        ),
        Posting(
          id: '$id-p2',
          entryId: id,
          accountId: 'category',
          amountMinor: -assetAmount,
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

  setUp(() {
    repository = MockLedgerRepository();
    when(
      repository.watchEntries(),
    ).thenAnswer((_) => Stream.value([entry('e1', 1000)]));
    viewModel = KeyLossMigrationViewModel(ledgerRepository: repository);
  });

  testWidgets(
    'lists entries for review and states the non-retroactive wording',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: KeyLossMigrationView(viewModel: viewModel, onMigrated: () {}),
        ),
      );
      await tester.pump();

      expect(find.textContaining('test entry'), findsOneWidget);
      expect(
        find.textContaining('does NOT retroactively prove'),
        findsOneWidget,
      );
    },
  );

  testWidgets('the migrate button is disabled until the checkbox is checked', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: KeyLossMigrationView(viewModel: viewModel, onMigrated: () {}),
      ),
    );
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    final buttonAfter = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(buttonAfter.onPressed, isNotNull);
  });

  testWidgets('confirming and migrating invokes onMigrated on success', (
    tester,
  ) async {
    final phrase = RecoveryPhrase.generate();
    final keyMaterial = await const Ed25519Signing().keyPairFromSeed(
      phrase.seed,
    );
    when(repository.migrateToNewIdentityAfterKeyLoss()).thenAnswer(
      (_) async => GeneratedIdentity(phrase: phrase, keyMaterial: keyMaterial),
    );
    var migrated = false;

    await tester.pumpWidget(
      MaterialApp(
        home: KeyLossMigrationView(
          viewModel: viewModel,
          onMigrated: () => migrated = true,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Migrate to a new key'),
    );
    await tester.pump();
    await tester.pump();

    expect(migrated, isTrue);
  });
}
