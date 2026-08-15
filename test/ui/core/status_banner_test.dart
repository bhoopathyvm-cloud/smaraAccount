import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/ui/core/app_colors.dart';
import 'package:smara_accounting/ui/core/status_banner.dart';

void main() {
  testWidgets('a dismissible banner shows a Dismiss action', (tester) async {
    var dismissed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatusBanner(
            message: 'Something went wrong.',
            onDismiss: () => dismissed = true,
          ),
        ),
      ),
    );

    expect(find.text('Dismiss'), findsOneWidget);
    await tester.tap(find.text('Dismiss'));
    expect(dismissed, isTrue);
  });

  testWidgets('a non-dismissible banner shows no Dismiss action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBanner(message: 'Currency mismatch.')),
      ),
    );

    expect(find.text('Dismiss'), findsNothing);
    expect(find.text('Currency mismatch.'), findsOneWidget);
  });

  testWidgets('isError styles the message text in signal red', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBanner(message: 'Currency mismatch.', isError: true),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Currency mismatch.'));
    expect(text.style?.color, AppColors.signal);
  });

  testWidgets('without isError the message uses default styling', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBanner(message: 'Saved successfully.')),
      ),
    );

    final text = tester.widget<Text>(find.text('Saved successfully.'));
    expect(text.style, isNull);
  });
}
