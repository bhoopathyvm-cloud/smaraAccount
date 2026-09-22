import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/ui/features/setup_choice/view_models/bundle_import_view_model.dart';
import 'package:smara_accounting/ui/features/setup_choice/views/bundle_import_view.dart';

import '../../../../mocks.mocks.dart';

// Never exercises the actual file pick (file_picker needs a platform
// channel this test environment doesn't have), same constraint as the
// ledger-backup restore dialog's tests - only what's reachable without
// one: initial render and the choose-a-file-first validation. Success and
// wrong-passphrase behavior are covered directly at the view-model level
// in bundle_import_view_model_test.dart.
void main() {
  late MockDeviceMigrationBundleRepository repository;
  late BundleImportViewModel viewModel;

  setUp(() {
    repository = MockDeviceMigrationBundleRepository();
    viewModel = BundleImportViewModel(bundleRepository: repository);
  });

  testWidgets('renders the passphrase field and Import action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: BundleImportView(viewModel: viewModel)),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Import'), findsOneWidget);
  });

  testWidgets(
    'tapping Import without choosing a file shows a validation message, '
    'never calling the Repository',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: BundleImportView(viewModel: viewModel)),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Import'));
      await tester.pump();

      expect(
        find.text('Choose a device migration bundle file first.'),
        findsOneWidget,
      );
      verifyNever(
        repository.importBundle(
          fileContents: anyNamed('fileContents'),
          passphrase: anyNamed('passphrase'),
        ),
      );
    },
  );
}
