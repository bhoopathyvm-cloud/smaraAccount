/// Domain exceptions cross the Repository boundary instead of raw
/// Drift/SQLite exceptions (smara-tech-guidelines.md's error handling
/// pattern).
class InvalidTransactionAmountException implements Exception {
  InvalidTransactionAmountException(this.message);

  final String message;

  @override
  String toString() => message;
}
