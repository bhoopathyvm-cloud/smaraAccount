import 'package:flutter_test/flutter_test.dart';

import '../integration_test/acceptance/support/acceptance_harness.dart';

void main() {
  test('localizedDay renders ASCII digits for a Western-numeral locale', () {
    expect(localizedDay('en', 15), '15');
  });

  test('localizedDay renders native-script digits for locales whose default '
      'numbering system is not Western (the real cause of a Bad state: No '
      'element failure when the acceptance suite searched for ASCII "15")', () {
    expect(localizedDay('bn', 15), isNot('15'));
    expect(localizedDay('as', 15), isNot('15'));
    expect(localizedDay('mr', 15), isNot('15'));
    expect(localizedDay('ne', 15), isNot('15'));
  });

  test('localizedDay falls back gracefully for an unrecognized locale tag', () {
    expect(localizedDay('zz', 15), '15');
  });
}
