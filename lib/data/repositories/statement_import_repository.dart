import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/csv/csv_column_mapping.dart';
import '../../domain/csv/csv_import_profile.dart';
import '../../domain/csv/csv_parser.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/ofx/ofx_parser.dart';
import '../../domain/statement_import/category_rule.dart';
import '../../domain/statement_import/parsed_statement_transaction.dart';
import '../../domain/statement_import/statement_import_batch.dart';
import '../database/app_database.dart';
import '../database/tables/ofx_import_records_table.dart' show ImportSource;
import 'account_repository.dart';
import 'ledger_repository.dart';

/// Repository for the statement import flow (ofx-transaction-import,
/// csv-transaction-import): parsing a file, matching it to a financial
/// account, duplicate detection, category suggestion, and posting the
/// reviewed batch. Delegates every actual posting to
/// [LedgerRepository.recordTransaction] unmodified (ofx-transaction-import
/// design.md Decision 5) - this class only adds the import-specific
/// bookkeeping around that call. OFX and CSV rows both flow through the
/// same review/dedupe/categorize/post methods here; only parsing differs
/// per source (csv-transaction-import design.md Decision 4).
class StatementImportRepository {
  StatementImportRepository({
    required AppDatabase database,
    required LedgerRepository ledgerRepository,
    required AccountRepository accountRepository,
  }) : _db = database,
       _ledgerRepository = ledgerRepository,
       _accountRepository = accountRepository;

  final AppDatabase _db;
  final LedgerRepository _ledgerRepository;
  final AccountRepository _accountRepository;

  /// Throws [OfxParseException] (via [parseOfxDocument]) when the file
  /// isn't recognizable as OFX at all.
  StatementParseResult parseOfxFile(List<int> bytes) {
    final content = utf8.decode(bytes, allowMalformed: true);
    return parseOfxDocument(content);
  }

  /// Throws [CsvParseException] (via [parseCsvDocument]) when the file
  /// can't be read as delimited CSV data at all.
  StatementParseResult parseCsvFile(List<int> bytes, CsvColumnMapping mapping) {
    return parseCsvDocument(bytes, mapping);
  }

  /// The account's group currency, for comparing against a parsed file's
  /// `statementCurrency` (ofx-transaction-import design.md Decision 3:
  /// mismatch is a warning, not a block).
  Future<String?> groupCurrencyFor(String financialAccountId) async {
    final accounts = await _accountRepository
        .watchFinancialAccounts(includeArchived: true)
        .first;
    final account = accounts.firstWhere((a) => a.id == financialAccountId);
    final groups = await _accountRepository
        .watchAccountGroups(includeArchived: true)
        .first;
    final group = groups.firstWhere((g) => g.id == account.groupId);
    return group.currency;
  }

  /// Returns the positions (indexes into [transactions]) of rows that
  /// match a previously imported row for [financialAccountId] - by
  /// [ParsedStatementTransaction.externalReferenceId] when the row has
  /// one, otherwise by [ParsedStatementTransaction.fallbackMatchKey]. The
  /// preview screen uses this to default those rows to excluded from
  /// posting.
  Future<Set<int>> findDuplicateIndexes({
    required String financialAccountId,
    required List<ParsedStatementTransaction> transactions,
  }) async {
    final referenceIds = transactions
        .map((t) => t.externalReferenceId)
        .whereType<String>()
        .toSet();
    final fallbackKeys = transactions.map((t) => t.fallbackMatchKey).toSet();

    final query = _db.select(_db.ofxImportRecords)
      ..where(
        (r) =>
            r.financialAccountId.equals(financialAccountId) &
            (r.fitid.isIn(referenceIds) |
                r.fallbackMatchKey.isIn(fallbackKeys)),
      );
    final existing = await query.get();

    final existingReferenceIds = existing
        .map((r) => r.fitid)
        .whereType<String>()
        .toSet();
    final existingFallbackKeys = existing
        .map((r) => r.fallbackMatchKey)
        .whereType<String>()
        .toSet();

    final duplicateIndexes = <int>{};
    for (var i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      final isDuplicate = transaction.externalReferenceId != null
          ? existingReferenceIds.contains(transaction.externalReferenceId)
          : existingFallbackKeys.contains(transaction.fallbackMatchKey);
      if (isDuplicate) duplicateIndexes.add(i);
    }
    return duplicateIndexes;
  }

  /// The category most recently posted (by device-chain order, not
  /// transaction date, so backdated statement rows don't skew "most
  /// recent") against an entry whose description exactly matches
  /// [description] for [financialAccountId], if any.
  Future<String?> suggestCategoryFor({
    required String financialAccountId,
    required String description,
  }) async {
    if (description.isEmpty) return null;

    final entries = await _ledgerRepository
        .watchEntriesForAccount(financialAccountId)
        .first;
    final categoryIds =
        (await _ledgerRepository.watchCategories(includeArchived: true).first)
            .map((c) => c.id)
            .toSet();

    JournalEntry? mostRecentMatch;
    for (final entry in entries) {
      if (entry.description != description) continue;
      if (mostRecentMatch == null ||
          entry.deviceChainSequence > mostRecentMatch.deviceChainSequence) {
        mostRecentMatch = entry;
      }
    }
    if (mostRecentMatch == null) return null;

    for (final posting in mostRecentMatch.postings) {
      if (posting.accountId != financialAccountId &&
          categoryIds.contains(posting.accountId)) {
        return posting.accountId;
      }
    }
    return null;
  }

  /// Posts each accepted row through [LedgerRepository.recordTransaction],
  /// one at a time, and records its external reference id / fallback match
  /// key for future duplicate detection. A row's posting failure is
  /// captured in its result and does not stop the remaining rows from
  /// posting (ofx-transaction-import design.md Decision 5).
  Future<StatementImportBatchResult> postAcceptedRows({
    required String financialAccountId,
    required List<StatementAcceptedRow> rows,
    required ImportSource source,
  }) async {
    final results = <StatementPostedRow>[];
    for (final row in rows) {
      try {
        // Threading the row's own statement currency through as
        // nativeCurrency is what makes recordTransaction apply
        // multi-account-ledger's existing foreign-currency handling
        // (immediate same-currency post, or a provisional entry pending
        // settlement) exactly as it would for a manually entered
        // transaction - this repository never re-implements that
        // decision itself (ofx-transaction-import design.md Decision 3).
        final currency = row.transaction.currency;
        final postedEntryId = await _ledgerRepository.recordTransaction(
          amountMinor: row.transaction.amountMinor,
          direction: row.transaction.direction,
          categoryId: row.categoryId,
          financialAccountId: financialAccountId,
          transactionDate: row.transaction.transactionDate,
          description: row.transaction.description,
          nativeCurrency: currency.isEmpty ? null : currency,
        );
        await _db
            .into(_db.ofxImportRecords)
            .insert(
              OfxImportRecordsCompanion.insert(
                financialAccountId: financialAccountId,
                fitid: Value(row.transaction.externalReferenceId),
                fallbackMatchKey: Value(
                  row.transaction.externalReferenceId == null
                      ? row.transaction.fallbackMatchKey
                      : null,
                ),
                journalEntryId: postedEntryId,
                importedAt: DateTime.now(),
                source: Value(source),
              ),
            );
        results.add(StatementPostedRow(transaction: row.transaction));
      } catch (error) {
        results.add(
          StatementPostedRow(
            transaction: row.transaction,
            error: error.toString(),
          ),
        );
      }
    }
    return StatementImportBatchResult(results: results);
  }

  /// Saves a completed column mapping as a named, reusable profile,
  /// fingerprinted by the source file's (normalized) header row
  /// (design.md Decision 6).
  Future<void> saveProfile({
    required String name,
    required CsvColumnMapping mapping,
    required List<String> headerRow,
  }) async {
    await _db
        .into(_db.csvImportProfiles)
        .insert(
          CsvImportProfilesCompanion.insert(
            name: name,
            headerFingerprint: jsonEncode(normalizeHeaderRow(headerRow)),
            columnMapping: mapping.toJsonString(),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// The saved profile whose header fingerprint exactly matches
  /// [headerRow] (after normalization), if any - offered as the default
  /// mapping for a file whose header row matches. No match found means no
  /// profile is auto-selected; every saved profile remains manually
  /// choosable via [watchProfiles] regardless (design.md Decision 6: exact
  /// match only, fails safe rather than guessing).
  Future<CsvImportProfile?> findProfileForHeaderRow(
    List<String> headerRow,
  ) async {
    final normalized = normalizeHeaderRow(headerRow);
    final rows = await _db.select(_db.csvImportProfiles).get();
    for (final row in rows) {
      final fingerprint = (jsonDecode(row.headerFingerprint) as List)
          .cast<String>();
      if (_listEquals(fingerprint, normalized)) {
        return _toDomainProfile(row);
      }
    }
    return null;
  }

  Stream<List<CsvImportProfile>> watchProfiles() {
    final query = _db.select(_db.csvImportProfiles)
      ..orderBy([(p) => OrderingTerm.asc(p.name)]);
    return query.watch().map((rows) => rows.map(_toDomainProfile).toList());
  }

  Future<void> renameProfile({
    required String id,
    required String newName,
  }) async {
    await (_db.update(_db.csvImportProfiles)..where((p) => p.id.equals(id)))
        .write(CsvImportProfilesCompanion(name: Value(newName)));
  }

  Future<void> deleteProfile(String id) async {
    await (_db.delete(
      _db.csvImportProfiles,
    )..where((p) => p.id.equals(id))).go();
  }

  CsvImportProfile _toDomainProfile(CsvImportProfileRow row) {
    return CsvImportProfile(
      id: row.id,
      name: row.name,
      headerFingerprint: (jsonDecode(row.headerFingerprint) as List)
          .cast<String>(),
      mapping: csvColumnMappingFromJsonString(row.columnMapping),
      createdAt: row.createdAt,
    );
  }

  /// Saves a keyword-to-category rule, applied across every financial
  /// account (import-category-rules design.md: "Per-account rule scoping"
  /// is a Non-Goal).
  Future<void> saveCategoryRule({
    required String keyword,
    required String categoryId,
  }) async {
    await _db
        .into(_db.categoryRules)
        .insert(
          CategoryRulesCompanion.insert(
            keyword: keyword,
            categoryId: categoryId,
            createdAt: DateTime.now(),
          ),
        );
  }

  Stream<List<CategoryRule>> watchCategoryRules() {
    final query = _db.select(_db.categoryRules)
      ..orderBy([(r) => OrderingTerm.asc(r.keyword)]);
    return query.watch().map(
      (rows) => rows.map(_toDomainCategoryRule).toList(),
    );
  }

  Future<void> updateCategoryRule({
    required String id,
    required String keyword,
    required String categoryId,
  }) async {
    await (_db.update(_db.categoryRules)..where((r) => r.id.equals(id))).write(
      CategoryRulesCompanion(
        keyword: Value(keyword),
        categoryId: Value(categoryId),
      ),
    );
  }

  Future<void> deleteCategoryRule(String id) async {
    await (_db.delete(_db.categoryRules)..where((r) => r.id.equals(id))).go();
  }

  CategoryRule _toDomainCategoryRule(CategoryRuleRow row) {
    return CategoryRule(
      id: row.id,
      keyword: row.keyword,
      categoryId: row.categoryId,
      createdAt: row.createdAt,
    );
  }
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
