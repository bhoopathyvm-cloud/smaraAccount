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
          onImportFromBackup: () {},
        ),
      ),
    );

    await tester.tap(find.text('New setup'));
    await tester.pump();

    expect(newSetupTapped, isTrue);
  });

  testWidgets('tapping Import From Backup invokes onImportFromBackup', (
    tester,
  ) async {
    var importTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SetupChoiceView(
          onNewSetup: () {},
          onImportFromBackup: () => importTapped = true,
        ),
      ),
    );

    await tester.tap(find.text('Import from backup'));
    await tester.pump();

    expect(importTapped, isTrue);
  });
}
