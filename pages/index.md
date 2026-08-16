# SMARA Account

A local-first, tamper-evident double-entry ledger. No server, no cloud,
no data leaving your device.

## The problem

Most accounting apps ask you to trust two things at once: a cloud
provider with your financial history, and a system where "immutable"
transaction history usually just means nobody built the edit button yet.
Once your data lives on someone else's server, you're trusting their
uptime, their access controls, and their promise not to look. And even
apps that stay local rarely make tampering with a past entry — by you,
by malware, or by anyone with file access — actually difficult. A
database row is a database row; anyone who can open the file can rewrite
it.

## The solution

SMARA Account keeps everything on your own device — no server, no cloud
storage, no account to sign up for. Every journal entry is cryptographically
signed with a key generated and held only on your device, and entries are
chained together so that altering one breaks the chain from that point
forward and is detected the next time the app opens. If a break is
detected, the affected entries are quarantined and flagged, never
silently accepted or hidden.

Posted entries are never edited or deleted in place. A correction is
always a new, opposite entry — the original stays in the record, so the
ledger's history is genuinely append-only, not just conventionally so.

The tradeoff is intentional: the signing key has no recovery backdoor.
Lose it, and past entries can't be re-signed under a new identity without
being marked as such — there's no way to quietly rewrite history, which
is what makes "tamper-evident" a property of the system rather than a
marketing claim.

## What it does today

Recording income and expenses, multiple accounts and account groups
(including different currencies), transfers between accounts, importing
bank statements from OFX and CSV files with saved category rules, a
running register, and a summary view. See [What's built](whats-built.md)
for the full, current list.

## Try it or contribute

The project is open source. See [How it was built](how-it-was-built.md)
for the development approach, or head straight to the
[repository](https://github.com/bhoopathyvm-cloud/smaraAccount) to read
the code, file an issue, or open a pull request.
