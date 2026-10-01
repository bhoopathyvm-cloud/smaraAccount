import 'package:smara_accounting/domain/backup/backup_reminder_policy.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime.utc(2026, 6, 1);

  group('BackupReminderPolicy.shouldShow', () {
    test('thirty days without a copy', () {
      expect(
        BackupReminderPolicy.shouldShow(
          enabled: true,
          now: now,
          currentEntryCount: 10,
          lastCopySavedAt: DateTime.utc(2026, 5, 1),
          entryCountAtLastCopy: 10,
        ),
        isTrue,
      );
    });

    test('uses first entry date when no copy was ever saved', () {
      expect(
        BackupReminderPolicy.shouldShow(
          enabled: true,
          now: now,
          currentEntryCount: 3,
          firstEntryAt: DateTime.utc(2026, 5, 1),
        ),
        isTrue,
      );
    });

    test('five hundred new entries without a copy', () {
      expect(
        BackupReminderPolicy.shouldShow(
          enabled: true,
          now: now,
          currentEntryCount: 500,
          lastCopySavedAt: DateTime.utc(2026, 5, 20),
          entryCountAtLastCopy: 0,
        ),
        isTrue,
      );
    });

    test('below both thresholds stays hidden', () {
      expect(
        BackupReminderPolicy.shouldShow(
          enabled: true,
          now: now,
          currentEntryCount: 10,
          lastCopySavedAt: DateTime.utc(2026, 5, 20),
          entryCountAtLastCopy: 5,
        ),
        isFalse,
      );
    });

    test('disabled never shows', () {
      expect(
        BackupReminderPolicy.shouldShow(
          enabled: false,
          now: now,
          currentEntryCount: 1000,
          lastCopySavedAt: DateTime.utc(2020, 1, 1),
        ),
        isFalse,
      );
    });

    test('custom day limit', () {
      expect(
        BackupReminderPolicy.shouldShow(
          enabled: true,
          now: now,
          currentEntryCount: 1,
          lastCopySavedAt: DateTime.utc(2026, 5, 17),
          reminderDays: 14,
        ),
        isTrue,
      );
    });

    test('snooze hides until seven days', () {
      expect(
        BackupReminderPolicy.shouldShow(
          enabled: true,
          now: now,
          currentEntryCount: 10,
          lastCopySavedAt: DateTime.utc(2026, 1, 1),
          snoozeUntil: DateTime.utc(2026, 6, 8),
          entryCountAtSnooze: 10,
          snoozeEntries: 500,
        ),
        isFalse,
      );
      expect(
        BackupReminderPolicy.shouldShow(
          enabled: true,
          now: DateTime.utc(2026, 6, 8),
          currentEntryCount: 10,
          lastCopySavedAt: DateTime.utc(2026, 1, 1),
          snoozeUntil: DateTime.utc(2026, 6, 8),
          entryCountAtSnooze: 10,
          snoozeEntries: 500,
        ),
        isTrue,
      );
    });

    test('snooze ends after five hundred new entries', () {
      expect(
        BackupReminderPolicy.shouldShow(
          enabled: true,
          now: now,
          currentEntryCount: 510,
          lastCopySavedAt: DateTime.utc(2026, 1, 1),
          snoozeUntil: DateTime.utc(2026, 6, 8),
          entryCountAtSnooze: 10,
          snoozeEntries: 500,
        ),
        isTrue,
      );
    });

    test('empty books never show', () {
      expect(
        BackupReminderPolicy.shouldShow(
          enabled: true,
          now: now,
          currentEntryCount: 0,
        ),
        isFalse,
      );
    });
  });
}
