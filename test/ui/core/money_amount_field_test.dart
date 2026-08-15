import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/ui/core/money_amount_field.dart';

void main() {
  testWidgets('entering a valid amount reports it in minor units', (
    tester,
  ) async {
    int? reported;
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoneyAmountField(
            controller: controller,
            labelText: 'Amount',
            suffixText: 'USD',
            onChangedMinor: (value) => reported = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '12.34');

    expect(reported, 1234);
    expect(find.text('USD'), findsOneWidget);
  });

  testWidgets('clearing the field reports null', (tester) async {
    int? reported = -1;
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoneyAmountField(
            controller: controller,
            labelText: 'Amount',
            onChangedMinor: (value) => reported = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '5');
    expect(reported, 500);

    await tester.enterText(find.byType(TextField), '');
    expect(reported, isNull);
  });

  testWidgets('an unparseable value reports null', (tester) async {
    int? reported = -1;
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoneyAmountField(
            controller: controller,
            labelText: 'Amount',
            onChangedMinor: (value) => reported = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'abc');

    expect(reported, isNull);
  });
}
