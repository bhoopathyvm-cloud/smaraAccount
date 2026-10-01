/// Append-only audit log event kinds for breaks and continuations.
enum IntegrityEventType {
  chainBreakDetected,
  chainReanchored,
  keyMigrationConfirmed,
  identityContinued,
}
