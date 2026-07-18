/// Domain exceptions cross the Repository boundary instead of raw
/// Drift/SQLite exceptions (smara-tech-guidelines.md's error handling
/// pattern).
class InvalidTransactionAmountException implements Exception {
  InvalidTransactionAmountException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown by [LedgerRepository.ensureCurrentIdentity] when the database
/// already has a signing identity but this device's secure storage has no
/// matching private key - the "existing database file detected" reinstall
/// scenario (spec: "Recoverable Reinstall or Device Migration"). The
/// caller should route to the restore-from-recovery-phrase/keystore flow
/// rather than silently generating a new identity.
class SigningIdentityMissingException implements Exception {
  SigningIdentityMissingException(this.message);

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
