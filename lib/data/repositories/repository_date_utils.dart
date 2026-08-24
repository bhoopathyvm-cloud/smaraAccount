/// Shared by every repository that posts a journal entry - date-only
/// (no time-of-day) formatting for `transactionDate`, distinct from
/// `recordedAt`'s own full timestamp (smara-tech-guidelines.md Golden
/// Rule #6: only the transaction date is user-supplied).
String dateOnly(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
