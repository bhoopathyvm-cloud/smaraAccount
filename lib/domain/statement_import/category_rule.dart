/// A saved, reusable keyword-to-category rule (import-category-rules
/// design.md): applies to any statement-import row (OFX or CSV) across
/// every financial account, ahead of the exact-memo-match fallback.
class CategoryRule {
  const CategoryRule({
    required this.id,
    required this.keyword,
    required this.categoryId,
    required this.createdAt,
  });

  final String id;
  final String keyword;
  final String categoryId;
  final DateTime createdAt;
}

/// Trims and lowercases, so matching is whitespace- and case-insensitive
/// without requiring the user to type an exact-case keyword
/// (import-category-rules design.md Decision: "case-insensitive substring
/// match").
String normalizeDescription(String description) =>
    description.trim().toLowerCase();

/// The category from the most-recently-created rule whose keyword is a
/// substring of [description] (both compared via [normalizeDescription]),
/// or null if no rule matches. A rule with a blank keyword never matches -
/// the UI requires a non-empty keyword to save a rule, but this guards
/// against ever treating an empty keyword as "matches everything."
String? matchCategoryRule(String description, List<CategoryRule> rules) {
  final normalizedDescription = normalizeDescription(description);
  CategoryRule? best;
  for (final rule in rules) {
    final keyword = normalizeDescription(rule.keyword);
    if (keyword.isEmpty) continue;
    if (!normalizedDescription.contains(keyword)) continue;
    if (best == null || rule.createdAt.isAfter(best.createdAt)) {
      best = rule;
    }
  }
  return best?.categoryId;
}
