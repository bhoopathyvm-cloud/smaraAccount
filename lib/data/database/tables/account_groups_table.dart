import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Kind of an [AccountGroups] row — asset rollups vs liability rollups.
enum AccountGroupKind { assetGroup, liabilityGroup }

/// Stable well-known ids for the four seeded system groups (design.md).
const groupCashEquivalentsId = 'group_cash_equivalents';
const groupPensionRetirementId = 'group_pension_retirement';
const groupCreditShortTermId = 'group_credit_short_term';
const groupLoansMortgagesId = 'group_loans_mortgages';

@DataClassName('AccountGroupRow')
class AccountGroups extends Table {
  /// A user-created group has no well-known constant id, so it needs a
  /// client-generated default, matching `Accounts.id`'s existing
  /// convention - the four system-group seeds are unaffected since they
  /// always pass an explicit id, which overrides this default.
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<AccountGroupKind>()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isSystem => boolean()();

  /// ISO 4217 code (e.g. 'USD', 'EUR') - a group is single-currency
  /// (multi-currency-support design.md Decision 1). Nullable only to
  /// represent the transient post-upgrade state for a database migrated
  /// from schemaVersion 3, before the user has supplied the one-time
  /// currency-backfill value; every group created through the Repository
  /// (fresh install or backfill) always has this set.
  TextColumn get currency => text().nullable()();

  /// Set only for a user-created group the user has archived (soft flag,
  /// matching `accounts.archived_at`'s shape) - never set for one of the
  /// four system groups, which are permanent and un-archivable
  /// (custom-account-groups design.md Decision 2).
  DateTimeColumn get archivedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
