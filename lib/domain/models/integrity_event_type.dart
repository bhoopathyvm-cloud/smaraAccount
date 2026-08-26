/// Append-only audit log event kinds for breaks and migrations.
enum IntegrityEventType {
  chainBreakDetected,
  chainReanchored,
  keyMigrationConfirmed,
}
