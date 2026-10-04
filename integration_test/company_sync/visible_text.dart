import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Collects visible text from the pumped tree for conductor reports (task 7.2 / 7.5).
String dumpVisibleText(WidgetTester tester) {
  final buffer = StringBuffer();
  final texts = find.byType(Text).evaluate();
  for (final element in texts) {
    final widget = element.widget;
    if (widget is Text) {
      final data = widget.data ?? widget.textSpan?.toPlainText();
      if (data != null && data.trim().isNotEmpty) {
        buffer.writeln(data.trim());
      }
    }
  }
  final rich = find.byType(RichText).evaluate();
  for (final element in rich) {
    final widget = element.widget;
    if (widget is RichText) {
      final data = widget.text.toPlainText().trim();
      if (data.isNotEmpty) buffer.writeln(data);
    }
  }
  return buffer.toString();
}
