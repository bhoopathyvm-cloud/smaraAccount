import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/domain/crypto/ed25519_signing.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/signing_identity.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockIdentityRepository repository;
  late RecoveryPhraseSetupViewModel viewModel;
  late GeneratedIdentity generated;

  setUpAll(() async {
    final phrase = RecoveryPhrase.generate();
    final keyMaterial = await const Ed25519Signing().keyPairFromSeed(
      phrase.seed,
    );
    generated = GeneratedIdentity(phrase: phrase, keyMaterial: keyMaterial);
  });

  setUp(() {
    repository = MockIdentityRepository();
    viewModel = RecoveryPhraseSetupViewModel(identityRepository: repository);
    // deferred-onboarding-first-entry: ensureGenerated() always checks for
    // a resumable (crash-interrupted) phrase first. Default to "nothing
    // pending" so existing true-first-generation tests don't need to know
    // about this - tests that care about resuming stub it explicitly.
    when(repository.resumePendingIdentity()).thenAnswer((_) async => null);
    when(repository.stashPendingPhraseWords(any)).thenAnswer((_) async {});
  });

  group('ensureGenerated', () {
    test('generates once and is idempotent across repeated calls', () async {
      when(
        repository.generateFirstIdentity(),
      ).thenAnswer((_) async => generated);

      await viewModel.ensureGenerated();
      await viewModel.ensureGenerated();

      expect(viewModel.isReady, isTrue);
      expect(viewModel.words, equals(generated.phrase.words));
      verify(repository.generateFirstIdentity()).called(1);
      verify(
        repository.stashPendingPhraseWords(generated.phrase.words),
      ).called(1);
    });

    test(
      'resumes an already-stashed phrase instead of generating a new one',
      () async {
        when(
          repository.resumePendingIdentity(),
        ).thenAnswer((_) async => generated);

        await viewModel.ensureGenerated();

        expect(viewModel.isReady, isTrue);
        expect(viewModel.words, equals(generated.phrase.words));
        verifyNever(repository.generateFirstIdentity());
        verifyNever(repository.stashPendingPhraseWords(any));
      },
    );
  });

  group('confirm', () {
    test(
      'rejects a mismatched confirmation word without acknowledging anything',
      () async {
        when(
          repository.generateFirstIdentity(),
        ).thenAnswer((_) async => generated);
        await viewModel.ensureGenerated();

        final wrongWords = {
          for (final i in RecoveryPhraseSetupViewModel.confirmationWordIndices)
            i: 'wrong',
        };

        final result = viewModel.confirm(wrongWords);

        expect(result, isFalse);
        expect(viewModel.errorMessage, isNotNull);
        verifyNever(repository.acknowledgeIdentity());
      },
    );

    test(
      'accepts all matching confirmation words without acknowledging anything',
      () async {
        when(
          repository.generateFirstIdentity(),
        ).thenAnswer((_) async => generated);
        await viewModel.ensureGenerated();

        final correctWords = {
          for (final i in RecoveryPhraseSetupViewModel.confirmationWordIndices)
            i: generated.phrase.words[i],
        };

        final result = viewModel.confirm(correctWords);

        expect(result, isTrue);
        expect(viewModel.errorMessage, isNull);
        verifyNever(repository.acknowledgeIdentity());
      },
    );
  });

  group('commitIdentity', () {
    test(
      'generates the identity if needed, commits it with the chosen currency, and verifies the chain',
      () async {
        when(
          repository.generateFirstIdentity(),
        ).thenAnswer((_) async => generated);

        final identity = SigningIdentity(
          identityId: 'identity-1',
          publicKey: generated.keyMaterial.publicKey,
          createdAt: DateTime.now(),
          supersedesIdentityId: null,
          supersededAt: null,
          acknowledgedAt: null,
        );
        when(
          repository.confirmFirstIdentity(generated, currency: 'USD'),
        ).thenAnswer((_) async => identity);
        when(repository.verifyChain()).thenAnswer(
          (_) async => const ChainVerificationResult(
            totalEntries: 0,
            breakEntryId: null,
            breakReason: null,
          ),
        );

        final result = await viewModel.commitIdentity('USD');

        expect(result, isTrue);
        verify(repository.generateFirstIdentity()).called(1);
        verify(
          repository.confirmFirstIdentity(generated, currency: 'USD'),
        ).called(1);
        verify(repository.verifyChain()).called(1);
      },
    );
  });

  group('acknowledge', () {
    test('delegates to the Repository', () async {
      when(repository.acknowledgeIdentity()).thenAnswer((_) async {});

      await viewModel.acknowledge();

      verify(repository.acknowledgeIdentity()).called(1);
    });
  });

  group('exportKeystoreFile', () {
    test('delegates to the Repository', () async {
      when(
        repository.exportKeystoreFile(passphrase: anyNamed('passphrase')),
      ).thenAnswer((_) async => '{"version":1}');

      final result = await viewModel.exportKeystoreFile(passphrase: 'hunter2');

      expect(result, equals('{"version":1}'));
    });
  });
}
