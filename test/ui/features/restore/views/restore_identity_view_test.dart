import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/models/signing_identity.dart';
import 'package:smara_accounting/ui/features/restore/view_models/restore_identity_view_model.dart';
import 'package:smara_accounting/ui/features/restore/views/restore_identity_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late RestoreIdentityViewModel viewModel;

  final identity = SigningIdentity(
    identityId: 'identity-1',
    publicKey: const [1, 2, 3],
    createdAt: DateTime.now(),
    supersedesIdentityId: null,
    supersededAt: null,
  );
  const verified = ChainVerificationResult(
    totalEntries: 0,
    breakEntryId: null,
    breakReason: null,
  );

  setUp(() {
    repository = MockLedgerRepository();
    viewModel = RestoreIdentityViewModel(ledgerRepository: repository);
  });

  testWidgets(
    'defaults to phrase mode and restoring calls onRestored on success',
    (tester) async {
      when(
        repository.restoreIdentity(
          recoveryPhraseWords: anyNamed('recoveryPhraseWords'),
        ),
      ).thenAnswer((_) async => identity);
      when(repository.verifyChain()).thenAnswer((_) async => verified);
      var restored = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RestoreIdentityView(
            viewModel: viewModel,
            onRestored: () => restored = true,
            onNoRecoveryMaterial: () {},
          ),
        ),
      );

      expect(find.text('Recovery phrase (all 24 words)'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'word1 word2 word3');
      await tester.tap(find.text('Restore'));
      await tester.pump();

      expect(restored, isTrue);
    },
  );

  testWidgets(
    'switching to keystore mode shows file contents and passphrase fields',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RestoreIdentityView(
            viewModel: viewModel,
            onRestored: () {},
            onNoRecoveryMaterial: () {},
          ),
        ),
      );

      await tester.tap(find.text('Keystore file'));
      await tester.pump();

      expect(find.text('Keystore file contents'), findsOneWidget);
      expect(find.text('Passphrase'), findsOneWidget);
    },
  );

  testWidgets('a mismatch error is shown without navigating', (tester) async {
    when(
      repository.restoreIdentity(
        recoveryPhraseWords: anyNamed('recoveryPhraseWords'),
      ),
    ).thenThrow(Exception('no match'));
    var restored = false;

    await tester.pumpWidget(
      MaterialApp(
        home: RestoreIdentityView(
          viewModel: viewModel,
          onRestored: () => restored = true,
          onNoRecoveryMaterial: () {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'word1 word2 word3');
    await tester.tap(find.text('Restore'));
    await tester.pump();

    expect(restored, isFalse);
    expect(find.textContaining('Could not restore'), findsOneWidget);
  });

  testWidgets('the no-recovery-material link invokes its callback', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: RestoreIdentityView(
          viewModel: viewModel,
          onRestored: () {},
          onNoRecoveryMaterial: () => tapped = true,
        ),
      ),
    );

    await tester.tap(
      find.text('I don\'t have my recovery phrase or keystore file'),
    );
    await tester.pump();

    expect(tapped, isTrue);
  });
}
