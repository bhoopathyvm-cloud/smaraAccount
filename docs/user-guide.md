# User Guide

SMARA Account is household books on your device: record what you spend
and receive like a notebook, and history can't quietly rewrite itself.
Everything described here reflects the app as it currently exists —
nothing in this guide is a planned or proposed feature.

## Your recovery phrase

Every device generates its own signing key, and every transaction you
record is signed with it. This is what makes the ledger tamper-evident —
there is no server and no account recovery. **If you lose this device and
your recovery phrase together, every transaction you've recorded becomes
permanently unverifiable.** There is no way for anyone, including the
app's author, to recover it for you.

You get two ways to protect against that:

- **Recovery phrase** (mandatory): a 24-word phrase, written down and
  acknowledged right after your first entry (see Onboarding below). This
  alone is always enough to restore your signing key.
- **Keystore file** (optional): an additional, passphrase-encrypted backup
  file you can export during that same step or skip entirely — your
  recovery phrase alone is sufficient without it.

If you ever lose both, the app still has an escape hatch (see
[True key loss](#true-key-loss) below), but it comes with a real
trade-off: everything recorded before that point can no longer be proven
untampered, only preserved as a read-only historical record.

## Onboarding

On first launch, the app walks you through this order:

1. **Currency** — pick your base currency. This becomes the currency of
   the starter account groups (Cash & cash equivalents, Credit &
   short-term debt, etc.) created for you, and generates your device's
   signing key automatically in the background.
2. **Record one entry** — a guided Spent or Received, so you can try the
   app before facing the recovery-phrase ritual.
3. **Your recovery phrase** — the 24 words are generated and shown once.
   Tap "I've saved my recovery phrase" only once you've actually written
   them down.
4. **Optional backup file** — enter a passphrase to export an encrypted
   keystore file, or tap "Skip." Neither blocks you from continuing.
5. **Confirm** — you re-enter part of your phrase to confirm you actually
   saved it correctly.

The entry you record in step 2 is a real, permanently signed transaction
from the moment it posts — not a demo. Steps 3–5 are mandatory and block
everything else (recording a second entry, leaving the app, even resuming
after it's closed) until you complete them; if the app is closed partway
through, it picks back up at the same step next time you open it, showing
the same phrase again.

## Setting up your accounts

Right after onboarding finishes, a short one-time wizard helps you get
from "just set up" to "ready to record real life":

- **Name your main account** — a starter account already exists for you;
  give it the name you actually recognize, like your bank. This step is
  required.
- **Add a credit card** (optional) — name it to create a liability
  account for it.
- **Add a cash account** (optional) — name it to create a second asset
  account for cash you track separately.

Skipping the optional steps just leaves you with the one main account,
renamed — you can always add more accounts later from the Accounts tab.
This wizard only ever appears once.

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

Home is the primary place you both glance at your money and add to it
(also where the gear icon opens **Settings**). It shows:

- **What you have minus what you owe** — your overall balance per
  currency (assets minus liabilities), with the assets/liabilities
  breakdown underneath.
- **Due today** — recurring templates (see below) whose day has arrived
  or passed and haven't been recorded yet this month. Tap one to record
  it now — nothing posts on its own.
- **Pending transfers** — a plain sentence for each one, like "You sent
  50.00 USD to Savings — tap when you know what arrived." These are
  cross-currency transfers or purchases whose exact amount wasn't known
  at the time; tap one to say what actually arrived.
- **This month** — what you've spent this calendar month, by category,
  and what you've received, by category. A category with no activity
  this month simply isn't listed. A category with a monthly limit set
  (see Categories below) shows its progress here too.
- **Account groups** — every account group with its accounts, tap an
  account to open its Register.

The **Add** button opens one choice: **Spent**, **Received**, **Moved
money**, or **Import statement**. Register's own Add button opens the
same choice, with the account you're viewing already selected.

## Recording a transaction

From the Register screen's "+" button: pick the account, whether it was
**Spent** or **Received**, the amount, a category, the date, and an
optional description. If the transaction was in a different currency than
the account, you can enter that currency (and optionally the equivalent
account-currency amount — leave it blank to post provisionally and settle
the exchange rate later).

### Splitting across multiple categories

A single purchase spanning more than one category — an Amazon order
that's part groceries, part household — doesn't have to be squeezed into
one category or entered as separate transactions. Tap "Split into
multiple categories" under the category field to expand into a list of
category lines, each with its own category and amount; a running
**Remaining** total shows what's left to allocate, and Save stays
disabled until it reaches zero. Removing lines down to one collapses back
to the ordinary single-category form. Splitting isn't available for a
transaction in a foreign currency.

Once posted, a split shows up in its account's Register as one row
labeled with its first category plus how many more ("Groceries +1
more") — the amount shown is always the full transaction, not any one
category's share. Fixing or reversing a split reverses every category
line together, in one action; the Fix flow itself is only offered for an
ordinary, single-category entry, since there's no single category to
prefill for a split. The Summary screen still totals each category leg
into its own category correctly, exactly as it would for separate
transactions.

Typing in the description field offers matching **payees** as you type —
selecting one fills in the description and suggests that payee's default
category and account, both always changeable before you save. After you
save, that payee's defaults update to whatever you actually used, so the
next entry for the same payee suggests your latest choice. Payees
themselves are managed from Settings ("Manage payees"): add, rename, or
delete one there; deleting only removes the memory aid, never any past
transaction.

### Recurring templates

For a bill or paycheck that repeats every month — rent, a subscription,
salary — create a recurring template instead of typing the same entry
each time: a name, Spent or Received, an account, a category, an amount,
and a day of the month (a month with fewer days uses its own last day).
Manage templates from Settings ("Manage recurring templates").

Once a template's day arrives (and stays due until you act on it, even
if you miss the exact day), it shows up on Home under **Due today**.
Tapping it records the transaction immediately, using the template's
amount, account, and category — it is never posted for you automatically,
so nothing changes in your books without a tap. After recording, it
won't be offered again until its day comes around next month.

## Categories

The Categories tab lists every income and expense category. Tap "+" to add
one (name + Income/Expense), the pencil icon to rename one, or "Hide" to
retire one — hidden categories stay visible on past transactions but are
no longer offered when recording new ones. Tap **Restore** on a hidden
category to bring it back into the picker again — hiding isn't a
one-way trip. A starter set already covers common household spending,
including Groceries, Rent/Mortgage, Utilities, Transport, Food out,
Phone, and Health.

### Monthly limits

Any Expense category can have an optional monthly spending guide: tap the
target icon on its row to set an amount, or leave the field blank to clear
an existing one. Once set, the category's row shows month-to-date spent
against that limit, with a calm "Over limit" note if you've gone past it —
this is purely informational. Recording a transaction against a category
past its limit is never blocked. If Home's "This month" section is
present, the same progress shows there too, next to that category's total.
Income categories don't offer a limit.

## Accounts and account groups

The Accounts tab manages your accounts (asset or liability) and the
groups they belong to.

- **Create an account**: name, Asset or Liability, which group, and an
  optional opening balance. For a Liability account, you can also mark
  **This is a credit card** — a label you set once at creation and can't
  change afterward. A credit card behaves exactly like any other
  liability account for balance, transfers, and recording; the flag only
  changes how it's shown and a couple of capture shortcuts (below).
- **Create a group**: name, Asset or Liability, and a currency (ISO 4217,
  e.g. `USD`) — every account in a group shares that group's currency.
- **Rename** an account or edit a group's name/currency (currency can only
  change while the group has no active accounts, since changing it would
  retroactively reinterpret historical balances).
- **Reassign** an account to a different group of the same currency.
- **Hide** an account or an empty, user-created group from new entries —
  hiding asks for confirmation first. A hidden account stays visible on
  Home and in its Register (read-only: you can't record a new
  transaction, start a transfer, or import into it). If it still has a
  positive balance, the Register offers **Transfer remaining balance** —
  pick a different, active destination and the app moves the full
  current balance in one transfer. For a destination in another currency
  you must enter the destination amount (no pending settlement on an
  account you're retiring).
- **Restore** a hidden account or group at any time — tap **Restore**
  where "Hide" used to be. Unarchiving an account whose own group had
  also been hidden restores both together in one tap, so the account is
  never left without an active group; restoring a group on its own does
  *not* also restore any accounts that were hidden while it was still
  active — each is undone independently. Restoring never reverses a
  **Transfer remaining balance** closeout that already happened, or
  brings back whatever balance it moved out.

Every account and group belongs to exactly one currency; moving money
between different currencies always goes through a **Transfer** (below),
never a plain edit.

Amounts are always displayed and entered per their own currency's own
convention, not your device's language or region: ₹ amounts group as
lakhs/crores (₹10,00,000), ¥ amounts show no decimal places, € amounts
use a period to group and a comma for the decimal, and so on. Type an
amount using whichever separator its currency actually uses — the field
tells you if what you typed isn't a valid amount, rather than silently
treating it as empty.

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
  enter — e.g. a $100 transfer plus a $5 wire fee costs $105 total.
- **Deducted from the amount**: check "Fee is deducted from the amount
  above" when the amount you enter is the *total* charged and the fee
  comes out of it before conversion (e.g. a remittance service that takes
  a cut) — e.g. entering $100 with a $1.62 deducted fee actually converts
  $98.38.

### Settling a pending transfer

Tap a pending transfer from Home and you land on "What arrived?": choose
whether it was delivered to the destination or returned to the source,
and enter the actual amount. If you received less than expected, you're
asked to pick a category to cover the difference. That only applies when
a *transfer* returns to its source — not when a transfer is delivered to
its destination, and not when settling a foreign-currency transaction
(enter the amount that was actually charged).

### Credit cards

A credit card is an ordinary liability account marked as a card at
creation (see Accounts and account groups above) — no separate account
type, no statement cycle or due-date tracking. Two things change once
you have one:

- **Recording spent** offers **Paid from card** and **Paid from bank**
  shortcuts above the Account field, narrowing the picker to just your
  card accounts or just your other accounts. They're shortcuts only —
  the same Account field is still there underneath, and with no card
  account these shortcuts don't appear at all.
- **Pay card**, shown on a card's own Register, is an ordinary transfer
  from a bank account to the card, pre-filled with the card as the
  destination — the same mechanism as any other transfer, just labeled
  and pre-selected so you never have to think in "transfer" terms to pay
  one down.

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
import screen's rule-management view. Saving a rule also offers, pre-checked,
to remember the same keyword as a payee with the rule's category as its
default — so the next time you type that payee's name into a manually
recorded transaction, its category is already suggested. Declining still
saves the rule exactly as it would otherwise.

## Register

Each account's Register lists its transactions newest-first, with each
row showing a direction icon, category, signed amount, and the running
balance after that entry. Tap an ordinary Spent/Received row to **Fix**
it: a form opens prefilled with that entry's account, amount, category,
date, and description, ready to edit. Confirming never edits or deletes
the original line — it posts a correction next to it instead, so the
original stays visible and your history is never rewritten. Transfers,
opening balances, and split entries aren't offered a tap target; they
don't have a Fix flow of their own yet.
An entry flagged as unverified (its signature no longer chains correctly)
is still shown, never hidden, with an error treatment.

Above the list, a **Search** box matches a row's description, category,
or amount as you type. Chips below it narrow further, combinable with
the search and with each other: **Spent only** or **Received only**, and
a date range. Search and filters only change which already-posted rows
are visible — they never change what's posted or the order it's shown
in. The clear ("×") button on the search box, shown whenever a search or
filter is active, resets everything back to the full register.

### Exporting to CSV

The Export CSV button in the Register's app bar lets you pick a date
range, then saves the currently viewed account's transactions for that
range to a CSV file you choose where to put — useful for handing off to
an accountant or taking your data somewhere else entirely. Each row has
the date, description, category (or, for a transfer, the other
account's name; for an opening balance, "Opening balance"), whether it
was spent or received, the amount, the currency, and whether the entry's
signature still verifies. A split transaction exports one row per
category, each with that category's own share of the total, not the
whole amount repeated. The export never includes your recovery phrase,
keystore, or any other signing-key material — only the same
date/description/category/amount data the Register itself already shows
you.

## Summary

The Summary tab totals income and expense over a date range you pick (an
"All accounts" option, or narrow it to one account), for a quick
period-over-period read on where money went.

## Settings

- **Manage payees**: add, rename, or delete a payee and its remembered
  default category/account (see Recording a transaction above). Deleting a
  payee only removes the memory aid — past transactions are unaffected.
- **Manage recurring templates**: add, edit, or delete a monthly bill or
  income template (see Recording a transaction above). Deleting one only
  stops it from being offered as due — past transactions it already
  recorded are unaffected.
- **Fetch reference exchange rates**: off by default. When on, cross-currency
  transfers show a best-effort market rate next to the destination-amount
  field, from your chosen provider, purely for comparison — it's never
  used to fill in or validate the amount you actually enter.
- **Rate provider**: which predefined provider to use when the lookup
  above is enabled.
- **Save backup**: writes an encrypted copy of your books to a location
  you choose, protected by a passphrase you pick. This backs up your
  *books* (accounts, categories, entries) — it's separate from your
  recovery phrase or keystore file, which back up your *signing key*.
  There's no way to recover the backup if you forget its passphrase.
- **Restore backup**: pick a backup file and its passphrase to restore
  from it. Restoring **replaces** everything currently in the app — it
  never merges with what's already there — after an explicit
  confirmation naming what will be replaced. A backup restores onto a
  device with no identity of its own (a fresh install) or onto the same
  device it came from; restoring a backup that belongs to a different
  signing identity than the one already set up on this device is
  rejected, since that would combine two different people's books rather
  than restore your own. Right after a successful restore, the app closes
  so you can reopen it and continue — the restored ledger is immediately
  readable and fully verified, but recording a new entry still needs the
  matching signing key restored separately, via recovery phrase or
  keystore.
- **Require unlock to open the app**: off by default. Turning it on asks
  you to set a PIN (at least 4 characters); from then on, opening the app
  or returning to it after the idle timeout requires that PIN. Turning it
  off clears the stored PIN — turning it back on later always starts from
  a fresh one.
- **Change PIN**: shown once app lock is on. Asks for your current PIN
  before accepting a new one.
- **Lock after**: how long the app can sit in the background before the
  next time you open it asks for your PIN again — Immediately, 1 minute,
  5 minutes, or 15 minutes.
- **Also allow biometrics**: shown only on a device with working Face
  ID/Touch ID/fingerprint unlock. When on, the lock screen tries
  biometrics first and always still accepts the PIN as a fallback.
- **Hide balances in the app switcher**: obscures the app's content when
  you switch to another app, independently of whether app lock itself is
  on. Only shown on iOS and Android — desktop platforms (macOS, Windows)
  have no equivalent app-switcher-snapshot mechanism to hide, so Settings
  says so plainly there instead of showing a toggle that would do
  nothing.
