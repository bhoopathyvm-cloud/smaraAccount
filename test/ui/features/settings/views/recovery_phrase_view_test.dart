import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/crypto/ed25519_signing.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/recovery_phrase_view.dart';

import '../../../../mocks.mocks.dart';

// Widget tests mock the Repository (dart-generate-test-mocks) rather than a
// real Drift database, matching register_view_test.dart's established
// pattern for this project.
void main() {
  late MockIdentityRepository repository;
  late MockLedgerChainVerifier chainVerifier;
  late RecoveryPhraseSetupViewModel viewModel;

  setUp(() {
    repository = MockIdentityRepository();
    chainVerifier = MockLedgerChainVerifier();
    viewModel = RecoveryPhraseSetupViewModel(
      identityRepository: repository,
      chainVerifier: chainVerifier,
    );
  });

  testWidgets(
    'displays all 24 words of an already-stashed phrase with consequences '
    'messaging',
    (tester) async {
      final phrase = RecoveryPhrase.generate();
      final keyMaterial = await const Ed25519Signing().keyPairFromSeed(
        phrase.seed,
      );
      when(repository.resumePendingIdentity()).thenAnswer(
        (_) async =>
            GeneratedIdentity(phrase: phrase, keyMaterial: keyMaterial),
      );

      await tester.pumpWidget(
        MaterialApp(home: RecoveryPhraseView(viewModel: viewModel)),
      );
      await tester.pump();

      for (final word in phrase.words) {
        expect(find.textContaining(word), findsWidgets);
      }
      expect(find.textContaining('permanently unverifiable'), findsOneWidget);
      verifyNever(repository.generateFirstIdentity());
    },
  );

  testWidgets(
    'shows an explanatory message, not an error, when the identity has '
    'no phrase to show',
    (tester) async {
      when(repository.resumePendingIdentity()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        MaterialApp(home: RecoveryPhraseView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('no recovery phrase'), findsOneWidget);
      verifyNever(repository.generateFirstIdentity());
    },
  );

  testWidgets(
    'shows a retry option when loading fails, never a permanent spinner',
    (tester) async {
      when(
        repository.resumePendingIdentity(),
      ).thenThrow(Exception('secure storage unavailable'));

      await tester.pumpWidget(
        MaterialApp(home: RecoveryPhraseView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
    },
  );
}
