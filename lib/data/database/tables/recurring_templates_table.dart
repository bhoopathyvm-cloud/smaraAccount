import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/transaction_direction.dart';

/// A recurring transaction template (recurring-templates design.md
/// Decisions): no FK-enforced relationship beyond the referenced
/// account/category ids - recording it just calls the same
/// `recordTransaction` path a manual entry would.
@DataClassName('RecurringTemplateRow')
class RecurringTemplates extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get name => text()();

  TextColumn get direction => textEnum<TransactionDirection>()();

  TextColumn get financialAccountId => text()();

  TextColumn get categoryId => text()();

  IntColumn get amountMinor => integer()();

  /// 1-31, clamped to a given month's actual last day when applied (see
  /// `effectiveDayOfMonth` in the domain model).
  IntColumn get dayOfMonth => integer()();

  /// 'YYYY-MM' of the last calendar month this template was recorded in.
  TextColumn get lastRecordedYearMonth => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
