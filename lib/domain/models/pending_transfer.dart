import 'pending_transfer_kind.dart';

export 'pending_transfer_kind.dart';

/// Domain-facing view of a `pending_transfers` row (multi-currency-support
/// design.md Decision 4).
class PendingTransfer {
  const PendingTransfer({
    required this.id,
    required this.kind,
    required this.sourceAccountId,
    required this.currency,
    required this.provisionalEntryId,
    required this.status,
    required this.initiatedAt,
    this.categoryId,
    this.destinationAccountId,
    this.settlementEntryId,
    this.feeEntryId,
    this.settledAt,
  });

  final String id;
  final PendingTransferKind kind;
  final String sourceAccountId;

  /// Set only when [kind] is [PendingTransferKind.foreignTransaction].
  final String? categoryId;

  /// Planned destination; set only when [kind] is
  /// [PendingTransferKind.transfer].
  final String? destinationAccountId;

  /// The currency the provisional entry's clearing leg was posted in.
  final String currency;

  final String provisionalEntryId;
  final PendingTransferStatus status;
  final String? settlementEntryId;
  final String? feeEntryId;
  final DateTime initiatedAt;
  final DateTime? settledAt;

  bool get isSettled => status == PendingTransferStatus.settled;
}
