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
}
