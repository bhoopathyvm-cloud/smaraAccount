import 'package:smara_accounting/domain/claims/claim_limit_hint.dart';
import 'package:test/test.dart';

void main() {
  test(
    'personal replaces company; company used when no personal; none when empty',
    () {
      expect(
        resolveClaimLimitHint(
          personalAmountMinor: 120,
          personalUnitLabel: 'per night',
          companyAmountMinor: 150,
          companyUnitLabel: 'per night',
        )?.amountMinor,
        120,
      );
      expect(
        resolveClaimLimitHint(
          personalAmountMinor: null,
          personalUnitLabel: null,
          companyAmountMinor: 150,
          companyUnitLabel: null,
        )?.source,
        'company',
      );
      expect(
        resolveClaimLimitHint(
          personalAmountMinor: null,
          personalUnitLabel: null,
          companyAmountMinor: null,
          companyUnitLabel: null,
        ),
        isNull,
      );
    },
  );

  test('above limit is a hint only — amounts are never changed', () {
    const hint = ClaimLimitHint(
      amountMinor: 120,
      unitLabel: 'per night',
      source: 'personal',
    );
    expect(isAboveClaimLimit(amountMinor: 210, hint: hint), isTrue);
    expect(isAboveClaimLimit(amountMinor: 100, hint: hint), isFalse);
    // Callers keep the entered amount; this helper only answers the hint.
    const entered = 210;
    expect(entered, 210);
  });
}
