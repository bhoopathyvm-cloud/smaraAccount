## Purpose

Gently remind people to save a copy of their books, by time or by usage, since a saved copy is now the only way to recover books from a lost or broken device.

## ADDED Requirements

### Requirement: Reminder Appears by Time or Usage
The Home screen SHALL show a banner "Save a copy of your books" with "Save a copy" and "Later" when no copy has been saved for the configured number of days (default 30) or the configured number of new entries (default 500) has been recorded since the last copy, whichever comes first. When no copy was ever saved, the count starts from the first entry. Saving a copy SHALL reset both the day count and the entry count.

#### Scenario: Thirty days without a copy
- **WHEN** 30 days have passed since the last copy was saved (or since the first entry, if none) with the default settings
- **THEN** the banner is shown on Home

#### Scenario: Five hundred new entries without a copy
- **WHEN** 500 entries have been recorded since the last copy, for example through one large bank-statement import, with the default settings
- **THEN** the banner is shown on Home even if fewer than 30 days have passed

#### Scenario: Saving a copy clears the banner
- **WHEN** the user saves a copy from the banner or from Settings
- **THEN** the banner disappears and both counts start again

### Requirement: Later Snoozes by Time or Usage
Tapping "Later" SHALL hide the banner until the configured snooze days (default 7) have passed or the configured snooze entries (default 500) have been recorded, whichever comes first.

#### Scenario: Banner returns after seven days
- **WHEN** the user taps "Later" and 7 days pass with the default settings and still no copy
- **THEN** the banner is shown again

#### Scenario: Banner returns after five hundred entries
- **WHEN** the user taps "Later" and 500 new entries are recorded before 7 days pass
- **THEN** the banner is shown again

### Requirement: Reminder Is Configurable and Can Be Turned Off
Settings SHALL let the user change the reminder's days and entries limits, change the snooze days and entries, and turn the reminder off entirely. The reminder SHALL be on by default with 30 days or 500 entries, and a snooze of 7 days or 500 entries.

#### Scenario: Turning the reminder off
- **WHEN** the user turns the reminder off in Settings
- **THEN** the banner never appears until the user turns it on again

#### Scenario: Changing the limits
- **WHEN** the user sets the reminder to 14 days
- **THEN** the banner appears after 14 days without a copy instead of 30
