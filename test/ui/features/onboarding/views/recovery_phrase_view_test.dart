import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/crypto/ed25519_signing.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/views/recovery_phrase_view.dart';

import '../../../../mocks.mocks.dart';

// Widget tests mock the Repository (dart-generate-test-mocks) rather than a
// real Drift database, matching register_view_test.dart's established
// pattern for this project.
void main() {
  late MockLedgerRepository repository;
  late RecoveryPhraseSetupViewModel viewModel;

  setUp(() {
    repository = MockLedgerRepository();
    viewModel = RecoveryPhraseSetupViewModel(ledgerRepository: repository);
  });

  testWidgets(
    'generates and displays all 24 words with consequences messaging',
    (tester) async {
      final phrase = RecoveryPhrase.generate();
      final keyMaterial = await const Ed25519Signing().keyPairFromSeed(
        phrase.seed,
      );
      when(repository.generateFirstIdentity()).thenAnswer(
        (_) async =>
            GeneratedIdentity(phrase: phrase, keyMaterial: keyMaterial),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RecoveryPhraseView(viewModel: viewModel, onContinue: () {}),
        ),
      );
      await tester.pump();

      for (final word in phrase.words) {
        expect(find.textContaining(word), findsWidgets);
      }
      expect(find.textContaining('permanently unverifiable'), findsOneWidget);
    },
  );

  testWidgets('tapping continue invokes the callback', (tester) async {
    final phrase = RecoveryPhrase.generate();
    final keyMaterial = await const Ed25519Signing().keyPairFromSeed(
      phrase.seed,
    );
    when(repository.generateFirstIdentity()).thenAnswer(
      (_) async => GeneratedIdentity(phrase: phrase, keyMaterial: keyMaterial),
    );
    var continued = false;

    await tester.pumpWidget(
      MaterialApp(
        home: RecoveryPhraseView(
          viewModel: viewModel,
          onContinue: () => continued = true,
        ),
      ),
    );
    await tester.pump();

    final button = find.text('I\'ve saved my recovery phrase');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pump();

    expect(continued, isTrue);
  });

  testWidgets(
    'shows a retry option when generation fails, never a permanent spinner',
    (tester) async {
      when(
        repository.generateFirstIdentity(),
      ).thenThrow(Exception('secure storage unavailable'));

      await tester.pumpWidget(
        MaterialApp(
          home: RecoveryPhraseView(viewModel: viewModel, onContinue: () {}),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
    },
  );
}
