# User Guide

SMARA Account is a local-first, double-entry accounting app. Everything
described here reflects the app as it currently exists — nothing in this
guide is a planned or proposed feature.

## Before anything else: your recovery phrase

**Read this before you finish setting up the app.**

Every device generates its own signing key, and every transaction you
record is signed with it. This is what makes the ledger tamper-evident —
there is no server and no account recovery. **If you lose this device and
your recovery phrase together, every transaction you've recorded becomes
permanently unverifiable.** There is no way for anyone, including the
app's author, to recover it for you.

You get two ways to protect against that:

- **Recovery phrase** (mandatory): a 24-word phrase generated on first
  launch. Write it down, in order, and store it somewhere safe and
  separate from this device. This alone is always enough to restore your
  signing key.
- **Keystore file** (optional): an additional, passphrase-encrypted backup
  file you can export during onboarding or skip entirely — your recovery
  phrase alone is sufficient without it.

If you ever lose both, the app still has an escape hatch (see
[True key loss](#true-key-loss) below), but it comes with a real
trade-off: everything recorded before that point can no longer be proven
untampered, only preserved as a read-only historical record.

## Onboarding

On first launch, the app walks you through four screens:

1. **Your recovery phrase** — the 24 words are generated and shown once.
   Tap "I've saved my recovery phrase" only once you've actually written
   them down.
2. **Optional backup file** — enter a passphrase to export an encrypted
   keystore file, or tap "Skip." Neither blocks you from continuing.
3. **Confirm** — you re-enter part of your phrase to confirm you actually
   saved it correctly, before it's committed.
4. **Currency** — pick your base currency. This becomes the currency of
   the two starter account groups (Cash & cash equivalents, Credit &
   short-term debt) created for you.

Nothing is written to the database until you complete confirmation — until
then, the ledger stays unusable by design.

## Restoring on a new device or after a reinstall

If you reinstall the app, or move to a new device, and the app detects an
existing ledger with no matching local signing key, it shows a **Restore
signing key** screen instead of onboarding. Choose either:

- **Recovery phrase** — paste all 24 words.
- **Keystore file** — paste the file's contents and the passphrase you set
  when exporting it.

Restoring only re-derives and matches your existing key — it never
re-signs or alters any entry.

### True key loss

If you don't have your recovery phrase or keystore file, tap "I don't have
my recovery phrase or keystore file" on the restore screen. You'll review
every existing entry and explicitly confirm the ledger looks correct, then
the app generates a brand-new key and re-signs everything under it. This
re-establishes trust **going forward only** — it does not retroactively
prove earlier entries were never tampered with. The original entries are
kept, unchanged, as a read-only historical record.

## Home

The Home tab (also where the gear icon opens **Settings**) shows:

- **Net position** — your overall balance per currency (assets minus
  liabilities), with the assets/liabilities breakdown underneath.
- **Pending transfers** — cross-currency transfers whose exchange rate
  wasn't known at the time, awaiting settlement. Tap one to settle it.
- **Account groups** — every account group with its accounts, tap an
  account to open its Register.

## Recording a transaction

From the Register screen's "+" button: pick the account, whether money is
coming in or going out, the amount, a category, the date, and an optional
description. If the transaction was in a different currency than the
account, you can enter that currency (and optionally the equivalent
account-currency amount — leave it blank to post provisionally and settle
the exchange rate later).

## Categories

The Categories tab lists every income and expense category. Tap "+" to add
one (name + Income/Expense), the pencil icon to rename one, or "Archive"
to retire one — archived categories stay visible on past transactions but
are no longer offered when recording new ones.

## Accounts and account groups

The Accounts tab manages your financial accounts (asset or liability) and
the groups they belong to.

- **Create an account**: name, Asset or Liability, which group, and an
  optional opening balance.
- **Create a group**: name, Asset or Liability, and a currency (ISO 4217,
  e.g. `USD`) — every account in a group shares that group's currency.
- **Rename** an account or edit a group's name/currency (currency can only
  change while the group has no active accounts, since changing it would
  retroactively reinterpret historical balances).
- **Reassign** an account to a different group of the same currency.
- **Archive** an account or an empty, user-created group — archiving asks
  for confirmation first, since it can't be undone from the UI. An
  archived account stays visible on Home and in its Register (read-only:
  you can't record a new transaction, start a transfer, or import into
  it). If it still has a positive balance, the Register offers
  **Transfer remaining balance** — pick a different, active destination
  and the app moves the full current balance in one transfer. For a
  destination in another currency you must enter the destination amount
  (no pending settlement on an account you're retiring).

Every account and group belongs to exactly one currency; moving money
between different currencies always goes through a **Transfer** (below),
never a plain edit.

## Transfers

From an account's Register (or the Accounts screen), start a transfer:
pick the source and destination accounts, the amount, an optional date and
description.

- **Same currency**: posts immediately as a single entry.
- **Cross-currency**: you can optionally enter the destination amount if
  you know the exchange rate — this posts a single complete entry.
  Leaving it blank posts a *provisional* entry that shows up under Home's
  "Pending transfers" until you settle it with the actual amount received.
  If you've enabled reference-rate lookup in Settings, an indicative
  market rate is shown alongside your own implied rate, for comparison
  only — neither ever auto-fills the destination amount.

### Transfer fees

You can optionally record a fee for the transfer, posted as its own
expense entry against the source account:

- **Charged on top** (default): the fee is additional to the amount you
  enter — e.g. a $100 transfer plus a $5 wire fee debits $105 total.
- **Deducted from the amount**: check "Fee is deducted from the amount
  above" when the amount you enter is the *total* debited and the fee
  comes out of it before conversion (e.g. a remittance service that takes
  a cut) — e.g. entering $100 with a $1.62 deducted fee actually converts
  $98.38.

### Settling a pending transfer

Tap a pending transfer from Home to settle it: choose whether it was
delivered to the destination or returned to the source, and enter the
actual settled amount. If it settles for less than expected, you're asked
to pick a category to cover the shortfall as a fee/loss. That
shortfall/fee applies only when a *transfer* returns to its source — not
when a transfer is delivered to its destination, and not when settling a
foreign-currency transaction (enter the amount that was actually charged).

## Importing bank statements

From the Accounts screen or a Register's import action, you can import a
bank statement instead of entering transactions by hand. Two formats are
supported:

- **OFX/QFX** — parsed directly, no extra setup.
- **CSV** — on the first import from a given file layout, you map which
  column is the date (with its date format), the amount (a single signed
  column, or separate debit/credit columns), the description, and
  optionally a reference id, plus the file's currency. You can save this
  mapping as a named **profile**; the next file with the same header row
  offers that profile automatically, skipping the mapping step.

Either way, you land on the same review screen: rows already imported
before (matched by reference id, or by date/amount/description when
there's no id) are flagged as possible duplicates and excluded by default,
though you can force-include one. Each row needs a category before it can
post — the app suggests one when a row's description exactly matches a
previously posted transaction's, but you can always change it. Deselected
or uncategorized rows are simply skipped, not blocked from posting the
rest of the batch.

Rows sharing the same description are grouped together on the review
screen, so you can assign a category to the whole group in one action
instead of each row individually. From a group, you can also save the
category choice as a **keyword-to-category rule**: any future imported
row whose description contains that keyword is pre-categorized
automatically. A matching saved rule is suggested before the exact-memo
fallback described above, so once you've saved a rule for a recurring
payee, it keeps winning even if an older, differently-categorized entry
also matches by memo. Saved rules can be reviewed, and deleted, from the
import screen's rule-management view.

## Register

Each account's Register lists its transactions newest-first, with each
row showing a direction icon, category, signed amount, and the running
balance after that entry. Tap a row to reverse it — reversal never edits
or deletes the original entry; it posts a new, opposite entry instead, so
the original stays visible and the ledger's history is never rewritten.
An entry flagged as unverified (its signature no longer chains correctly)
is still shown, never hidden, with an error treatment.

## Summary

The Summary tab totals income and expense over a date range you pick (an
"All accounts" option, or narrow it to one account), for a quick
period-over-period read on where money went.

## Settings

- **Fetch reference exchange rates**: off by default. When on, cross-currency
  transfers show a best-effort market rate next to the destination-amount
  field, from your chosen provider, purely for comparison — it's never
  used to fill in or validate the amount you actually enter.
- **Rate provider**: which predefined provider to use when the lookup
  above is enabled.
