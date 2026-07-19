import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/signing_identity.dart';
import 'package:smara_accounting/ui/features/restore/view_models/restore_identity_view_model.dart';

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
    totalEntries: 3,
    breakEntryId: null,
    breakReason: null,
  );

  setUp(() {
    repository = MockLedgerRepository();
    viewModel = RestoreIdentityViewModel(ledgerRepository: repository);
  });

  group('restoreFromPhrase', () {
    test(
      'splits input into words, restores, and verifies on success',
      () async {
        when(
          repository.restoreIdentity(
            recoveryPhraseWords: anyNamed('recoveryPhraseWords'),
          ),
        ).thenAnswer((_) async => identity);
        when(repository.verifyChain()).thenAnswer((_) async => verified);

        final result = await viewModel.restoreFromPhrase(
          '  word1  word2\nword3 ',
        );

        expect(result, isTrue);
        expect(viewModel.errorMessage, isNull);
        final captured =
            verify(
                  repository.restoreIdentity(
                    recoveryPhraseWords: captureAnyNamed('recoveryPhraseWords'),
                  ),
                ).captured.single
                as List<String>;
        expect(captured, equals(['word1', 'word2', 'word3']));
        verify(repository.verifyChain()).called(1);
      },
    );

    test('surfaces a mismatch as errorMessage without rethrowing', () async {
      when(
        repository.restoreIdentity(
          recoveryPhraseWords: anyNamed('recoveryPhraseWords'),
        ),
      ).thenThrow(SigningIdentityMismatchException('no match'));

      final result = await viewModel.restoreFromPhrase('word1 word2');

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isSubmitting, isFalse);
    });
  });

  group('restoreFromKeystore', () {
    test('restores and verifies on success', () async {
      when(
        repository.restoreIdentity(
          keystoreFileContents: anyNamed('keystoreFileContents'),
          keystorePassphrase: anyNamed('keystorePassphrase'),
        ),
      ).thenAnswer((_) async => identity);
      when(repository.verifyChain()).thenAnswer((_) async => verified);

      final result = await viewModel.restoreFromKeystore(
        fileContents: '{"version":1}',
        passphrase: 'hunter2',
      );

      expect(result, isTrue);
      verify(repository.verifyChain()).called(1);
    });

    test('surfaces a wrong passphrase as errorMessage', () async {
      when(
        repository.restoreIdentity(
          keystoreFileContents: anyNamed('keystoreFileContents'),
          keystorePassphrase: anyNamed('keystorePassphrase'),
        ),
      ).thenThrow(Exception('bad passphrase'));

      final result = await viewModel.restoreFromKeystore(
        fileContents: '{"version":1}',
        passphrase: 'wrong',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });
  });
}
