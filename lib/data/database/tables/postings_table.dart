import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'accounts_table.dart';
import 'journal_entries_table.dart';

/// Every journal entry has exactly two postings whose [amountMinor] values
/// sum to zero (design.md: "Signed-amount postings instead of explicit
/// debit/credit columns"). Postings are immutable along with their entry.
///
/// Named PostingRow (not the Drift default "Posting") to stay distinct
/// from domain/models/posting.dart's Posting.
@DataClassName('PostingRow')
class Postings extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get entryId => text().references(JournalEntries, #id)();

  TextColumn get accountId => text().references(Accounts, #id)();

  /// Signed minor-unit amount (e.g. cents). Recording money in sets the
  /// asset posting to +amount and the income-category posting to -amount;
  /// money out is the reverse.
  IntColumn get amountMinor => integer()();

  IntColumn get lineNumber => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
