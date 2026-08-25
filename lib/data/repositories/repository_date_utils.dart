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

/// Drift's `DateTimeColumn` stores values as whole-second unix timestamps
/// by default, so a value hashed at write time with millisecond precision
/// would never match what verifyChain recomputes after reading the same
/// value back from the database. Truncating before hashing (and before
/// storing) keeps the two in sync.
DateTime truncateToStoredPrecision(DateTime dateTime) {
  final seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
  return DateTime.fromMillisecondsSinceEpoch(
    seconds * 1000,
    isUtc: dateTime.isUtc,
  );
}

bool bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
