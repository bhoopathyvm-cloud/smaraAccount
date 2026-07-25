/// Formats a signed minor-unit amount (e.g. cents) as "1234.56" /
/// "-1234.56" - no hardcoded currency symbol; callers that have a
/// currency in scope (an account's group, multi-currency-support) append
/// its code/symbol themselves, and callers add a sign/label per the
/// design system's "direction is never color-coded, use icon + sign +
/// label" rule.
String formatAmountMinor(int amountMinor) {
  final isNegative = amountMinor < 0;
  final absValue = amountMinor.abs();
  final major = absValue ~/ 100;
  final minor = (absValue % 100).toString().padLeft(2, '0');
  return '${isNegative ? '-' : ''}$major.$minor';
}
