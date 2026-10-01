import '../models/account.dart';

/// One suggested or automatic merge candidate (same type + matching name
/// in any language).
class CategoryMergeCandidate {
  const CategoryMergeCandidate({
    required this.survivorId,
    required this.absorbedId,
    required this.matchedName,
    required this.type,
    required this.automatic,
  });

  final String survivorId;
  final String absorbedId;
  final String matchedName;
  final AccountType type;

  /// True when both categories already share a name in any language
  /// (auto-merge). False when a newly added translation matches another
  /// category (suggested merge).
  final bool automatic;
}

/// Catalog entry used when detecting duplicate categories across languages.
class CategoryNameCatalogEntry {
  const CategoryNameCatalogEntry({
    required this.id,
    required this.type,
    required this.defaultName,
    this.translatedNames = const [],
    this.createdAt,
  });

  final String id;
  final AccountType type;
  final String defaultName;
  final List<String> translatedNames;
  final DateTime? createdAt;

  Iterable<String> get allNames sync* {
    yield defaultName;
    yield* translatedNames;
  }
}

String _normalizeName(String name) => name.trim().toLowerCase();

/// Finds automatic merges: same type + same name in any language.
/// Survivor is the earlier-created category when timestamps exist; otherwise
/// the lower id (deterministic).
List<CategoryMergeCandidate> findAutomaticMerges(
  Iterable<CategoryNameCatalogEntry> entries,
) {
  final byTypeAndName = <String, List<CategoryNameCatalogEntry>>{};
  for (final entry in entries) {
    final seen = <String>{};
    for (final name in entry.allNames) {
      final key = '${entry.type.name}|${_normalizeName(name)}';
      if (!seen.add(key)) continue;
      byTypeAndName.putIfAbsent(key, () => []).add(entry);
    }
  }

  final candidates = <CategoryMergeCandidate>[];
  final paired = <String>{};
  for (final group in byTypeAndName.entries) {
    final list = group.value;
    if (list.length < 2) continue;
    final unique = <String, CategoryNameCatalogEntry>{
      for (final e in list) e.id: e,
    }.values.toList();
    if (unique.length < 2) continue;
    unique.sort(_compareForSurvivor);
    final survivor = unique.first;
    for (final absorbed in unique.skip(1)) {
      final pairKey = '${survivor.id}|${absorbed.id}';
      if (!paired.add(pairKey)) continue;
      final matchedName = group.key.split('|').skip(1).join('|');
      candidates.add(
        CategoryMergeCandidate(
          survivorId: survivor.id,
          absorbedId: absorbed.id,
          matchedName: matchedName,
          type: survivor.type,
          automatic: true,
        ),
      );
    }
  }
  return candidates;
}

/// When [newTranslation] for [categoryId] matches another category of the
/// same type, returns a suggested (non-automatic) merge.
CategoryMergeCandidate? suggestMergeForTranslation({
  required String categoryId,
  required AccountType type,
  required String newTranslation,
  required Iterable<CategoryNameCatalogEntry> others,
}) {
  final needle = _normalizeName(newTranslation);
  if (needle.isEmpty) return null;
  CategoryNameCatalogEntry? match;
  for (final other in others) {
    if (other.id == categoryId) continue;
    if (other.type != type) continue;
    for (final name in other.allNames) {
      if (_normalizeName(name) == needle) {
        match = other;
        break;
      }
    }
    if (match != null) break;
  }
  if (match == null) return null;

  final self = CategoryNameCatalogEntry(
    id: categoryId,
    type: type,
    defaultName: newTranslation,
  );
  final ordered = [self, match]..sort(_compareForSurvivor);
  final survivor = ordered.first;
  final absorbed = ordered.last;
  return CategoryMergeCandidate(
    survivorId: survivor.id,
    absorbedId: absorbed.id,
    matchedName: newTranslation.trim(),
    type: type,
    automatic: false,
  );
}

/// Walks [mergeMap] (absorbed → survivor) to the surviving category id.
String resolveSurvivorCategoryId(
  String categoryId,
  Map<String, String> mergeMap,
) {
  var current = categoryId;
  final seen = <String>{current};
  while (mergeMap.containsKey(current)) {
    current = mergeMap[current]!;
    if (!seen.add(current)) break; // cycle guard
  }
  return current;
}

int _compareForSurvivor(
  CategoryNameCatalogEntry a,
  CategoryNameCatalogEntry b,
) {
  final aAt = a.createdAt;
  final bAt = b.createdAt;
  if (aAt != null && bAt != null) {
    final byTime = aAt.compareTo(bAt);
    if (byTime != 0) return byTime;
  } else if (aAt != null) {
    return -1;
  } else if (bAt != null) {
    return 1;
  }
  return a.id.compareTo(b.id);
}
