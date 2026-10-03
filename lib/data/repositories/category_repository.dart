import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/account.dart';
import '../../domain/models/summary.dart';
import '../../domain/shared_categories/category_display_name.dart';
import '../../domain/shared_categories/category_merge.dart';
import '../../domain/summary/ledger_summary_engine.dart';
import '../database/app_database.dart';
import 'account_chart_reader.dart';
import 'metadata_outbox.dart';
import 'repository_date_utils.dart';

/// One translation row for a category (locale → display name).
class CategoryTranslation {
  const CategoryTranslation({
    required this.categoryId,
    required this.locale,
    required this.name,
    required this.updatedAt,
  });

  final String categoryId;
  final String locale;
  final String name;
  final DateTime updatedAt;
}

/// Income/expense categories - creation, renaming, archive/unarchive
/// lifecycle, monthly limits, per-category totals, translations, and merge
/// map (shared-categories / linked-devices-and-sync). Split out of
/// `LedgerRepository` (architecture-deepening design.md D1); a leaf with
/// no dependency on any other repository.
class CategoryRepository {
  CategoryRepository({
    required AppDatabase database,
    AccountChartReader? chart,
    MetadataOutbox? metadataOutbox,
    Future<String?> Function()? currentIdentityId,
  }) : _db = database,
       _chart = chart ?? AccountChartReader(database),
       _outbox = metadataOutbox,
       _currentIdentityId = currentIdentityId;

  final AppDatabase _db;
  final AccountChartReader _chart;
  final MetadataOutbox? _outbox;
  final Future<String?> Function()? _currentIdentityId;

  /// Categories for pickers ([includeArchived] false, the default) or
  /// historical views ([includeArchived] true). Allowlist: income/expense
  /// only — never liability/equity/asset. Absorbed (merged) categories are
  /// omitted unless [includeMerged] is true.
  Stream<List<Account>> watchCategories({
    bool includeArchived = false,
    bool includeMerged = false,
  }) {
    if (includeMerged) {
      return _chart.watchCategories(includeArchived: includeArchived);
    }
    return _chart.watchCategories(includeArchived: includeArchived).asyncMap((
      categories,
    ) async {
      final absorbed = await _absorbedCategoryIds();
      return [
        for (final c in categories)
          if (!absorbed.contains(c.id)) c,
      ];
    });
  }

  /// [type] must be [AccountType.income] or [AccountType.expense].
  Future<void> addCategory({
    required String name,
    required AccountType type,
  }) async {
    if (type != AccountType.income && type != AccountType.expense) {
      throw ArgumentError.value(type, 'type', 'must be income or expense');
    }
    await _db.transaction(() async {
      final created = await _db
          .into(_db.accounts)
          .insertReturning(AccountsCompanion.insert(name: name, type: type));
      await _emit(
        entityType: 'category',
        entityId: created.id,
        field: 'type',
        value: type.name,
      );
      await _emit(
        entityType: 'category',
        entityId: created.id,
        field: 'name',
        value: name,
      );
    });
    await applyAutomaticMerges();
  }

  Future<void> renameCategory({
    required String id,
    required String newName,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
        AccountsCompanion(name: Value(newName)),
      );
      await _emit(
        entityType: 'category',
        entityId: id,
        field: 'name',
        value: newName,
      );
    });
    await applyAutomaticMerges();
  }

  Future<void> archiveCategory(String id) async {
    final at = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
        AccountsCompanion(archivedAt: Value(at)),
      );
      await _emit(
        entityType: 'category',
        entityId: id,
        field: 'archivedAt',
        value: at.toIso8601String(),
      );
    });
  }

  /// Restores an archived income or expense category to active status
  /// (unarchive-accounts-categories spec: "Unarchive Income or Expense
  /// Category").
  Future<void> unarchiveCategory(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
        const AccountsCompanion(archivedAt: Value(null)),
      );
      await _emit(
        entityType: 'category',
        entityId: id,
        field: 'archivedAt',
        value: null,
      );
    });
  }

  /// Sets or clears (`null`) an Expense category's optional monthly
  /// spending limit (spec: "Category Management" - "An Income category
  /// SHALL NOT have a monthly limit"). Informational only - never
  /// enforced against posting (monthly-category-limits design.md
  /// Decision 3).
  Future<void> setCategoryMonthlyLimit({
    required String id,
    required int? monthlyLimitMinor,
  }) async {
    if (monthlyLimitMinor != null) {
      if (monthlyLimitMinor <= 0) {
        throw InvalidTransactionAmountException(
          'Monthly limit must be positive and non-zero, got $monthlyLimitMinor.',
          code: AppErrorCode.monthlyLimitMustBePositive,
        );
      }
      final row = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(id))).getSingleOrNull();
      if (row == null || row.type != AccountType.expense) {
        throw ArgumentError.value(
          id,
          'id',
          'must be an Expense category to set a monthly limit',
        );
      }
    }
    await _db.transaction(() async {
      await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
        AccountsCompanion(monthlyLimitMinor: Value(monthlyLimitMinor)),
      );
      await _emit(
        entityType: 'category',
        entityId: id,
        field: 'monthlyLimitMinor',
        value: monthlyLimitMinor,
      );
    });
  }

  /// Books-level default language for category names (design Decision 8 / 9).
  Future<String> defaultCategoryLocale() async {
    final row = await (_db.select(
      _db.booksSetMetadata,
    )..limit(1)).getSingleOrNull();
    return row?.defaultCategoryLocale ?? 'en';
  }

  Future<void> setDefaultCategoryLocale(String locale) async {
    final normalized = normalizeLocaleTag(locale);
    final row = await (_db.select(
      _db.booksSetMetadata,
    )..limit(1)).getSingleOrNull();
    if (row == null) {
      throw StateError(
        'Books set metadata is missing; cannot set default category locale.',
      );
    }
    await _db.transaction(() async {
      await (_db.update(
        _db.booksSetMetadata,
      )..where((t) => t.id.equals(row.id))).write(
        BooksSetMetadataCompanion(defaultCategoryLocale: Value(normalized)),
      );
      await _emit(
        entityType: 'settings',
        entityId: 'books',
        field: 'defaultCategoryLocale',
        value: normalized,
      );
    });
  }

  /// Upserts a translation for [categoryId] in [locale]. Returns a suggested
  /// merge when the new text matches another category of the same type.
  Future<CategoryMergeCandidate?> setTranslation({
    required String categoryId,
    required String locale,
    required String name,
    DateTime? updatedAt,
  }) async {
    final normalizedLocale = normalizeLocaleTag(locale);
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must be non-empty');
    }
    final category = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(categoryId))).getSingleOrNull();
    if (category == null ||
        (category.type != AccountType.income &&
            category.type != AccountType.expense)) {
      throw ArgumentError.value(categoryId, 'categoryId', 'must be a category');
    }
    final when = updatedAt ?? DateTime.now();
    await _db.transaction(() async {
      await _db
          .into(_db.categoryTranslations)
          .insertOnConflictUpdate(
            CategoryTranslationsCompanion.insert(
              categoryId: categoryId,
              locale: normalizedLocale,
              name: trimmed,
              updatedAt: when,
            ),
          );
      await _emit(
        entityType: 'category_translation',
        entityId: categoryId,
        field: normalizedLocale,
        value: trimmed,
      );
    });

    final suggestion = await _suggestMergeForNewTranslation(
      categoryId: categoryId,
      type: category.type,
      translation: trimmed,
    );
    await applyAutomaticMerges();
    return suggestion;
  }

  Future<List<CategoryTranslation>> listTranslations(String categoryId) async {
    final rows = await (_db.select(
      _db.categoryTranslations,
    )..where((t) => t.categoryId.equals(categoryId))).get();
    rows.sort((a, b) => a.locale.compareTo(b.locale));
    return [
      for (final row in rows)
        CategoryTranslation(
          categoryId: row.categoryId,
          locale: row.locale,
          name: row.name,
          updatedAt: row.updatedAt,
        ),
    ];
  }

  Future<void> deleteTranslation({
    required String categoryId,
    required String locale,
  }) async {
    final normalized = normalizeLocaleTag(locale);
    await (_db.delete(_db.categoryTranslations)..where(
          (t) => t.categoryId.equals(categoryId) & t.locale.equals(normalized),
        ))
        .go();
  }

  /// Display name for [category] preferring [appLocale] translation, else
  /// the stored default-language name.
  Future<String> displayNameFor(
    Account category, {
    required String appLocale,
  }) async {
    final translations = await listTranslations(category.id);
    return resolveCategoryDisplayName(
      defaultName: category.name,
      appLocale: appLocale,
      translationsByLocale: {for (final t in translations) t.locale: t.name},
    );
  }

  /// Synchronous helper when translations are already loaded.
  String displayNameFromMaps({
    required String defaultName,
    required String appLocale,
    required Map<String, String> translationsByLocale,
  }) {
    return resolveCategoryDisplayName(
      defaultName: defaultName,
      appLocale: appLocale,
      translationsByLocale: translationsByLocale,
    );
  }

  /// Maps absorbed category ids → survivor (postings keep original ids).
  Future<Map<String, String>> mergeMap() async {
    final rows = await _db.select(_db.categoryMergeMap).get();
    return {
      for (final row in rows) row.absorbedCategoryId: row.survivorCategoryId,
    };
  }

  /// Manual merge: lists/totals treat [absorbedCategoryId] as [survivorCategoryId];
  /// posting rows are not rewritten (entry hashes stay valid).
  Future<void> mergeCategories({
    required String survivorCategoryId,
    required String absorbedCategoryId,
    DateTime? mergedAt,
  }) async {
    if (survivorCategoryId == absorbedCategoryId) {
      throw ArgumentError('Cannot merge a category into itself.');
    }
    final survivor = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(survivorCategoryId))).getSingleOrNull();
    final absorbed = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(absorbedCategoryId))).getSingleOrNull();
    if (survivor == null || absorbed == null) {
      throw ArgumentError('Both categories must exist to merge.');
    }
    if (survivor.type != absorbed.type) {
      throw ArgumentError('Merged categories must share the same type.');
    }
    if (survivor.type != AccountType.income &&
        survivor.type != AccountType.expense) {
      throw ArgumentError('Only income/expense categories can be merged.');
    }

    final when = mergedAt ?? DateTime.now();
    final resolvedSurvivor = resolveSurvivorCategoryId(
      survivorCategoryId,
      await mergeMap(),
    );
    await _db
        .into(_db.categoryMergeMap)
        .insertOnConflictUpdate(
          CategoryMergeMapCompanion.insert(
            absorbedCategoryId: absorbedCategoryId,
            survivorCategoryId: resolvedSurvivor,
            mergedAt: when,
          ),
        );
    // Move translations from absorbed → survivor when locale is free.
    final absorbedTranslations = await listTranslations(absorbedCategoryId);
    final survivorTranslations = await listTranslations(resolvedSurvivor);
    final survivorLocales = {for (final t in survivorTranslations) t.locale};
    for (final t in absorbedTranslations) {
      if (survivorLocales.contains(t.locale)) continue;
      await _db
          .into(_db.categoryTranslations)
          .insertOnConflictUpdate(
            CategoryTranslationsCompanion.insert(
              categoryId: resolvedSurvivor,
              locale: t.locale,
              name: t.name,
              updatedAt: t.updatedAt,
            ),
          );
    }
  }

  /// Applies automatic same-name+type merges across languages.
  Future<List<CategoryMergeCandidate>> applyAutomaticMerges() async {
    final catalog = await _buildCatalog();
    final candidates = findAutomaticMerges(catalog);
    final applied = <CategoryMergeCandidate>[];
    final existing = await mergeMap();
    for (final candidate in candidates) {
      if (existing.containsKey(candidate.absorbedId)) continue;
      if (resolveSurvivorCategoryId(candidate.absorbedId, existing) ==
          resolveSurvivorCategoryId(candidate.survivorId, existing)) {
        continue;
      }
      await mergeCategories(
        survivorCategoryId: candidate.survivorId,
        absorbedCategoryId: candidate.absorbedId,
      );
      applied.add(candidate);
      existing[candidate.absorbedId] = candidate.survivorId;
    }
    return applied;
  }

  /// Suggested merges when a translation matches another category's name.
  Future<List<CategoryMergeCandidate>> suggestedMerges() async {
    final catalog = await _buildCatalog();
    final suggestions = <CategoryMergeCandidate>[];
    final existing = await mergeMap();
    for (final entry in catalog) {
      if (existing.containsKey(entry.id)) continue;
      for (final name in entry.translatedNames) {
        final suggestion = suggestMergeForTranslation(
          categoryId: entry.id,
          type: entry.type,
          newTranslation: name,
          others: catalog,
        );
        if (suggestion == null || suggestion.automatic) continue;
        if (existing.containsKey(suggestion.absorbedId)) continue;
        suggestions.add(suggestion);
      }
    }
    // Deduplicate by pair.
    final seen = <String>{};
    return [
      for (final s in suggestions)
        if (seen.add('${s.survivorId}|${s.absorbedId}')) s,
    ];
  }

  /// Per-category totals within a date range. Totals for absorbed categories
  /// roll up into the survivor (UI/totals use the merge map; postings keep
  /// original account ids so entry hashes still verify).
  Stream<List<CategoryTotal>> watchCategoryTotals({
    required DateTime start,
    required DateTime end,
  }) {
    final startDate = dateOnly(start);
    final endDate = dateOnly(end);

    final query =
        _db.select(_db.postings).join([
          innerJoin(
            _db.journalEntries,
            _db.journalEntries.id.equalsExp(_db.postings.entryId),
          ),
          innerJoin(
            _db.accounts,
            _db.accounts.id.equalsExp(_db.postings.accountId),
          ),
          leftOuterJoin(
            _db.entryVerificationCache,
            _db.entryVerificationCache.entryId.equalsExp(_db.postings.entryId),
          ),
        ])..where(
          _db.journalEntries.transactionDate.isBiggerOrEqualValue(startDate) &
              _db.journalEntries.transactionDate.isSmallerOrEqualValue(endDate),
        );

    return query.watch().asyncMap((rows) async {
      final map = await mergeMap();
      final survivorNames = <String, String>{};
      final lines = <SummaryPostingLine>[];
      for (final row in rows) {
        final entry = row.readTable(_db.journalEntries);
        final account = row.readTable(_db.accounts);
        final posting = row.readTable(_db.postings);
        final verification = row.readTableOrNull(_db.entryVerificationCache);
        final survivorId = resolveSurvivorCategoryId(account.id, map);
        if (!survivorNames.containsKey(survivorId)) {
          if (survivorId == account.id) {
            survivorNames[survivorId] = account.name;
          } else {
            final survivor = await (_db.select(
              _db.accounts,
            )..where((a) => a.id.equals(survivorId))).getSingleOrNull();
            survivorNames[survivorId] = survivor?.name ?? account.name;
          }
        }
        lines.add(
          SummaryPostingLine(
            entryId: entry.id,
            migratedFromEntryId: entry.migratedFromEntryId,
            isQuarantined: verification != null && !verification.isVerified,
            accountId: survivorId,
            accountName: survivorNames[survivorId]!,
            accountType: account.type,
            amountMinor: posting.amountMinor,
          ),
        );
      }
      return buildCategoryTotals(lines);
    });
  }

  Future<Set<String>> _absorbedCategoryIds() async {
    final rows = await _db.select(_db.categoryMergeMap).get();
    return {for (final row in rows) row.absorbedCategoryId};
  }

  Future<List<CategoryNameCatalogEntry>> _buildCatalog() async {
    final categories = await _chart
        .watchCategories(includeArchived: true)
        .first;
    final translations = await _db.select(_db.categoryTranslations).get();
    final byCategory = <String, List<String>>{};
    for (final t in translations) {
      byCategory.putIfAbsent(t.categoryId, () => []).add(t.name);
    }
    final absorbed = await _absorbedCategoryIds();
    return [
      for (final c in categories)
        if (!absorbed.contains(c.id))
          CategoryNameCatalogEntry(
            id: c.id,
            type: c.type,
            defaultName: c.name,
            translatedNames: byCategory[c.id] ?? const [],
          ),
    ];
  }

  Future<CategoryMergeCandidate?> _suggestMergeForNewTranslation({
    required String categoryId,
    required AccountType type,
    required String translation,
  }) async {
    final catalog = await _buildCatalog();
    return suggestMergeForTranslation(
      categoryId: categoryId,
      type: type,
      newTranslation: translation,
      others: catalog,
    );
  }

  Future<void> _emit({
    required String entityType,
    required String entityId,
    required String field,
    required Object? value,
  }) async {
    final outbox = _outbox;
    final identityFn = _currentIdentityId;
    if (outbox == null || identityFn == null) return;
    final identityId = await identityFn();
    if (identityId == null || identityId.isEmpty) return;
    await outbox.emit(
      entityType: entityType,
      entityId: entityId,
      field: field,
      value: value,
      updatedByIdentityId: identityId,
    );
  }
}
