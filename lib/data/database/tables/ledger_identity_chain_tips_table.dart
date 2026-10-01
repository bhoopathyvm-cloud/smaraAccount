import 'package:drift/drift.dart';

import 'journal_entries_table.dart';
import 'signing_identities_table.dart';

/// Per-identity trusted tip and next sequence for multi-chain verification
/// (linked-devices-and-sync design Decision 3).
///
/// The singleton [LedgerChainState] row remains the local write tip used by
/// existing posting code until multi-chain wiring (tasks 3.x) migrates reads
/// onto this table. Both coexist during the transition.
@DataClassName('IdentityChainTipRow')
class LedgerIdentityChainTips extends Table {
  TextColumn get identityId =>
      text().references(SigningIdentities, #identityId)();

  TextColumn get trustedTipEntryId =>
      text().nullable().references(JournalEntries, #id)();

  BlobColumn get trustedTipHash => blob().nullable()();

  IntColumn get nextDeviceChainSequence => integer()();

  @override
  Set<Column> get primaryKey => {identityId};
}
