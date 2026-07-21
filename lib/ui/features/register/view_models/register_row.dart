import '../../../../domain/models/journal_entry.dart'
    show VerificationBreakReason;
import '../../../../domain/models/transaction_direction.dart';

/// A display-ready projection of one register row: [direction]/[amountMinor]
/// reflect the viewed account's *display* balance delta (see
/// `LedgerRepository.displayBalanceDeltaFor` - asset and liability accounts
/// invert the raw posting sign), so they always agree with
/// [runningBalanceMinor]; the counterpart posting tells us the category or
/// counterparty account to show.
class RegisterRow {
  const RegisterRow({
    required this.entryId,
    required this.categoryName,
    required this.direction,
    required this.amountMinor,
    required this.transactionDate,
    required this.description,
    required this.runningBalanceMinor,
    required this.isReversal,
    required this.isVerified,
    required this.breakReason,
  });

  final String entryId;
  final String categoryName;
  final TransactionDirection direction;

  /// Always a positive magnitude; [direction] carries the sign meaning.
  final int amountMinor;
  final DateTime transactionDate;
  final String? description;

  /// Never includes this or any earlier quarantined entry's amount (spec:
  /// "Quarantine of Entries After a Break" - excluded from running
  /// balance, but still visible for review).
  final int runningBalanceMinor;
  final bool isReversal;

  /// False for a quarantined entry - shown with the design system's error
  /// treatment (red left-border + lock icon), never hidden.
  final bool isVerified;
  final VerificationBreakReason? breakReason;
}
