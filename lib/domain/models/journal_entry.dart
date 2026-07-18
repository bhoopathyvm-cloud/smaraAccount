import 'posting.dart';

/// A posted, immutable double-entry journal entry and its postings. Once
/// posted, no code path updates or deletes this row or its postings
/// (Golden Rule #7) - corrections are a new entry referencing this one via
/// [reversesEntryId].
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.transactionDate,
    required this.recordedAt,
    required this.description,
    required this.reversesEntryId,
    required this.postings,
  });

  final String id;
  final DateTime transactionDate;
  final DateTime recordedAt;
  final String? description;
  final String? reversesEntryId;
  final List<Posting> postings;
}
