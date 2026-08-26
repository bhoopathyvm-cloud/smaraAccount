import '../models/journal_entry.dart' show VerificationBreakReason;
import '../models/transaction_direction.dart';

/// A display-ready projection of one register row: [direction]/[amountMinor]
/// reflect the viewed account's *display* balance delta (see
/// [displayBalanceDeltaFor] - asset and liability accounts invert the raw
/// posting sign), so they always agree with [runningBalanceMinor]; the
/// counterpart posting tells us the category or counterparty account to show.
class RegisterRow {
  const RegisterRow({
    required this.entryId,
    required this.categoryName,
    required this.counterpartAccountIds,
    required this.direction,
    required this.amountMinor,
    required this.currency,
    required this.transactionDate,
    required this.description,
    required this.runningBalanceMinor,
    required this.isReversal,
    required this.isVerified,
    required this.breakReason,
    required this.isSupersededByMigration,
  });

  final String entryId;

  /// A single category/counterparty name, or (split-transactions) a
  /// summarized label like "Food +1 more" when the entry has more than
  /// one category leg.
  final String categoryName;

  /// The viewed account's own currency (localized-money-formatting) -
  /// every row in one account's register shares it, since an account
  /// belongs to exactly one currency.
  final String currency;

  /// Raw account ids of every counterpart posting on this entry (a
  /// category, another financial account for a transfer, the
  /// opening-balance equity account, or - split-transactions - more than
  /// one category) - used by fix-this-correction-wizard to prefill the
  /// Fix form's category, and to decide whether a row is fixable at all
  /// (only an ordinary, single-category transaction is; transfers,
  /// opening balances, and splits are not - `RegisterViewModel.isRowFixable`
  /// requires exactly one entry here).
  final List<String> counterpartAccountIds;
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

  /// True when this entry was superseded by a true key-loss migration.
  /// Shown with a muted historical label, distinct from the quarantine
  /// treatment - the entry is not unverifiable, just no longer current
  /// (spec: "Migration-Superseded Entries Are Visibly Marked").
  final bool isSupersededByMigration;
}
