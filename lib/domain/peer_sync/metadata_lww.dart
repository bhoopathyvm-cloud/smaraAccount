import 'sync_payloads.dart';
import 'hybrid_logical_clock.dart';

/// Last-write-wins per metadata field with hybrid logical clock ordering
/// (design Decision 5 / 7; tasks 5.2 / 6.4). Unrelated fields never overwrite
/// each other.
class MetadataLww {
  const MetadataLww();

  /// Field key used to keep ops independent: entityType|entityId|field.
  static String fieldKey(MetadataOperation op) =>
      '${op.entityType}|${op.entityId}|${op.field}';

  static HybridLogicalTimestamp stampOf(MetadataOperation op) =>
      HybridLogicalTimestamp(
        wall: op.updatedAt.toUtc(),
        counter: op.hlcCounter,
        // Keep empty hlcDeviceId as empty so wall+counter ties fall through to
        // the identity tie-break in [prefer]. Falling back to identity here
        // would order by HLC deviceId (lexicographically greater wins) and
        // contradict the lower-identity rule below.
        deviceId: op.hlcDeviceId,
      );

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
    final cmp = stampOf(candidate).compareTo(stampOf(incumbent));
    if (cmp != 0) return cmp > 0;
    // Final tie-break: lower identity id wins (deterministic).
    return candidate.updatedByIdentityId.compareTo(
          incumbent.updatedByIdentityId,
        ) <
        0;
  }
}
