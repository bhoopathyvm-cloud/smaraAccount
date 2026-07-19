import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/crypto/ed25519_signing.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/signing_identity.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
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
    repository = MockLedgerRepository();
    viewModel = RecoveryPhraseSetupViewModel(ledgerRepository: repository);
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
    });
  });

  group('confirm', () {
    test(
      'rejects a mismatched confirmation word without committing anything',
      () async {
        when(
          repository.generateFirstIdentity(),
        ).thenAnswer((_) async => generated);
        await viewModel.ensureGenerated();

        final wrongWords = {
          for (final i in RecoveryPhraseSetupViewModel.confirmationWordIndices)
            i: 'wrong',
        };

        final result = await viewModel.confirm(wrongWords);

        expect(result, isFalse);
        expect(viewModel.errorMessage, isNotNull);
        verifyNever(repository.confirmFirstIdentity(any));
      },
    );

    test(
      'commits the identity and verifies the chain when all words match',
      () async {
        when(
          repository.generateFirstIdentity(),
        ).thenAnswer((_) async => generated);
        await viewModel.ensureGenerated();

        final identity = SigningIdentity(
          identityId: 'identity-1',
          publicKey: generated.keyMaterial.publicKey,
          createdAt: DateTime.now(),
          supersedesIdentityId: null,
          supersededAt: null,
        );
        when(
          repository.confirmFirstIdentity(generated),
        ).thenAnswer((_) async => identity);
        when(repository.verifyChain()).thenAnswer(
          (_) async => const ChainVerificationResult(
            totalEntries: 0,
            breakEntryId: null,
            breakReason: null,
          ),
        );

        final correctWords = {
          for (final i in RecoveryPhraseSetupViewModel.confirmationWordIndices)
            i: generated.phrase.words[i],
        };

        final result = await viewModel.confirm(correctWords);

        expect(result, isTrue);
        expect(viewModel.errorMessage, isNull);
        verify(repository.confirmFirstIdentity(generated)).called(1);
        verify(repository.verifyChain()).called(1);
      },
    );
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
