import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/crypto/ed25519_signing.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/views/recovery_phrase_confirm_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockIdentityRepository repository;
  late RecoveryPhraseSetupViewModel viewModel;
  late GeneratedIdentity generated;

  setUp(() async {
    repository = MockIdentityRepository();
    viewModel = RecoveryPhraseSetupViewModel(identityRepository: repository);
    final phrase = RecoveryPhrase.generate();
    final keyMaterial = await const Ed25519Signing().keyPairFromSeed(
      phrase.seed,
    );
    generated = GeneratedIdentity(phrase: phrase, keyMaterial: keyMaterial);
    when(repository.generateFirstIdentity()).thenAnswer((_) async => generated);
    await viewModel.ensureGenerated();
  });

  Future<void> enterWords(WidgetTester tester, List<String> words) async {
    final fields = find.byType(TextField);
    for (
      var i = 0;
      i < RecoveryPhraseSetupViewModel.confirmationWordIndices.length;
      i++
    ) {
      await tester.enterText(fields.at(i), words[i]);
    }
  }

  testWidgets('blocks progress and shows an error on a mismatched word', (
    tester,
  ) async {
    var confirmed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: RecoveryPhraseConfirmView(
          viewModel: viewModel,
          onConfirmed: () => confirmed = true,
        ),
      ),
    );

    await enterWords(tester, ['wrong', 'wrong', 'wrong']);
    await tester.tap(find.text('Confirm'));
    await tester.pump();

    expect(confirmed, isFalse);
    expect(find.textContaining('doesn\'t match'), findsOneWidget);
    verifyNever(
      repository.confirmFirstIdentity(any, currency: anyNamed('currency')),
    );
  });

  testWidgets(
    'proceeds without committing the identity when all requested words match',
    (tester) async {
      var confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RecoveryPhraseConfirmView(
            viewModel: viewModel,
            onConfirmed: () => confirmed = true,
          ),
        ),
      );

      final correctWords = [
        for (final i in RecoveryPhraseSetupViewModel.confirmationWordIndices)
          generated.phrase.words[i],
      ];
      await enterWords(tester, correctWords);
      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(confirmed, isTrue);
      // deferred-onboarding-first-entry: the identity is already committed
      // by this point (via commitIdentity, from the earlier currency
      // screen) - confirming here only acknowledges it.
      verifyNever(
        repository.confirmFirstIdentity(any, currency: anyNamed('currency')),
      );
      verifyNever(repository.verifyChain());
    },
  );
}
