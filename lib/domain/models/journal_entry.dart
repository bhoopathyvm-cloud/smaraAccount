import 'posting.dart';

/// A posted, immutable double-entry journal entry and its postings. Once
/// posted, no code path updates or deletes this row or its postings
/// (Golden Rule #7) - corrections are a new entry referencing this one via
/// [reversesEntryId].
class JournalEntry({
  required final String id,
  required final DateTime transactionDate,
  required final DateTime recordedAt,
  required final String? description,
  required final String? reversesEntryId,
  required final List<Posting> postings,
});
