import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/crypto/entry_canonical_hash.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../../domain/models/membership_notice.dart';
import '../../domain/peer_sync/competing_fix_resolver.dart';
import '../../domain/peer_sync/metadata_lww.dart';
import '../../domain/peer_sync/peer_sync_session.dart';
import '../../domain/peer_sync/sync_payloads.dart';
import '../../domain/peer_sync/sync_settings_allowlist.dart';
import '../database/app_database.dart';
import 'ledger_chain_store.dart';
import 'ledger_posting.dart';
import 'repository_date_utils.dart';

/// Result of applying a peer [EntryBatch] (task 6.1–6.3).
class SyncMergeResult {
  const SyncMergeResult({
    required this.insertedCount,
    required this.skippedDuplicateCount,
    required this.rejectedCount,
    required this.competingFixCancellations,
  });

  final int insertedCount;
  final int skippedDuplicateCount;
  final int rejectedCount;
  final int competingFixCancellations;
}

/// Inserts peer-signed journal rows and applies MetadataOps without editing
/// existing entries (peer-sync design Decisions 3 / 7 / 9; tasks 6.1–6.5).
///
/// Leaf deps only: [AppDatabase], [SigningKeyService], [LedgerChainStore],
/// optional [LedgerPosting] for cancel records — no Identity/Account cycle.
class SyncMergeRepository implements SyncLedgerView {
  SyncMergeRepository({
    required AppDatabase database,
    required SigningKeyService signingKeyService,
    LedgerChainStore? chain,
    LedgerPosting? posting,
    DateTime Function()? clock,
    Uuid? uuid,
    this.localDeviceDisplayName = 'This device',
  }) : _db = database,
       _keys = signingKeyService,
       _chain = chain ?? LedgerChainStore(database),
       _posting = posting,
       _clock = clock ?? DateTime.now,
       _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SigningKeyService _keys;
  final LedgerChainStore _chain;
  final LedgerPosting? _posting;
  final DateTime Function() _clock;
  final Uuid _uuid;
  final String localDeviceDisplayName;

  final _lww = const MetadataLww();
  final _fixResolver = const CompetingFixResolver();

  /// In-memory metadata field state for LWW tests / sync apply.
  final Map<String, MetadataOperation> metadataState = {};

  /// Applied books settings from MetadataOps (device keys never land here).
  final Map<String, Object?> appliedBooksSettings = {};

  @override
  Future<Map<String, int>> nextSequenceByIdentity() async {
    final tips = await _db.select(_db.ledgerIdentityChainTips).get();
    if (tips.isNotEmpty) {
      return {
        for (final tip in tips) tip.identityId: tip.nextDeviceChainSequence,
      };
    }
    // Fall back to scanning entries when tips are empty.
    final entries = await _db.select(_db.journalEntries).get();
    final result = <String, int>{};
    for (final e in entries) {
      final next = e.deviceChainSequence + 1;
      final existing = result[e.signedByIdentityId] ?? 1;
      if (next > existing) result[e.signedByIdentityId] = next;
    }
    return result;
  }

  @override
  Future<List<SyncJournalEntry>> entriesFrom({
    required String identityId,
    required int minSequence,
  }) async {
    final rows =
        await (_db.select(_db.journalEntries)
              ..where(
                (e) =>
                    e.signedByIdentityId.equals(identityId) &
                    e.deviceChainSequence.isBiggerOrEqualValue(minSequence),
              )
              ..orderBy([(e) => OrderingTerm.asc(e.deviceChainSequence)]))
            .get();
    final result = <SyncJournalEntry>[];
    for (final row in rows) {
      final postings = await (_db.select(
        _db.postings,
      )..where((p) => p.entryId.equals(row.id))).get();
      result.add(
        SyncJournalEntry(
          id: row.id,
          transactionDate: row.transactionDate,
          recordedAt: row.recordedAt,
          description: row.description,
          reversesEntryId: row.reversesEntryId,
          deviceChainSequence: row.deviceChainSequence,
          previousEntryHash: row.previousEntryHash,
          entryHash: row.entryHash,
          signedByIdentityId: row.signedByIdentityId,
          signature: row.signature,
          migratedFromEntryId: row.migratedFromEntryId,
          postings: postings
              .map(
                (p) => SyncPosting(
                  accountId: p.accountId,
                  amountMinor: p.amountMinor,
                  lineNumber: p.lineNumber,
                ),
              )
              .toList(),
        ),
      );
    }
    return result;
  }

  @override
  Future<int> applyEntryBatch(
    EntryBatch batch, {
    required String fromDeviceId,
  }) async {
    final result = await mergeEntryBatch(
      batch,
      fromDeviceId: fromDeviceId,
      fromDeviceDisplayName: fromDeviceId,
    );
    return result.insertedCount;
  }

  /// Inserts peer-signed rows (never edits existing). Skips duplicates by
  /// identity + `deviceChainSequence`. Rejects unverifiable entries with a
  /// notice. Resolves competing Fixes after inserts.
  Future<SyncMergeResult> mergeEntryBatch(
    EntryBatch batch, {
    required String fromDeviceId,
    required String fromDeviceDisplayName,
    bool emitOwnerAlert = true,
  }) async {
    var inserted = 0;
    var skipped = 0;
    var rejected = 0;

    for (final entry in batch.entries) {
      final duplicate = await _findDuplicate(
        identityId: entry.signedByIdentityId,
        sequence: entry.deviceChainSequence,
      );
      if (duplicate != null) {
        skipped++;
        continue;
      }

      final existingById = await (_db.select(
        _db.journalEntries,
      )..where((e) => e.id.equals(entry.id))).getSingleOrNull();
      if (existingById != null) {
        skipped++;
        continue;
      }

      final ok = await _verifyPeerEntry(entry);
      if (!ok) {
        rejected++;
        await _recordNotAcceptedNotice(
          fromDeviceId: fromDeviceId,
          fromDeviceDisplayName: fromDeviceDisplayName,
        );
        if (emitOwnerAlert) {
          await _recordOwnerAlert(
            fromDeviceId: fromDeviceId,
            fromDeviceDisplayName: fromDeviceDisplayName,
          );
        }
        continue;
      }

      await _insertPeerEntry(entry);
      inserted++;
    }

    final cancellations = await _resolveCompetingFixes();

    return SyncMergeResult(
      insertedCount: inserted,
      skippedDuplicateCount: skipped,
      rejectedCount: rejected,
      competingFixCancellations: cancellations,
    );
  }

  /// Applies MetadataOps with per-field LWW. Settings ops only apply when the
  /// field is a books setting (task 6.5).
  Future<List<MetadataOperation>> applyMetadataOps(MetadataOps ops) async {
    final filtered = <MetadataOperation>[];
    for (final op in ops.operations) {
      if (op.entityType == 'settings') {
        if (!SyncSettingsAllowlist.isBooksSetting(op.field)) {
          continue;
        }
        appliedBooksSettings[op.field] = op.value;
      }
      filtered.add(op);
    }

    final merged = _lww.merge([...metadataState.values, ...filtered]);
    metadataState
      ..clear()
      ..addEntries(merged.map((o) => MapEntry(MetadataLww.fieldKey(o), o)));
    return merged;
  }

  Future<JournalEntryRow?> _findDuplicate({
    required String identityId,
    required int sequence,
  }) {
    return (_db.select(_db.journalEntries)..where(
          (e) =>
              e.signedByIdentityId.equals(identityId) &
              e.deviceChainSequence.equals(sequence),
        ))
        .getSingleOrNull();
  }

  Future<bool> _verifyPeerEntry(SyncJournalEntry entry) async {
    final identity =
        await (_db.select(_db.signingIdentities)
              ..where((t) => t.identityId.equals(entry.signedByIdentityId)))
            .getSingleOrNull();
    if (identity == null) return false;

    final prior =
        await (_db.select(_db.journalEntries)
              ..where(
                (e) =>
                    e.signedByIdentityId.equals(entry.signedByIdentityId) &
                    e.deviceChainSequence.isSmallerThanValue(
                      entry.deviceChainSequence,
                    ),
              )
              ..orderBy([(e) => OrderingTerm.desc(e.deviceChainSequence)])
              ..limit(1))
            .getSingleOrNull();

    final expectedPrevious = prior == null
        ? Uint8List.fromList(genesisPreviousEntryHash)
        : Uint8List.fromList(prior.entryHash);
    if (!_bytesEqual(entry.previousEntryHash, expectedPrevious)) {
      return false;
    }

    final canonical = canonicalEntryBytes(
      previousEntryHash: entry.previousEntryHash,
      id: entry.id,
      deviceChainSequence: entry.deviceChainSequence,
      transactionDate: entry.transactionDate,
      recordedAt: entry.recordedAt,
      description: entry.description,
      reversesEntryId: entry.reversesEntryId,
      signedByIdentityId: entry.signedByIdentityId,
      postings: entry.postings
          .map(
            (p) => CanonicalPosting(
              lineNumber: p.lineNumber,
              accountId: p.accountId,
              amountMinor: p.amountMinor,
            ),
          )
          .toList(),
    );
    final recomputed = await hashCanonicalEntry(canonical);
    if (!_bytesEqual(recomputed, entry.entryHash)) return false;

    return _keys.verify(
      entry.entryHash,
      signature: entry.signature,
      publicKey: identity.publicKey,
    );
  }

  Future<void> _insertPeerEntry(SyncJournalEntry entry) async {
    await _db.transaction(() async {
      await _db
          .into(_db.journalEntries)
          .insert(
            JournalEntriesCompanion.insert(
              id: Value(entry.id),
              transactionDate: entry.transactionDate,
              recordedAt: truncateToStoredPrecision(entry.recordedAt),
              description: Value(entry.description),
              reversesEntryId: Value(entry.reversesEntryId),
              deviceChainSequence: entry.deviceChainSequence,
              previousEntryHash: Uint8List.fromList(entry.previousEntryHash),
              entryHash: Uint8List.fromList(entry.entryHash),
              signedByIdentityId: entry.signedByIdentityId,
              signature: Uint8List.fromList(entry.signature),
              migratedFromEntryId: Value(entry.migratedFromEntryId),
            ),
          );
      for (final p in entry.postings) {
        await _db
            .into(_db.postings)
            .insert(
              PostingsCompanion.insert(
                entryId: entry.id,
                accountId: p.accountId,
                amountMinor: p.amountMinor,
                lineNumber: p.lineNumber,
              ),
            );
      }
      await _chain.upsertVerificationCache(
        entryId: entry.id,
        isVerified: true,
        breakReason: null,
      );
      await _chain.updateIdentityTip(
        identityId: entry.signedByIdentityId,
        trustedTipEntryId: entry.id,
        trustedTipHash: Uint8List.fromList(entry.entryHash),
        nextDeviceChainSequence: entry.deviceChainSequence + 1,
      );
    });
  }

  Future<int> _resolveCompetingFixes() async {
    final reversals = await (_db.select(
      _db.journalEntries,
    )..where((e) => e.reversesEntryId.isNotNull())).get();
    if (reversals.isEmpty) return 0;

    // Exclude Fix reversals that have already been cancelled (an entry
    // exists with reversesEntryId pointing at them).
    final alreadyReversedIds = <String>{
      for (final r in reversals) r.reversesEntryId!,
    };

    final active = reversals
        .where((r) => !alreadyReversedIds.contains(r.id))
        .map(
          (r) => CompetingFixCandidate(
            entryId: r.id,
            reversesEntryId: r.reversesEntryId!,
            recordedAt: r.recordedAt,
            signedByIdentityId: r.signedByIdentityId,
          ),
        );

    final resolutions = _fixResolver.resolve(active);
    var cancellations = 0;
    for (final resolution in resolutions) {
      for (final loser in resolution.losers) {
        final posting = _posting;
        if (posting != null) {
          await posting.reverseEntry(loser.entryId);
        } else {
          // Tests without a posting engine still record the notice.
        }
        await _recordCompetingFixNotice(
          winnerEntryId: resolution.winner.entryId,
          loserEntryId: loser.entryId,
        );
        cancellations++;
      }
    }
    return cancellations;
  }

  Future<void> _recordNotAcceptedNotice({
    required String fromDeviceId,
    required String fromDeviceDisplayName,
  }) {
    return _insertNotice(
      kind: MembershipNoticeKind.entryNotAccepted,
      relatedDeviceId: fromDeviceId,
      relatedDisplayName: fromDeviceDisplayName,
      detail:
          'Not accepted: couldn\'t be verified (from $fromDeviceDisplayName)',
    );
  }

  Future<void> _recordOwnerAlert({
    required String fromDeviceId,
    required String fromDeviceDisplayName,
  }) {
    return _insertNotice(
      kind: MembershipNoticeKind.ownerVerificationAlert,
      relatedDeviceId: fromDeviceId,
      relatedDisplayName: fromDeviceDisplayName,
      detail:
          'An entry from $fromDeviceDisplayName could not be verified and '
          'was not accepted.',
    );
  }

  Future<void> _recordCompetingFixNotice({
    required String winnerEntryId,
    required String loserEntryId,
  }) {
    return _insertNotice(
      kind: MembershipNoticeKind.competingFixCheck,
      detail:
          'Two Fixes competed; kept $winnerEntryId and cancelled '
          '$loserEntryId. Please check.',
    );
  }

  Future<void> _insertNotice({
    required MembershipNoticeKind kind,
    String? relatedDeviceId,
    String? relatedDisplayName,
    String? detail,
  }) {
    return _db
        .into(_db.membershipNotices)
        .insert(
          MembershipNoticesCompanion.insert(
            noticeId: _uuid.v4(),
            kind: kind,
            createdAt: Value(_clock()),
            relatedDeviceId: Value(relatedDeviceId),
            relatedDisplayName: Value(relatedDisplayName),
            detail: Value(detail),
          ),
        );
  }

  bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
