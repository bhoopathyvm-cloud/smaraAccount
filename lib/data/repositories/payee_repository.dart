import 'package:drift/drift.dart';

import '../../domain/models/payee.dart';
import '../../domain/statement_import/category_rule.dart'
    show normalizeDescription;
import '../database/app_database.dart';

/// Payees and spending memory (payees-and-spending-memory design.md
/// Decision 1). No FK/link column on journal_entries - a payee is matched
/// against a typed description at query time, not stored per-entry. Split
/// out of `LedgerRepository` (architecture-deepening design.md D1); a leaf
/// with no dependency on any other repository.
class PayeeRepository {
  PayeeRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  Stream<List<Payee>> watchPayees() {
    final query = _db.select(_db.payees)
      ..orderBy([(p) => OrderingTerm.asc(p.name)]);
    return query.watch().map((rows) => rows.map(_toDomainPayee).toList());
  }

  Future<Payee> createPayee({
    required String name,
    String? defaultCategoryId,
    String? defaultFinancialAccountId,
  }) async {
    final id = await _db
        .into(_db.payees)
        .insertReturning(
          PayeesCompanion.insert(
            name: name,
            defaultCategoryId: Value(defaultCategoryId),
            defaultFinancialAccountId: Value(defaultFinancialAccountId),
            createdAt: DateTime.now(),
          ),
        );
    return _toDomainPayee(id);
  }

  /// Links an existing payee whose normalized [name] matches, or creates
  /// one, updating its default category to [defaultCategoryId] either way
  /// (import-category-rules "Saving a rule offers to link a payee too"
  /// scenario: saving a rule always applies the rule's category as the
  /// linked payee's default, whether the payee already existed or not).
  Future<Payee> findOrCreatePayeeByName({
    required String name,
    String? defaultCategoryId,
  }) async {
    final normalized = normalizeDescription(name);
    final allPayees = await _db.select(_db.payees).get();
    final existing = allPayees.cast<PayeeRow?>().firstWhere(
      (p) => normalizeDescription(p!.name) == normalized,
      orElse: () => null,
    );
    if (existing != null) {
      if (defaultCategoryId != null) {
        await (_db.update(
          _db.payees,
        )..where((p) => p.id.equals(existing.id))).write(
          PayeesCompanion(defaultCategoryId: Value(defaultCategoryId)),
        );
      }
      return _toDomainPayee(existing);
    }
    return createPayee(name: name, defaultCategoryId: defaultCategoryId);
  }

  Future<void> renamePayee({required String id, required String newName}) {
    return (_db.update(_db.payees)..where((p) => p.id.equals(id))).write(
      PayeesCompanion(name: Value(newName)),
    );
  }

  Future<void> deletePayee(String id) async {
    await (_db.delete(_db.payees)..where((p) => p.id.equals(id))).go();
  }

  /// Updates [payeeId]'s remembered defaults to whatever was just used -
  /// called after a successful `LedgerRepository.recordTransaction` for a
  /// matched payee, so the next entry for the same payee suggests the most
  /// recent choice (design.md Decisions: defaults double as "last used").
  Future<void> recordPayeeUsage({
    required String payeeId,
    required String categoryId,
    required String financialAccountId,
  }) {
    return (_db.update(_db.payees)..where((p) => p.id.equals(payeeId))).write(
      PayeesCompanion(
        defaultCategoryId: Value(categoryId),
        defaultFinancialAccountId: Value(financialAccountId),
      ),
    );
  }

  Payee _toDomainPayee(PayeeRow row) {
    return Payee(
      id: row.id,
      name: row.name,
      defaultCategoryId: row.defaultCategoryId,
      defaultFinancialAccountId: row.defaultFinancialAccountId,
    );
  }
}
