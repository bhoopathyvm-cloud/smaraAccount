import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/keystore_export_view.dart';

import '../../../../mocks.mocks.dart';

// Never exercises the actual file write (path_provider needs a platform
// channel this test environment doesn't have) - only the parts reachable
// without one: initial render and the empty-passphrase validation message.
void main() {
  late MockIdentityRepository repository;
  late MockLedgerChainVerifier chainVerifier;
  late RecoveryPhraseSetupViewModel viewModel;

  setUp(() {
    repository = MockIdentityRepository();
    chainVerifier = MockLedgerChainVerifier();
    viewModel = RecoveryPhraseSetupViewModel(
      identityRepository: repository,
      chainVerifier: chainVerifier,
    );
  });

  testWidgets('exporting with an empty passphrase shows a validation message', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: KeystoreExportView(viewModel: viewModel)),
    );

    await tester.tap(find.text('Export keystore file'));
    await tester.pump();

    expect(
      find.text('Enter a passphrase to protect the file.'),
      findsOneWidget,
    );
  });
}
