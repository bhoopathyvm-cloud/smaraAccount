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

class InvalidTransferException implements Exception {
  InvalidTransferException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InvalidOpeningBalanceException implements Exception {
  InvalidOpeningBalanceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AccountGroupException implements Exception {
  AccountGroupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LastActiveAccountException implements Exception {
  LastActiveAccountException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Covers every settlement/pending-transfer business-rule violation
/// (multi-currency-support design.md Decision 5): negative or
/// provisional-exceeding settled amount, settling an already-settled
/// pending transfer, an invalid fee category or settlement target, and
/// attempting to reverse a still-pending provisional entry directly.
class PendingTransferException implements Exception {
  PendingTransferException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a selected file cannot be recognized as an OFX document at
/// all (ofx-transaction-import). Individual unparseable transaction rows
/// within an otherwise-recognized file are reported as [OfxSkippedRow]s
/// instead, not by throwing this.
class OfxParseException implements Exception {
  OfxParseException(this.message);

  final String message;

  @override
  String toString() => message;
}
