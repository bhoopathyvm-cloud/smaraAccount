import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/ui/features/continuation/view_models/continuation_view_model.dart';
import 'package:smara_accounting/ui/features/continuation/views/continuation_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  testWidgets(
    'offers Continue my books and Restore from a copy',
    (tester) async {
      final viewModel = ContinuationViewModel(
        identityRepository: MockIdentityRepository(),
        chainVerifier: MockLedgerChainVerifier(),
        booksCopyRepository: MockBooksCopyRepository(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ContinuationView(
            viewModel: viewModel,
            onContinued: () {},
            onRestoreFromCopy: () {},
          ),
        ),
      );

      expect(find.text('Continue my books on this phone'), findsWidgets);
      expect(find.text('Restore from a copy'), findsOneWidget);
    },
  );
}
