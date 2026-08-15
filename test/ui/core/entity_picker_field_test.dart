import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/ui/core/entity_picker_field.dart';

class _Item {
  const _Item(this.id, this.label);
  final String id;
  final String label;
}

void main() {
  testWidgets('selecting an item reports its id', (tester) async {
    String? selected;
    const items = [_Item('1', 'Checking'), _Item('2', 'Savings')];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntityPickerField<_Item>(
            labelText: 'Account',
            items: items,
            idOf: (item) => item.id,
            labelOf: (item) => item.label,
            value: null,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Savings').last);
    await tester.pumpAndSettle();

    expect(selected, '2');
  });

  testWidgets('only the supplied (caller-filtered) items are offered', (
    tester,
  ) async {
    const items = [_Item('1', 'Checking')];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntityPickerField<_Item>(
            labelText: 'Account',
            items: items,
            idOf: (item) => item.id,
            labelOf: (item) => item.label,
            value: null,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('Checking'), findsOneWidget);
    expect(find.text('Savings'), findsNothing);
  });
}
