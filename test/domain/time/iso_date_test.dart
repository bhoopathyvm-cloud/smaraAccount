import 'package:test/test.dart';

import 'package:smara_accounting/domain/time/iso_date.dart';

void main() {
  test('dateOnly pads YYYY-MM-DD', () {
    expect(dateOnly(DateTime(2026, 1, 5)), '2026-01-05');
    expect(dateOnly(DateTime(2026, 12, 31, 23, 59)), '2026-12-31');
  });

  test('truncateToStoredPrecision drops sub-second parts', () {
    final truncated = truncateToStoredPrecision(
      DateTime.fromMillisecondsSinceEpoch(1_700_000_000_456),
    );
    expect(truncated.millisecondsSinceEpoch % 1000, 0);
  });
}
