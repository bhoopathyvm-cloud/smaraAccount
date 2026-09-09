import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/crypto/entry_canonical_hash.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../../domain/models/integrity_event.dart';
import '../database/app_database.dart';
import 'ledger_chain_store.dart';
import 'repository_date_utils.dart';

/// True key-loss migration algorithm: supersede the current Signing
/// Identity, generate a new one, and re-canonicalize / re-sign every active
/// Journal Entry under it on a fresh hash chain (genesis root), while the
/// unique `device_chain_sequence` counter continues monotonically. Appends
/// a `KEY_MIGRATION_CONFIRMED` Integrity Event.
///
/// Extracted from `IdentityRepository` (architecture cycle 18) so this
/// ~130-line disaster-recovery algorithm has one owned home, matching the
/// data-layer engine pattern of `LedgerPosting` / `LedgerChainVerifier`.
/// Takes only leaves (`AppDatabase`, `LedgerChainStore`,
/// `SigningKeyService`), so it stays below `IdentityRepository` and closes
/// no construction cycle (ADR 0002). `IdentityRepository` constructs one and
/// delegates its public `migrateToNewIdentityAfterKeyLoss`.
class KeyLossMigrationEngine {
  KeyLossMigrationEngine({
    required AppDatabase database,
    required LedgerChainStore chain,
    SigningKeyService? signingKeyService,
  }) : _db = database,
       _chain = chain,
       _signingKeyService = signingKeyService ?? SigningKeyService();

  final AppDatabase _db;
  final LedgerChainStore _chain;
  final SigningKeyService _signingKeyService;

  Future<GeneratedIdentity> migrate() async {
    final previousIdentity = await _chain.currentSigningIdentity();
    final generated = await _signingKeyService.generateNewIdentity();

    await _db.transaction(() async {
      final newIdentityRow = await _db
          .into(_db.signingIdentities)
          .insertReturning(
            SigningIdentitiesCompanion.insert(
              publicKey: Uint8List.fromList(generated.keyMaterial.publicKey),
              supersedesIdentityId: Value(previousIdentity?.identityId),
              // This migration flow has its own explicit "I confirm the
              // current ledger is valid" acknowledgment (spec: "True
              // Key-Loss Migration") and never shows a new recovery
              // phrase to re-acknowledge - mark it acknowledged
              // immediately so the router doesn't also send the user
              // through deferred-onboarding-first-entry's acknowledgment
              // screens for a phrase this flow never generated.
              acknowledgedAt: Value(DateTime.now()),
            ),
          );

      if (previousIdentity != null) {
        await (_db.update(_db.signingIdentities)
              ..where((t) => t.identityId.equals(previousIdentity.identityId)))
            .write(
              SigningIdentitiesCompanion(supersededAt: Value(DateTime.now())),
            );
      }

      final activeEntries = await _activeEntriesForMigration();
      // device_chain_sequence is UNIQUE across the whole table (design.md),
      // not scoped per identity - legacy entries keep their old sequence
      // numbers forever, so a migration continues the *same* monotonic
      // counter rather than restarting at 0. Only the hash chain itself
      // (previousHash below) resets to genesis: that's the actual fresh
      // trust root a migration establishes.
      final priorChainState = await _chain.loadState();
      var sequence = priorChainState.nextDeviceChainSequence;
      Uint8List previousHash = Uint8List.fromList(genesisPreviousEntryHash);
      String? lastInsertedId;

      for (final legacy in activeEntries) {
        final legacyPostings = await (_db.select(
          _db.postings,
        )..where((p) => p.entryId.equals(legacy.id))).get();

        final newId = const Uuid().v4();
        final recordedAt = truncateToStoredPrecision(DateTime.now());
        final canonicalPostings = legacyPostings
            .map(
              (p) => CanonicalPosting(
                lineNumber: p.lineNumber,
                accountId: p.accountId,
                amountMinor: p.amountMinor,
              ),
            )
            .toList();

        final bytes = canonicalEntryBytes(
          previousEntryHash: previousHash,
          id: newId,
          deviceChainSequence: sequence,
          transactionDate: legacy.transactionDate,
          recordedAt: recordedAt,
          description: legacy.description,
          reversesEntryId: legacy.reversesEntryId,
          signedByIdentityId: newIdentityRow.identityId,
          postings: canonicalPostings,
        );
        final entryHash = await hashCanonicalEntry(bytes);
        final signature = await _signingKeyService.sign(entryHash);

        await _db
            .into(_db.journalEntries)
            .insert(
              JournalEntriesCompanion.insert(
                id: Value(newId),
                transactionDate: legacy.transactionDate,
                recordedAt: recordedAt,
                description: Value(legacy.description),
                reversesEntryId: Value(legacy.reversesEntryId),
                deviceChainSequence: sequence,
                previousEntryHash: previousHash,
                entryHash: entryHash,
                signedByIdentityId: newIdentityRow.identityId,
                signature: signature,
                migratedFromEntryId: Value(legacy.id),
              ),
            );

        for (final p in legacyPostings) {
          await _db
              .into(_db.postings)
              .insert(
                PostingsCompanion.insert(
                  entryId: newId,
                  accountId: p.accountId,
                  amountMinor: p.amountMinor,
                  lineNumber: p.lineNumber,
                ),
              );
        }

        await _chain.upsertVerificationCache(
          entryId: newId,
          isVerified: true,
          breakReason: null,
        );

        previousHash = entryHash;
        lastInsertedId = newId;
        sequence += 1;
      }

      await _chain.updateState(
        trustedTipEntryId: lastInsertedId,
        trustedTipHash: activeEntries.isEmpty ? null : previousHash,
        nextDeviceChainSequence: sequence,
      );

      await _db
          .into(_db.integrityEvents)
          .insert(
            IntegrityEventsCompanion.insert(
              eventType: IntegrityEventType.keyMigrationConfirmed,
              relatedIdentityId: Value(newIdentityRow.identityId),
              detail: Value(
                'Migrated ${activeEntries.length} entries to new identity '
                '${newIdentityRow.identityId} after confirmed key loss.',
              ),
            ),
          );
    });

    return generated;
  }

  /// Entries not already superseded by an earlier migration - the set
  /// re-created by [migrate].
  Future<List<JournalEntryRow>> _activeEntriesForMigration() async {
    final all = await (_db.select(
      _db.journalEntries,
    )..orderBy([(e) => OrderingTerm.asc(e.deviceChainSequence)])).get();
    final supersededIds = all
        .where((e) => e.migratedFromEntryId != null)
        .map((e) => e.migratedFromEntryId!)
        .toSet();
    return all.where((e) => !supersededIds.contains(e.id)).toList();
  }
}
