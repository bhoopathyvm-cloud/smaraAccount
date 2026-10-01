/// Pure visibility rules for the Home "Save a copy of your books" banner
/// (books-copy-and-continuation / backup-reminder).
class BackupReminderPolicy {
  const BackupReminderPolicy._();

  /// Whether the Home reminder banner should show.
  ///
  /// [lastCopySavedAt] / [entryCountAtLastCopy] reset when a copy is saved.
  /// When no copy has ever been saved, [firstEntryAt] is the day baseline
  /// and [entryCountAtLastCopy] is treated as zero.
  /// While snoozed, the banner stays hidden until [snoozeUntil] or
  /// [snoozeEntries] new entries since [entryCountAtSnooze], whichever
  /// comes first — then it shows again without re-checking the main
  /// thresholds (the reminder had already fired).
  static bool shouldShow({
    required bool enabled,
    required DateTime now,
    required int currentEntryCount,
    DateTime? lastCopySavedAt,
    int entryCountAtLastCopy = 0,
    DateTime? firstEntryAt,
    DateTime? snoozeUntil,
    int? entryCountAtSnooze,
    int reminderDays = 30,
    int reminderEntries = 500,
    int snoozeEntries = 500,
  }) {
    if (!enabled) return false;

    if (snoozeUntil != null && entryCountAtSnooze != null) {
      final snoozeTimeElapsed = !now.isBefore(snoozeUntil);
      final snoozeEntriesElapsed =
          currentEntryCount - entryCountAtSnooze >= snoozeEntries;
      if (!snoozeTimeElapsed && !snoozeEntriesElapsed) {
        return false;
      }
      return true;
    }

    final dayBaseline = lastCopySavedAt ?? firstEntryAt;
    if (dayBaseline == null && currentEntryCount == 0) {
      return false;
    }

    if (dayBaseline != null &&
        now.difference(dayBaseline).inDays >= reminderDays) {
      return true;
    }

    final entriesSinceCopy = currentEntryCount - entryCountAtLastCopy;
    if (entriesSinceCopy >= reminderEntries) {
      return true;
    }

    return false;
  }
}
