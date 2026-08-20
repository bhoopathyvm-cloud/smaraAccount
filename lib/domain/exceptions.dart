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
/// within an otherwise-recognized file are reported as
/// [StatementSkippedRow]s instead, not by throwing this.
class OfxParseException implements Exception {
  OfxParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a selected file cannot be read as delimited CSV data at all
/// (csv-transaction-import). An individual row that doesn't fit the
/// column mapping is reported as a [StatementSkippedRow] instead, not by
/// throwing this.
class CsvParseException implements Exception {
  CsvParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown by [LedgerRepository.restoreLedgerBackup] when the decrypted
/// bytes don't open as a valid Smara ledger database at all (wrong file
/// selected, corrupted, or the passphrase decrypted garbage that happened
/// to pass the AEAD tag on some other file format - the open-as-database
/// step is a further sanity check beyond the AEAD authentication).
class InvalidLedgerBackupException implements Exception {
  InvalidLedgerBackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown by [LedgerRepository.restoreLedgerBackup] when the backup's
/// active signing identity differs from this device's own active identity
/// (ledger-backup-restore design.md Decision 4) - restoring it would
/// combine two different identities' books, not restore the user's own.
class ForeignBackupIdentityException implements Exception {
  ForeignBackupIdentityException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InvestmentException implements Exception {
  const InvestmentException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InsufficientCashException extends InvestmentException {
  const InsufficientCashException(super.message);
}

class InsufficientQuantityException extends InvestmentException {
  const InsufficientQuantityException(super.message);
}

class LockedQuantityException extends InvestmentException {
  const LockedQuantityException(super.message);
}

class InvestmentReversalBlockedException extends InvestmentException {
  const InvestmentReversalBlockedException(super.message);
}
