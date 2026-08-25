import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/crypto/ed25519_signing.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/ui/features/migration/view_models/key_loss_migration_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late MockIdentityRepository identityRepository;
  late KeyLossMigrationViewModel viewModel;

  setUp(() {
    repository = MockLedgerRepository();
    identityRepository = MockIdentityRepository();
    when(repository.watchEntries()).thenAnswer((_) => Stream.value(const []));
    viewModel = KeyLossMigrationViewModel(
      ledgerRepository: repository,
      identityRepository: identityRepository,
    );
    addTearDown(viewModel.dispose);
  });

  test('loads entries from the Repository for review', () async {
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.entries, isEmpty);
  });

  group('confirmAndMigrate', () {
    test('does nothing and returns false when not confirmed', () async {
      final result = await viewModel.confirmAndMigrate();

      expect(result, isFalse);
      verifyNever(identityRepository.migrateToNewIdentityAfterKeyLoss());
    });

    test('migrates once confirmed', () async {
      final phrase = RecoveryPhrase.generate();
      final keyMaterial = await const Ed25519Signing().keyPairFromSeed(
        phrase.seed,
      );
      when(identityRepository.migrateToNewIdentityAfterKeyLoss()).thenAnswer(
        (_) async =>
            GeneratedIdentity(phrase: phrase, keyMaterial: keyMaterial),
      );

      viewModel.setConfirmed(true);
      final result = await viewModel.confirmAndMigrate();

      expect(result, isTrue);
      expect(viewModel.isMigrating, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(identityRepository.migrateToNewIdentityAfterKeyLoss()).called(1);
    });

    test('surfaces a failure as errorMessage without rethrowing', () async {
      when(
        identityRepository.migrateToNewIdentityAfterKeyLoss(),
      ).thenThrow(Exception('boom'));

      viewModel.setConfirmed(true);
      final result = await viewModel.confirmAndMigrate();

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });
  });
}
