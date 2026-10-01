import 'sync_payloads.dart';

/// Last-write-wins per metadata field with identity tie-break
/// (design Decision 7 / task 6.4). Unrelated fields never overwrite each other.
class MetadataLww {
  const MetadataLww();

  /// Field key used to keep ops independent: entityType|entityId|field.
  static String fieldKey(MetadataOperation op) =>
      '${op.entityType}|${op.entityId}|${op.field}';

  /// Returns the winning op for each distinct field among [operations].
  List<MetadataOperation> merge(Iterable<MetadataOperation> operations) {
    final winners = <String, MetadataOperation>{};
    for (final op in operations) {
      final key = fieldKey(op);
      final existing = winners[key];
      if (existing == null || prefer(op, existing)) {
        winners[key] = op;
      }
    }
    return winners.values.toList();
  }

  /// True when [candidate] should replace [incumbent].
  bool prefer(MetadataOperation candidate, MetadataOperation incumbent) {
    final byTime = candidate.updatedAt.compareTo(incumbent.updatedAt);
    if (byTime > 0) return true;
    if (byTime < 0) return false;
    // Tie-break: lower identity id wins (deterministic, not security).
    return candidate.updatedByIdentityId.compareTo(
          incumbent.updatedByIdentityId,
        ) <
        0;
  }
}
