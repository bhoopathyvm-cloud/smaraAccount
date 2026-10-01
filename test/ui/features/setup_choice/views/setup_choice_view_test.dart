import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/ui/features/setup_choice/views/setup_choice_view.dart';

void main() {
  testWidgets('tapping New Setup invokes onNewSetup', (tester) async {
    var newSetupTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SetupChoiceView(
          onNewSetup: () => newSetupTapped = true,
          onRestoreFromCopy: () {},
        ),
      ),
    );

    await tester.tap(find.text('New setup'));
    await tester.pump();

    expect(newSetupTapped, isTrue);
  });

  testWidgets('tapping Restore from a copy invokes onRestoreFromCopy', (
    tester,
  ) async {
    var restoreTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SetupChoiceView(
          onNewSetup: () {},
          onRestoreFromCopy: () => restoreTapped = true,
        ),
      ),
    );

    await tester.tap(find.text('Restore from a copy'));
    await tester.pump();

    expect(restoreTapped, isTrue);
  });
}
