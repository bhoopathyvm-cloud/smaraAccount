import '../models/transaction_direction.dart';
import 'register_row.dart';

/// Whether [row] can go through the Fix flow: ordinary, currently-verified,
/// single-category transaction that is not already reversed.
bool isRegisterRowFixable({
  required RegisterRow row,
  required Set<String> categoryIds,
  required Set<String> reversedEntryIds,
}) {
  return row.counterpartAccountIds.length == 1 &&
      categoryIds.contains(row.counterpartAccountIds.single) &&
      !row.isReversal &&
      !reversedEntryIds.contains(row.entryId) &&
      row.isVerified &&
      !row.isSupersededByMigration;
}

/// Client-side narrowing of register rows (search + date + direction).
/// [amountTextFor] supplies locale-formatted amount text for query match.
List<RegisterRow> filterRegisterRows({
  required List<RegisterRow> rows,
  required String searchText,
  DateTime? filterStartDate,
  DateTime? filterEndDate,
  TransactionDirection? filterDirection,
  required String Function(RegisterRow row) amountTextFor,
}) {
  final query = searchText.trim().toLowerCase();
  final hasQuery = query.isNotEmpty;
  final hasFilters =
      hasQuery ||
      filterStartDate != null ||
      filterEndDate != null ||
      filterDirection != null;
  if (!hasFilters) return rows;

  return rows.where((row) {
    if (filterDirection != null && row.direction != filterDirection) {
      return false;
    }
    if (filterStartDate != null &&
        row.transactionDate.isBefore(filterStartDate)) {
      return false;
    }
    if (filterEndDate != null) {
      final endExclusive = DateTime(
        filterEndDate.year,
        filterEndDate.month,
        filterEndDate.day + 1,
      );
      if (!row.transactionDate.isBefore(endExclusive)) return false;
    }
    if (!hasQuery) return true;
    final description = (row.description ?? '').toLowerCase();
    final category = row.categoryName.toLowerCase();
    final amountText = amountTextFor(row).toLowerCase();
    return description.contains(query) ||
        category.contains(query) ||
        amountText.contains(query);
  }).toList();
}
