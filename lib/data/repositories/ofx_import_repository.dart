import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/journal_entry.dart';
import '../../domain/ofx/ofx_import_batch.dart';
import '../../domain/ofx/ofx_parser.dart';
import '../../domain/ofx/parsed_ofx_transaction.dart';
import '../database/app_database.dart';
import 'ledger_repository.dart';

/// Repository for the OFX import flow (ofx-transaction-import): parsing a
/// file, matching it to a financial account, duplicate detection,
/// category suggestion, and posting the reviewed batch. Delegates every
/// actual posting to [LedgerRepository.recordTransaction] unmodified
/// (design.md Decision 5) - this class only adds the import-specific
/// bookkeeping around that call.
class OfxImportRepository {
  OfxImportRepository({
    required AppDatabase database,
    required LedgerRepository ledgerRepository,
  }) : _db = database,
       _ledgerRepository = ledgerRepository;

  final AppDatabase _db;
  final LedgerRepository _ledgerRepository;

  /// Throws [OfxParseException] (via [parseOfxDocument]) when the file
  /// isn't recognizable as OFX at all.
  OfxParseResult parseFile(List<int> bytes) {
    final content = utf8.decode(bytes, allowMalformed: true);
    return parseOfxDocument(content);
  }

  /// The account's group currency, for comparing against a parsed file's
  /// `statementCurrency` (design.md Decision 3: mismatch is a warning, not
  /// a block).
  Future<String?> groupCurrencyFor(String financialAccountId) async {
    final accounts = await _ledgerRepository
        .watchFinancialAccounts(includeArchived: true)
        .first;
    final account = accounts.firstWhere((a) => a.id == financialAccountId);
    final groups = await _ledgerRepository
        .watchAccountGroups(includeArchived: true)
        .first;
    final group = groups.firstWhere((g) => g.id == account.groupId);
    return group.currency;
  }

  /// Returns the positions (indexes into [transactions]) of rows that
  /// match a previously imported row for [financialAccountId] - by
  /// `fitid` when the row has one, otherwise by [ParsedOfxTransaction.
  /// fallbackMatchKey]. The preview screen uses this to default those rows
  /// to excluded from posting.
  Future<Set<int>> findDuplicateIndexes({
    required String financialAccountId,
    required List<ParsedOfxTransaction> transactions,
  }) async {
    final fitids = transactions.map((t) => t.fitid).whereType<String>().toSet();
    final fallbackKeys = transactions.map((t) => t.fallbackMatchKey).toSet();

    final query = _db.select(_db.ofxImportRecords)
      ..where(
        (r) =>
            r.financialAccountId.equals(financialAccountId) &
            (r.fitid.isIn(fitids) | r.fallbackMatchKey.isIn(fallbackKeys)),
      );
    final existing = await query.get();

    final existingFitids = existing
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
      final isDuplicate = transaction.fitid != null
          ? existingFitids.contains(transaction.fitid)
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
  /// one at a time, and records its `fitid`/fallback match key for future
  /// duplicate detection. A row's posting failure is captured in its
  /// result and does not stop the remaining rows from posting
  /// (design.md Decision 5).
  Future<OfxImportBatchResult> postAcceptedRows({
    required String financialAccountId,
    required List<OfxAcceptedRow> rows,
  }) async {
    final results = <OfxPostedRow>[];
    for (final row in rows) {
      try {
        // Threading the row's own statement currency through as
        // nativeCurrency is what makes recordTransaction apply
        // multi-account-ledger's existing foreign-currency handling
        // (immediate same-currency post, or a provisional entry pending
        // settlement) exactly as it would for a manually entered
        // transaction - this repository never re-implements that
        // decision itself (design.md Decision 3).
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
                fitid: Value(row.transaction.fitid),
                fallbackMatchKey: Value(
                  row.transaction.fitid == null
                      ? row.transaction.fallbackMatchKey
                      : null,
                ),
                journalEntryId: postedEntryId,
                importedAt: DateTime.now(),
              ),
            );
        results.add(OfxPostedRow(transaction: row.transaction));
      } catch (error) {
        results.add(
          OfxPostedRow(transaction: row.transaction, error: error.toString()),
        );
      }
    }
    return OfxImportBatchResult(results: results);
  }
}
