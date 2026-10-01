# Privacy Policy

Smara Account is a local-first household ledger. This page describes what
the app actually does with information — not a generic template. It is
the same document linked from the app's Settings screen and from App
Store / Play Store listings.

Last updated: 27 September 2026.

## There is no Smara Account server or account

The app does not create an online account, does not sign you in, and does
not store your books on a Smara server. Nothing you enter into your books
— amounts, accounts, categories, payees, descriptions — ever leaves your
device through the app.

This website (`smara-ai.ch`) is a static project site. It does not set
analytics cookies and does not run an advertising or tracking SDK.

## What stays on your device

**Signing key.** When you set the app up, it generates a signing key used
only to sign and later check your ledger history. That key is stored in
the operating system's secure storage (Keychain on Apple platforms,
Keystore on Android, the desktop's secret service on Linux) through the device's own secure-storage APIs. Smara
Account never sends the key anywhere. You can choose to back it up
yourself from Settings — see Backups below.

**Ledger database.** Your accounts, categories, and entries live in a
local database file in the app's private application-support folder on
the device. The app uses that file to show balances and history. It is
not uploaded.

**Settings.** Preferences such as language, whether optional lookups are
on, and app-lock choices are stored on the device (shared preferences
and, for the PIN hash, the same secure storage as the signing key).

## Network lookups

The app can make **three** kinds of network request, all to predefined
public providers. Each is described in Settings, sends as little as
possible, and never includes your balances, payees, descriptions, or how
many of an investment you hold or what you paid.

1. **Reference exchange rates** — off by default. When you turn this on,
   a cross-currency transfer can show a comparison rate from a
   predefined public provider (currently Frankfurter / ECB rates, or
   ExchangeRate-API). The request is a currency pair (for example EUR and
   USD). Nothing else about your books is sent.
2. **Investment market quotes** — **on by default**, and you can turn it
   off in Settings ("Fetch market prices for investments"). When on,
   instruments that have a ticker or ISIN can look up a last price from a
   predefined public quote source (currently Stooq or Yahoo Finance). The
   request is that ticker, market symbol, or ISIN only — never quantity,
   never what you paid. If you never add an investment instrument, no
   quote request is made.
3. **Instrument listing search** — when you add a new investment
   instrument while online, the app searches once (currently Yahoo
   Finance) for the ISIN or ticker you entered, so you can confirm which
   exchange listing you hold (or, if you were offline, during a later
   price refresh while quotes are on). The request is that identifier
   only.

If a lookup fails, the app keeps working with what it already has. These
lookups never post or change a ledger entry.

Opening a holding in your favourite research tool (for example ChatGPT),
or using **Look up identifiers** when adding an instrument, uses your
device browser to open that site with a prompt you can edit. The prompt
contains only the instrument's name, ticker, or ISIN — never quantity,
cost, or account. Opening this Privacy Policy from Settings also uses
your browser.
Smara Account does not send that prompt to a Smara server; the third-party
site's own privacy policy applies once the browser is open.

## Face ID, Touch ID, and other biometrics

Optional app lock can use the device's Face ID, Touch ID, or equivalent.
The app never receives or stores fingerprint, face, or other biometric
templates. The operating system returns only pass or fail. You can also
unlock with the PIN you set in the app; that PIN is stored as a hash in
secure storage, not as the PIN itself.

## Backups and CSV exports

**Save backup** writes an encrypted, passphrase-protected copy of the
local ledger database to a file you choose. That file is books, not your
signing key. Restoring it replaces local books; it does not transplant a
key from another identity.

**Books Copy** (optional, Settings) writes a passphrase-encrypted copy of your books to a location you choose. It does not include your private signing key. Restoring a copy replaces the books on this device.

**both** your books and your signing
key, so you can move to a new device in one step. Anyone with that file
*and* its passphrase could read your books and sign entries as you, so
keep the passphrase separate from the file. The app never uploads it.

**Export CSV** writes transaction rows you choose (including whether each
row still verifies) to a file you choose. It does not include the signing
private signing key. A lost device can only be recovered from a saved Books Copy.

**Hide balances in the app switcher** (optional) covers the app's content
while it is in the background; nothing is sent anywhere.

Files you save live wherever you put them. Treat them like financial
records.

## Cryptography (export compliance)

The app uses standard cryptography to sign and verify ledger entries, to
hash the app-lock PIN, and to encrypt the backup, keystore, and device
migration files you choose to save. It does not use cryptography to scramble
network traffic, does not ship a proprietary algorithm, and is not a
cryptography product. That is the same story declared in the iOS
export-compliance flag (`ITSAppUsesNonExemptEncryption` = false).

## What we do not do

The app does not sell data, does not show ads, does not use a crash or
analytics SDK, and does not share ledger contents with a third party as
part of recording or displaying your books.

## Contact

Privacy questions and corrections to this page: open an issue on the
[Smara Account repository](https://github.com/bhoopathyvm-cloud/smaraAccount/issues).
That is the same contact path as other project contributions.
