import '../money/currency_minor_units.dart';
import '../models/transaction_direction.dart';
import '../register/register_projection.dart';
import '../time/iso_date.dart';

/// Escape a CSV field per RFC 4180 (quote when commas/quotes/newlines).
String escapeCsvField(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

/// Plain, locale-independent decimal for [amountMinor] in [currency]
/// (period decimal, no grouping) — never locale-grouped display form.
String formatCsvAmount(int amountMinor, String currency) {
  final digits = minorUnitDigitsForCurrency(currency);
  final major = amountMinor / _pow10(digits);
  return major.toStringAsFixed(digits);
}

int _pow10(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

/// Serialize [projected] (newest-first register order) to an oldest-first
/// CSV string with the ledger-data-export header.
String buildLedgerCsv({
  required List<RegisterProjectedEntry> projected,
  required String currency,
}) {
  final buffer = StringBuffer()
    ..writeln('Date,Description,Category,Direction,Amount,Currency,Verified');
  for (final item in projected.reversed) {
    final direction = item.row.direction == TransactionDirection.moneyIn
        ? 'Received'
        : 'Spent';
    for (final leg in item.legs) {
      buffer.writeln(
        [
          dateOnly(item.row.transactionDate),
          escapeCsvField(item.row.description ?? ''),
          escapeCsvField(leg.label),
          direction,
          formatCsvAmount(leg.amountMinor, currency),
          currency,
          item.row.isVerified ? 'Yes' : 'No',
        ].join(','),
      );
    }
  }
  return buffer.toString();
}
