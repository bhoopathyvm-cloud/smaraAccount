import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/ui/core/destructive_confirmation.dart';

void main() {
  Widget buildHarness(ValueChanged<bool> onResult) {
    return MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            final confirmed = await confirmDestructiveAction(
              context: context,
              title: 'Archive group?',
              message: 'This cannot be undone.',
            );
            onResult(confirmed);
          },
          child: const Text('Open'),
        ),
      ),
    );
  }

  testWidgets('confirming resolves to true', (tester) async {
    bool? result;
    await tester.pumpWidget(buildHarness((value) => result = value));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Archive group?'), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Hide'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('cancelling resolves to false', (tester) async {
    bool? result;
    await tester.pumpWidget(buildHarness((value) => result = value));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('confirmLabel overrides the default button text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => confirmDestructiveAction(
              context: context,
              title: 'Delete rule?',
              message: 'Gone for good.',
              confirmLabel: 'Delete',
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(OutlinedButton, 'Delete'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Archive'), findsNothing);
  });
}
