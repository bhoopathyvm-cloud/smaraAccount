/// Domain exceptions cross the Repository boundary instead of raw
/// Drift/SQLite exceptions (smara-tech-guidelines.md's error handling
/// pattern).
class InvalidTransactionAmountException implements Exception {
  InvalidTransactionAmountException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown by [LedgerRepository.restoreIdentity] when the re-derived key's
/// public key doesn't match any [SigningIdentity] already on record - the
/// recovery phrase or keystore file doesn't belong to this database.
class SigningIdentityMismatchException implements Exception {
  SigningIdentityMismatchException(this.message);

  final String message;

  @override
  String toString() => message;
}
