/// Optional per-category spending-limit hint for Claims. Shown only —
/// never blocks submit or approve (design Decision 11).
class ClaimSpendingHint {
  const ClaimSpendingHint({
    required this.categoryId,
    required this.maxAmountMinor,
    required this.unitLabel,
  });

  final String categoryId;
  final int maxAmountMinor;

  /// e.g. "night", "meal".
  final String unitLabel;
}
