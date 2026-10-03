import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_verifier.dart';
import 'package:smara_accounting/domain/crypto/ed25519_signing.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/signing_identity.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/first_identity_setup_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockIdentityRepository identityRepository;
  late MockLedgerChainVerifier chainVerifier;
  late FirstIdentitySetupViewModel viewModel;
  late GeneratedIdentity generated;

  setUp(() async {
    identityRepository = MockIdentityRepository();
    chainVerifier = MockLedgerChainVerifier();
    generated = GeneratedIdentity(
      keyMaterial: await const Ed25519Signing().generateKeyPair(),
    );
    when(
      identityRepository.generateFirstIdentity(),
    ).thenAnswer((_) async => generated);
    when(chainVerifier.verifyChain()).thenAnswer(
      (_) async => const ChainVerificationResult(
        totalEntries: 0,
        breakEntryId: null,
        breakReason: null,
      ),
    );
    viewModel = FirstIdentitySetupViewModel(
      identityRepository: identityRepository,
      chainVerifier: chainVerifier,
    );
  });

  test('a double tap on the last onboarding step commits once', () async {
    final release = Completer<void>();
    when(
      identityRepository.confirmFirstIdentity(
        any,
        currency: anyNamed('currency'),
      ),
    ).thenAnswer((_) async {
      await release.future;
      return SigningIdentity(
        identityId: 'id-1',
        publicKey: generated.keyMaterial.publicKey,
        createdAt: DateTime.utc(2026, 10, 3),
        supersedesIdentityId: null,
        supersededAt: null,
        continuesIdentityId: null,
        continuedAt: null,
        acknowledgedAt: DateTime.utc(2026, 10, 3),
      );
    });

    final firstTap = viewModel.commitIdentity('EUR');
    final secondTap = viewModel.commitIdentity('EUR');
    release.complete();

    expect(await firstTap, isTrue);
    expect(await secondTap, isTrue);
    expect(await viewModel.commitIdentity('EUR'), isTrue);
    verify(
      identityRepository.confirmFirstIdentity(
        any,
        currency: anyNamed('currency'),
      ),
    ).called(1);
  });
}
