import '../models/home_overview.dart';
import '../models/pending_transfer.dart';

/// Mutable settle-pending form state: target account, settled amount,
/// fee category, and computed shortfall / currency visibility.
class SettlePendingDraft {
  SettlePendingDraft({required this.summary}) {
    if (isTransfer) {
      settledToAccountId = summary.pendingTransfer.destinationAccountId;
    }
  }

  final PendingTransferSummary summary;

  /// Currency of the current settlement target account's group (from
  /// catalog). Updated by the ViewModel when selection/catalog changes.
  String? targetAccountCurrency;

  String? settledToAccountId;
  int? settledAmountMinor;
  String? feeCategoryId;

  bool get isTransfer =>
      summary.pendingTransfer.kind == PendingTransferKind.transfer;

  /// True only for a transfer settling back to its own source account.
  bool get isShortfallComparable =>
      isTransfer &&
      settledToAccountId == summary.pendingTransfer.sourceAccountId;

  /// Currency [settledAmountMinor] should be entered in.
  String? get settledAmountCurrency {
    if (isShortfallComparable) return summary.currency;
    return targetAccountCurrency;
  }

  int get shortfallMinor {
    if (!isShortfallComparable) return 0;
    final settled = settledAmountMinor;
    if (settled == null) return 0;
    final shortfall = summary.amountMinor - settled;
    return shortfall > 0 ? shortfall : 0;
  }

  /// Account id to settle to for submit (destination for transfer, source
  /// for foreign transaction).
  String? get effectiveSettledToAccountId =>
      isTransfer ? settledToAccountId : summary.pendingTransfer.sourceAccountId;
}
