/// Formats a signed minor-unit amount (e.g. cents) as "1234.56" /
/// "-1234.56" - no hardcoded currency symbol, since no currency field
/// exists anywhere in the schema or spec; callers add a sign/label per the
/// design system's "direction is never color-coded, use icon + sign +
/// label" rule.
String formatAmountMinor(int amountMinor) {
  final isNegative = amountMinor < 0;
  final absValue = amountMinor.abs();
  final major = absValue ~/ 100;
  final minor = (absValue % 100).toString().padLeft(2, '0');
  return '${isNegative ? '-' : ''}$major.$minor';
}
