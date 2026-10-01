import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/ui/features/setup_choice/view_models/bundle_import_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockBooksCopyRepository repository;
  late BundleImportViewModel viewModel;

  setUp(() {
    repository = MockBooksCopyRepository();
    viewModel = BundleImportViewModel(booksCopyRepository: repository);
  });

  group('importBundle', () {
    test('returns true on success', () async {
      when(
        repository.restoreBooksCopy(
          fileContents: anyNamed('fileContents'),
          passphrase: anyNamed('passphrase'),
        ),
      ).thenAnswer((_) async {});

      final result = await viewModel.importBundle(
        fileContents: '{"kind":"smara-books-copy"}',
        passphrase: 'hunter2',
      );

      expect(result, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isImporting, isFalse);
    });

    test('surfaces an invalid copy as errorMessage', () async {
      when(
        repository.restoreBooksCopy(
          fileContents: anyNamed('fileContents'),
          passphrase: anyNamed('passphrase'),
        ),
      ).thenThrow(InvalidLedgerBackupException('not a valid copy'));

      final result = await viewModel.importBundle(
        fileContents: '{}',
        passphrase: 'hunter2',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isImporting, isFalse);
    });

    test('surfaces a wrong passphrase as a generic errorMessage', () async {
      when(
        repository.restoreBooksCopy(
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
