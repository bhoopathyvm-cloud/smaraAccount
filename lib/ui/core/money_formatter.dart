import 'package:intl/intl.dart';

import '../../domain/money/currency_minor_units.dart';

export '../../domain/money/currency_minor_units.dart'
    show minorUnitDigitsForCurrency;

String _localeForCurrency(String currency) => localeForCurrency(currency);

/// Formats a signed minor-unit amount (e.g. cents) per [currency]'s own
/// convention - grouping, decimal separator, and minor-unit digit count
/// (e.g. none for JPY) - sourced from `intl`'s CLDR currency/locale data,
/// not a hand-maintained table. No currency symbol or code: callers that
/// display one append it themselves (multi-currency-support), and callers
/// add a sign/label per the design system's "direction is never
/// color-coded, use icon + sign + label" rule.
String formatAmountMinor(int amountMinor, String currency) {
  final format = NumberFormat.currency(
    locale: _localeForCurrency(currency),
    name: currency,
    symbol: '',
  );
  final minorUnitDigits = format.decimalDigits ?? 2;
  final major = amountMinor / _pow10(minorUnitDigits);
  return format.format(major).trim();
}

int _pow10(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

/// Parses [text] as an amount in [currency]'s own convention (its
/// decimal and grouping separators, per [_localeForCurrency]) into minor
/// units. Returns null both for an empty string and for genuinely
/// unparseable text - callers distinguish "nothing entered yet" from
/// "invalid" themselves via `text.trim().isEmpty`, since this function
/// can't tell those apart from the string alone (localized-money-formatting
/// design.md Decision 3: unparseable input must be rejected explicitly
/// by the caller, not silently coerced to zero).
int? parseAmountToMinor(String text, String currency) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;

  final format = NumberFormat.currency(
    locale: _localeForCurrency(currency),
    name: currency,
    symbol: '',
  );
  final decimalSep = format.symbols.DECIMAL_SEP;
  final groupSep = format.symbols.GROUP_SEP;

  var normalized = trimmed.replaceAll(groupSep, '');
  if (decimalSep != '.') {
    normalized = normalized.replaceAll(decimalSep, '.');
  }
  if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(normalized)) return null;

  final value = double.tryParse(normalized);
  if (value == null) return null;
  final minorUnitDigits = format.decimalDigits ?? 2;
  return (value * _pow10(minorUnitDigits)).round();
}
