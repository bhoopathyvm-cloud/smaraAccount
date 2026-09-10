import 'package:flutter_test/flutter_test.dart';

import '../integration_test/acceptance/support/acceptance_harness.dart';

void main() {
  test('staticPrefixOf stays a substring when the placeholder is followed '
      'by literal text', () {
    String template(String date) =>
        'Cannot sell: some units are locked '
        'until $date.';
    final prefix = staticPrefixOf(template);
    expect(template('2026-10-15'), contains(prefix));
  });

  test('staticPrefixOf stays a substring when the placeholder is the last '
      'thing in the template', () {
    String template(String date) => 'Locked until $date';
    final prefix = staticPrefixOf(template);
    expect(template('2026-10-15'), contains(prefix));
  });
}
