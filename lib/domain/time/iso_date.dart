/// Calendar date as `YYYY-MM-DD` (no time-of-day). Used for user-supplied
/// transaction dates and CSV export — distinct from full timestamps like
/// `recordedAt` (Golden Rule #6).
String dateOnly(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Drift `DateTimeColumn` values are whole-second unix timestamps; truncate
/// before hashing/storing so verifyChain matches write-time hashes.
DateTime truncateToStoredPrecision(DateTime dateTime) {
  final seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
  return DateTime.fromMillisecondsSinceEpoch(
    seconds * 1000,
    isUtc: dateTime.isUtc,
  );
}
