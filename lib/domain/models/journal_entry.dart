import '../../data/database/tables/entry_verification_cache_table.dart'
    show VerificationBreakReason;
import 'posting.dart';

export '../../data/database/tables/entry_verification_cache_table.dart'
    show VerificationBreakReason;

/// A posted, immutable double-entry journal entry and its postings. Once
/// posted, no code path updates or deletes this row or its postings
/// (Golden Rule #7) - corrections are a new entry referencing this one via
/// [reversesEntryId].
///
/// [isVerified] and [breakReason] are a snapshot of the derived
/// `entry_verification_cache` at query time, not part of this entry's
/// immutable identity (design.md: "verification results are derived data,
/// never part of the immutable truth") - they can change across app
/// restarts as the chain is re-walked, while every other field here never
/// changes once posted.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.transactionDate,
    required this.recordedAt,
    required this.description,
    required this.reversesEntryId,
    required this.postings,
    required this.deviceChainSequence,
    required this.entryHash,
    required this.signedByIdentityId,
    required this.signature,
    required this.migratedFromEntryId,
    required this.isVerified,
    required this.breakReason,
    required this.isSupersededByMigration,
  });

  final String id;
  final DateTime transactionDate;
  final DateTime recordedAt;
  final String? description;
  final String? reversesEntryId;
  final List<Posting> postings;
  final int deviceChainSequence;
  final List<int> entryHash;
  final String signedByIdentityId;
  final List<int> signature;
  final String? migratedFromEntryId;
  final bool isVerified;
  final VerificationBreakReason? breakReason;

  /// True when a later true-key-loss migration re-created this entry's
  /// content under a new identity (spec: "Legacy entries remain visible
  /// but excluded from active balances"). Independent of [isVerified] - a
  /// superseded entry may still cryptographically verify fine under its
  /// original identity's chain; it's excluded from active totals because
  /// a newer, migrated entry now represents it, not because it's broken.
  final bool isSupersededByMigration;
}
