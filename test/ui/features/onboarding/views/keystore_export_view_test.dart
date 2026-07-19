import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/views/keystore_export_view.dart';

import '../../../../mocks.mocks.dart';

// Never exercises the actual file write (path_provider needs a platform
// channel this test environment doesn't have) - only the parts reachable
// without one: initial render, the empty-passphrase validation message,
// and Skip always being available to continue past this optional step.
void main() {
  late MockLedgerRepository repository;
  late RecoveryPhraseSetupViewModel viewModel;

  setUp(() {
    repository = MockLedgerRepository();
    viewModel = RecoveryPhraseSetupViewModel(ledgerRepository: repository);
  });

  testWidgets('Skip always continues, regardless of passphrase state', (
    tester,
  ) async {
    var continued = false;

    await tester.pumpWidget(
      MaterialApp(
        home: KeystoreExportView(
          viewModel: viewModel,
          onContinue: () => continued = true,
        ),
      ),
    );

    await tester.tap(find.text('Skip'));
    await tester.pump();

    expect(continued, isTrue);
  });

  testWidgets('exporting with an empty passphrase shows a validation message', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: KeystoreExportView(viewModel: viewModel, onContinue: () {}),
      ),
    );

    await tester.tap(find.text('Export keystore file'));
    await tester.pump();

    expect(
      find.text('Enter a passphrase to protect the file.'),
      findsOneWidget,
    );
  });
}
