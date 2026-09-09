import '../models/pending_transfer_kind.dart';

/// The two subtle rules a pending-transfer settlement turns on, in one
/// Flutter-free place so the settle-pending form ([SettlePendingDraft]) and
/// the write path (`LedgerPosting.settlePendingTransfer`) can never diverge:
///
/// - the *resolved target* account a settlement posts against, and
/// - whether the settlement follows the *shortfall path* - only a transfer
///   returning to its own source account compares the settled amount against
///   the provisional amount and may post a fee for the gap.
///
/// A `foreignTransaction` always settles against its own source account in
/// the account's native currency, so there is no shared-currency figure to
/// compare a shortfall against; a transfer delivered to its destination has
/// no shortfall either (multi-currency-support design.md Decision 5). Both
/// the draft and the posting previously restated these two rules; this
/// module is the single owner they both resolve through.
class PendingTransferSettlement {
  const PendingTransferSettlement._({
    required this.resolvedTargetAccountId,
    required this.isShortfallComparable,
  });

  /// Resolve settlement from the pending item's [kind] and its own
  /// [sourceAccountId], plus the [settledToAccountId] the user chose. The
  /// chosen account matters only for a transfer; a `foreignTransaction`
  /// ignores it and always returns to source. [settledToAccountId] may be
  /// null before a transfer's target has been picked.
  factory PendingTransferSettlement.resolve({
    required PendingTransferKind kind,
    required String sourceAccountId,
    String? settledToAccountId,
  }) {
    final target = kind == PendingTransferKind.foreignTransaction
        ? sourceAccountId
        : settledToAccountId;
    final shortfallComparable =
        kind == PendingTransferKind.transfer && target == sourceAccountId;
    return PendingTransferSettlement._(
      resolvedTargetAccountId: target,
      isShortfallComparable: shortfallComparable,
    );
  }

  /// The account a settlement entry posts against: the chosen source/
  /// destination for a transfer, always the source for a `foreignTransaction`.
  /// Null only when a transfer's target has not been chosen yet.
  final String? resolvedTargetAccountId;

  /// Whether the shortfall path applies (a transfer returning to its own
  /// source): only then is the settled amount compared against the
  /// provisional amount and a fee posted for any gap.
  final bool isShortfallComparable;
}
