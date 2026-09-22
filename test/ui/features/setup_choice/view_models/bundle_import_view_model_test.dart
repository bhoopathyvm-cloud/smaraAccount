import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/ui/features/setup_choice/view_models/bundle_import_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockDeviceMigrationBundleRepository repository;
  late BundleImportViewModel viewModel;

  setUp(() {
    repository = MockDeviceMigrationBundleRepository();
    viewModel = BundleImportViewModel(bundleRepository: repository);
  });

  group('importBundle', () {
    test('returns true on success', () async {
      when(
        repository.importBundle(
          fileContents: anyNamed('fileContents'),
          passphrase: anyNamed('passphrase'),
        ),
      ).thenAnswer((_) async {});

      final result = await viewModel.importBundle(
        fileContents: '{"kind":"smara-device-migration-bundle"}',
        passphrase: 'hunter2',
      );

      expect(result, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isImporting, isFalse);
    });

    test(
      'surfaces a foreign identity as errorMessage without rethrowing',
      () async {
        when(
          repository.importBundle(
            fileContents: anyNamed('fileContents'),
            passphrase: anyNamed('passphrase'),
          ),
        ).thenThrow(
          ForeignDeviceMigrationBundleIdentityException('different identity'),
        );

        final result = await viewModel.importBundle(
          fileContents: '{}',
          passphrase: 'hunter2',
        );

        expect(result, isFalse);
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.isImporting, isFalse);
      },
    );

    test('surfaces an invalid bundle as errorMessage', () async {
      when(
        repository.importBundle(
          fileContents: anyNamed('fileContents'),
          passphrase: anyNamed('passphrase'),
        ),
      ).thenThrow(InvalidDeviceMigrationBundleException('not a bundle'));

      final result = await viewModel.importBundle(
        fileContents: '{}',
        passphrase: 'hunter2',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('surfaces a wrong passphrase as a generic errorMessage', () async {
      when(
        repository.importBundle(
          fileContents: anyNamed('fileContents'),
          passphrase: anyNamed('passphrase'),
        ),
      ).thenThrow(Exception('bad passphrase'));

      final result = await viewModel.importBundle(
        fileContents: '{}',
        passphrase: 'wrong',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });
  });
}
