import 'package:flutter_test/flutter_test.dart';

import '../integration_test/acceptance/support/acceptance_harness.dart';

void main() {
  test('staticTextOf stays a substring when the placeholder is followed '
      'by literal text', () {
    String template(String date) =>
        'Cannot sell: some units are locked '
        'until $date.';
    final prefix = staticTextOf(template);
    expect(template('2026-10-15'), contains(prefix));
  });

  test('staticTextOf stays a substring when the placeholder is the last '
      'thing in the template', () {
    String template(String date) => 'Locked until $date';
    final prefix = staticTextOf(template);
    expect(template('2026-10-15'), contains(prefix));
  });

  test('staticTextOf is never empty when the placeholder comes first', () {
    String template(String date) => '$dateに帳簿を引き継ぎました';
    final text = staticTextOf(template);
    expect(text, isNotEmpty);
    expect(template('2026/10/01'), contains(text));
  });
}
