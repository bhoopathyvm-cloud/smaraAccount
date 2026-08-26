import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/recurring_template.dart';
import '../../domain/models/transaction_direction.dart';
import '../database/app_database.dart';
import 'ledger_repository.dart';

/// Recurring templates and one-tap recording of a due template. Split
/// out of `LedgerRepository` (architecture-deepening design.md D1).
/// [recordDueTemplate] posts through [LedgerRepository.recordTransaction].
class RecurringTemplateRepository {
  RecurringTemplateRepository({
    required AppDatabase database,
    required LedgerRepository ledgerRepository,
  }) : _db = database,
       _ledgerRepository = ledgerRepository;

  final AppDatabase _db;
  final LedgerRepository _ledgerRepository;

  Stream<List<RecurringTemplate>> watchRecurringTemplates() {
    final query = _db.select(_db.recurringTemplates)
      ..orderBy([(t) => OrderingTerm.asc(t.dayOfMonth)]);
    return query.watch().map(
      (rows) => rows.map(_toDomainRecurringTemplate).toList(),
    );
  }

  /// Templates due today or overdue this month (see `isTemplateDue`),
  /// joined with the account/category names Home needs to display them -
  /// mirrors [watchHomeOverview]'s precedent of resolving names in the
  /// repository layer, not the ViewModel.
  Stream<List<DueRecurringTemplate>> watchDueRecurringTemplates() {
    return watchRecurringTemplates().asyncMap((templates) async {
      final today = DateTime.now();
      final due = templates.where((t) => isTemplateDue(t, today)).toList();
      if (due.isEmpty) return const <DueRecurringTemplate>[];

      final accounts = await _db.select(_db.accounts).get();
      final accountsById = {for (final a in accounts) a.id: a};
      final groups = await _db.select(_db.accountGroups).get();
      final currencyByGroupId = {for (final g in groups) g.id: g.currency};

      return [
        for (final template in due)
          DueRecurringTemplate(
            template: template,
            financialAccountName:
                accountsById[template.financialAccountId]?.name ??
                'Unknown account',
            categoryName:
                accountsById[template.categoryId]?.name ?? 'Unknown category',
            currency:
                currencyByGroupId[accountsById[template.financialAccountId]
                    ?.groupId] ??
                'USD',
          ),
      ];
    });
  }

  Future<RecurringTemplate> createRecurringTemplate({
    required String name,
    required TransactionDirection direction,
    required String financialAccountId,
    required String categoryId,
    required int amountMinor,
    required int dayOfMonth,
  }) async {
    _validateRecurringTemplateFields(
      amountMinor: amountMinor,
      dayOfMonth: dayOfMonth,
    );
    final row = await _db
        .into(_db.recurringTemplates)
        .insertReturning(
          RecurringTemplatesCompanion.insert(
            name: name,
            direction: direction,
            financialAccountId: financialAccountId,
            categoryId: categoryId,
            amountMinor: amountMinor,
            dayOfMonth: dayOfMonth,
            createdAt: DateTime.now(),
          ),
        );
    return _toDomainRecurringTemplate(row);
  }

  Future<void> updateRecurringTemplate({
    required String id,
    required String name,
    required TransactionDirection direction,
    required String financialAccountId,
    required String categoryId,
    required int amountMinor,
    required int dayOfMonth,
  }) async {
    _validateRecurringTemplateFields(
      amountMinor: amountMinor,
      dayOfMonth: dayOfMonth,
    );
    await (_db.update(
      _db.recurringTemplates,
    )..where((t) => t.id.equals(id))).write(
      RecurringTemplatesCompanion(
        name: Value(name),
        direction: Value(direction),
        financialAccountId: Value(financialAccountId),
        categoryId: Value(categoryId),
        amountMinor: Value(amountMinor),
        dayOfMonth: Value(dayOfMonth),
      ),
    );
  }

  Future<void> deleteRecurringTemplate(String id) async {
    await (_db.delete(
      _db.recurringTemplates,
    )..where((t) => t.id.equals(id))).go();
  }

  /// Posts [templateId]'s due transaction via [recordTransaction] - the
  /// exact same path a manual entry takes - then stamps it recorded for
  /// this calendar month so it stops being offered as due (spec:
  /// "surface due templates for one-tap recording without auto-posting").
  Future<String> recordDueTemplate(String templateId) async {
    final row = await (_db.select(
      _db.recurringTemplates,
    )..where((t) => t.id.equals(templateId))).getSingle();
    final template = _toDomainRecurringTemplate(row);
    final now = DateTime.now();

    return _db.transaction(() async {
      final entryId = await _ledgerRepository.recordTransaction(
        amountMinor: template.amountMinor,
        direction: template.direction,
        categoryId: template.categoryId,
        financialAccountId: template.financialAccountId,
        transactionDate: now,
        description: template.name,
      );

      await (_db.update(
        _db.recurringTemplates,
      )..where((t) => t.id.equals(templateId))).write(
        RecurringTemplatesCompanion(
          lastRecordedYearMonth: Value(yearMonthOf(now)),
        ),
      );
      return entryId;
    });
  }

  void _validateRecurringTemplateFields({
    required int amountMinor,
    required int dayOfMonth,
  }) {
    if (amountMinor <= 0) {
      throw InvalidTransactionAmountException(
        'Template amount must be positive and non-zero, got $amountMinor.',
        code: AppErrorCode.templateAmountMustBePositive,
      );
    }
    if (dayOfMonth < 1 || dayOfMonth > 31) {
      throw ArgumentError.value(
        dayOfMonth,
        'dayOfMonth',
        'must be between 1 and 31',
      );
    }
  }

  RecurringTemplate _toDomainRecurringTemplate(RecurringTemplateRow row) {
    return RecurringTemplate(
      id: row.id,
      name: row.name,
      direction: row.direction,
      financialAccountId: row.financialAccountId,
      categoryId: row.categoryId,
      amountMinor: row.amountMinor,
      dayOfMonth: row.dayOfMonth,
      lastRecordedYearMonth: row.lastRecordedYearMonth,
    );
  }
}
