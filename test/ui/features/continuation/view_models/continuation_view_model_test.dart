import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_verifier.dart';
import 'package:smara_accounting/domain/models/signing_identity.dart';
import 'package:smara_accounting/ui/features/continuation/view_models/continuation_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockIdentityRepository identityRepository;
  late MockLedgerChainVerifier chainVerifier;
  late MockBooksCopyRepository booksCopyRepository;
  late ContinuationViewModel viewModel;

  setUp(() {
    identityRepository = MockIdentityRepository();
    chainVerifier = MockLedgerChainVerifier();
    booksCopyRepository = MockBooksCopyRepository();
    viewModel = ContinuationViewModel(
      identityRepository: identityRepository,
      chainVerifier: chainVerifier,
      booksCopyRepository: booksCopyRepository,
    );
  });

  test('continueBooks records Continuation and verifies the chain', () async {
    when(identityRepository.continueBooks()).thenAnswer(
      (_) async => SigningIdentity(
        identityId: 'new',
        publicKey: const [1],
        createdAt: DateTime.utc(2026, 1, 1),
        supersedesIdentityId: null,
        supersededAt: null,
        continuesIdentityId: 'old',
        continuedAt: null,
        acknowledgedAt: DateTime.utc(2026, 1, 1),
      ),
    );
    when(chainVerifier.verifyChain()).thenAnswer(
      (_) async => const ChainVerificationResult(
        totalEntries: 0,
        breakEntryId: null,
        breakReason: null,
      ),
    );

    final ok = await viewModel.continueBooks();

    expect(ok, isTrue);
    expect(viewModel.continued, isTrue);
    verify(identityRepository.continueBooks()).called(1);
    verify(chainVerifier.verifyChain()).called(1);
  });

  test('restoreFromCopy delegates to BooksCopyRepository', () async {
    when(
      booksCopyRepository.restoreBooksCopy(
        fileContents: anyNamed('fileContents'),
        passphrase: anyNamed('passphrase'),
      ),
    ).thenAnswer((_) async {});

    final ok = await viewModel.restoreFromCopy(
      fileContents: '{"kind":"smara-books-copy"}',
      passphrase: 'secret',
    );

    expect(ok, isTrue);
    verify(
      booksCopyRepository.restoreBooksCopy(
        fileContents: '{"kind":"smara-books-copy"}',
        passphrase: 'secret',
      ),
    ).called(1);
  });

  test(
    'restoreFromCopy records a failure when the repository throws',
    () async {
      when(
        booksCopyRepository.restoreBooksCopy(
          fileContents: anyNamed('fileContents'),
          passphrase: anyNamed('passphrase'),
        ),
      ).thenThrow(Exception('bad passphrase'));

      final ok = await viewModel.restoreFromCopy(
        fileContents: 'nope',
        passphrase: 'wrong',
      );

      expect(ok, isFalse);
      expect(viewModel.failure, isNotNull);
    },
  );
}
