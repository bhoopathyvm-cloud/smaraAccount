import '../../../../domain/models/transaction_direction.dart';

/// A display-ready projection of one register row: the journal entry's
/// asset-side posting tells us direction/amount (its sign is always
/// correct for that entry, including after a reversal); the category-side
/// posting tells us which category to show.
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
  });

  final String entryId;
  final String categoryName;
  final TransactionDirection direction;

  /// Always a positive magnitude; [direction] carries the sign meaning.
  final int amountMinor;
  final DateTime transactionDate;
  final String? description;
  final int runningBalanceMinor;
  final bool isReversal;
}
