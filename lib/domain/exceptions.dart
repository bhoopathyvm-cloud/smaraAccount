import 'app_error.dart';

export 'app_error.dart';

/// Domain exceptions cross the Repository boundary instead of raw
/// Drift/SQLite exceptions (smara-tech-guidelines.md's error handling
/// pattern). Each type carries a stable [AppErrorCode] plus structured
/// [params]; [message] remains English debug text for logs and existing
/// tests, not the UI localization source.
class InvalidTransactionAmountException implements Exception {
  InvalidTransactionAmountException(
    this.message, {
    this.code = AppErrorCode.amountMustBePositive,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

/// Thrown by [LedgerRepository.restoreIdentity] when the re-derived key's
/// public key doesn't match any [SigningIdentity] already on record - the
/// recovery phrase or keystore file doesn't belong to this database.
class SigningIdentityMismatchException implements Exception {
  SigningIdentityMismatchException(
    this.message, {
    this.code = AppErrorCode.signingIdentityMismatch,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

class InvalidTransferException implements Exception {
  InvalidTransferException(
    this.message, {
    this.code = AppErrorCode.generic,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

class InvalidOpeningBalanceException implements Exception {
  InvalidOpeningBalanceException(
    this.message, {
    this.code = AppErrorCode.openingBalanceMustBePositive,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

class AccountGroupException implements Exception {
  AccountGroupException(
    this.message, {
    this.code = AppErrorCode.generic,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

class LastActiveAccountException implements Exception {
  LastActiveAccountException(
    this.message, {
    this.code = AppErrorCode.lastActiveAccount,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

/// Covers every settlement/pending-transfer business-rule violation
/// (multi-currency-support design.md Decision 5): negative or
/// provisional-exceeding settled amount, settling an already-settled
/// pending transfer, an invalid fee category or settlement target, and
/// attempting to reverse a still-pending provisional entry directly.
class PendingTransferException implements Exception {
  PendingTransferException(
    this.message, {
    this.code = AppErrorCode.generic,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

/// Thrown when a selected file cannot be recognized as an OFX document at
/// all (ofx-transaction-import). Individual unparseable transaction rows
/// within an otherwise-recognized file are reported as
/// [StatementSkippedRow]s instead, not by throwing this.
class OfxParseException implements Exception {
  OfxParseException(
    this.message, {
    this.code = AppErrorCode.ofxUnrecognized,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

/// Thrown when a selected file cannot be read as delimited CSV data at all
/// (csv-transaction-import). An individual row that doesn't fit the
/// column mapping is reported as a [StatementSkippedRow] instead, not by
/// throwing this.
class CsvParseException implements Exception {
  CsvParseException(
    this.message, {
    this.code = AppErrorCode.csvUnreadable,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

/// Thrown by [LedgerBackupRepository.restoreLedgerBackup] when the decrypted
/// bytes don't open as a valid Smara ledger database at all (wrong file
/// selected, corrupted, or the passphrase decrypted garbage that happened
/// to pass the AEAD tag on some other file format - the open-as-database
/// step is a further sanity check beyond the AEAD authentication).
class InvalidLedgerBackupException implements Exception {
  InvalidLedgerBackupException(
    this.message, {
    this.code = AppErrorCode.invalidLedgerBackup,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

/// Thrown by [LedgerBackupRepository.restoreLedgerBackup] when the backup's
/// active signing identity differs from this device's own active identity
/// (ledger-backup-restore design.md Decision 4) - restoring it would
/// combine two different identities' books, not restore the user's own.
class ForeignBackupIdentityException implements Exception {
  ForeignBackupIdentityException(
    this.message, {
    this.code = AppErrorCode.foreignBackupIdentity,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

class InvestmentException implements Exception {
  const InvestmentException(
    this.message, {
    this.code = AppErrorCode.generic,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}

class InsufficientCashException extends InvestmentException {
  const InsufficientCashException(
    super.message, {
    super.code = AppErrorCode.insufficientCash,
    super.params,
  });
}

class InsufficientQuantityException extends InvestmentException {
  const InsufficientQuantityException(
    super.message, {
    super.code = AppErrorCode.insufficientQuantity,
    super.params,
  });
}

class LockedQuantityException extends InvestmentException {
  const LockedQuantityException(
    super.message, {
    super.code = AppErrorCode.lockedUntil,
    super.params,
  });
}

class InvestmentReversalBlockedException extends InvestmentException {
  const InvestmentReversalBlockedException(
    super.message, {
    super.code = AppErrorCode.investmentReversalBlocked,
    super.params,
  });
}

/// Thrown when [LedgerRepository.reverseEntry] (or Fix) is asked to
/// correct an original that already has a reversal posted. A second
/// negation would distort balances while leaving the original untouched.
class AlreadyReversedException implements Exception {
  AlreadyReversedException(
    this.message, {
    this.code = AppErrorCode.alreadyReversed,
    this.params = const {},
  });

  final String message;
  final AppErrorCode code;
  final Map<String, String> params;

  @override
  String toString() => message;
}
