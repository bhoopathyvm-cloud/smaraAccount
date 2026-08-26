import 'integrity_event_type.dart';

export 'integrity_event_type.dart';

/// Domain-facing view of an `integrity_events` row - the append-only audit
/// log of chain breaks, re-anchors, and key migrations (design.md).
class IntegrityEvent {
  const IntegrityEvent({
    required this.eventId,
    required this.eventType,
    required this.occurredAt,
    required this.relatedEntryId,
    required this.relatedIdentityId,
    required this.detail,
  });

  final String eventId;
  final IntegrityEventType eventType;
  final DateTime occurredAt;
  final String? relatedEntryId;
  final String? relatedIdentityId;
  final String? detail;
}
