import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/pending_transfer_kind.dart';
import 'accounts_table.dart';
import 'journal_entries_table.dart';

export '../../../domain/models/pending_transfer_kind.dart';

/// Tracks the two-phase provisional/settled lifecycle for a cross-currency
/// transfer or foreign-currency transaction whose final amount wasn't
/// known at record time. Not a ledger fact in its own right - a lightweight
/// index over which immutable [JournalEntries] rows belong together and
/// whether the second half has happened yet (design.md Decision 4).
///
/// Named PendingTransferRow (not the Drift default) to stay distinct from
/// domain/models/pending_transfer.dart's PendingTransfer.
@DataClassName('PendingTransferRow')
class PendingTransfers extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get kind => textEnum<PendingTransferKind>()();

  TextColumn get sourceAccountId => text().references(Accounts, #id)();

  /// Set only when [kind] is [PendingTransferKind.foreignTransaction].
  TextColumn get categoryId => text().nullable().references(Accounts, #id)();

  /// Planned destination; set only when [kind] is
  /// [PendingTransferKind.transfer] - a foreign-currency transaction has no
  /// natural "to" account the way a transfer does.
  TextColumn get destinationAccountId =>
      text().nullable().references(Accounts, #id)();

  /// The currency the provisional entry's clearing leg was actually posted
  /// in - the source account's own group currency for a `transfer`, or the
  /// transaction's native currency for a `foreignTransaction` (which can
  /// differ from the financial account's own currency - the whole reason
  /// this pending item exists). Snapshotted at creation time since neither
  /// value is otherwise recoverable later (categories aren't group-scoped
  /// and carry no currency of their own).
  TextColumn get currency => text()();

  TextColumn get provisionalEntryId => text().references(JournalEntries, #id)();

  TextColumn get status => textEnum<PendingTransferStatus>()();

  TextColumn get settlementEntryId =>
      text().nullable().references(JournalEntries, #id)();
  TextColumn get feeEntryId =>
      text().nullable().references(JournalEntries, #id)();

  DateTimeColumn get initiatedAt => dateTime()();
  DateTimeColumn get settledAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
