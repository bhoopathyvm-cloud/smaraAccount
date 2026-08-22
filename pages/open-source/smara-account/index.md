# Smara Account

## What Smara Means

**Smara** comes from Sanskrit. The word is connected with remembrance,
memory, and recollection. That meaning fits this project: Smara Account is
about helping a person remember financial history clearly, without old
records quietly changing behind their back.

The name also links the project back to this personal site. My own story
started far from software, in a farming village where memory, trust, and
spoken records mattered. Smara Account takes that simple idea of
remembering what happened and gives it a modern software shape: local
books, signed history, and corrections that keep the original visible.

A local-first, tamper-evident double-entry ledger. No server, no cloud,
no data leaving your device.

In plain language: Smara Account is for people who want their household
or small-business books to behave like a notebook, but with one important
upgrade — old pages cannot be quietly rewritten without the app noticing.

## The Problem

Most accounting apps ask you to trust two things at once: a cloud
provider with your financial history, and a system where "immutable"
transaction history usually just means nobody built the edit button yet.
Once your data lives on someone else's server, you're trusting their
uptime, their access controls, and their promise not to look. And even
apps that stay local rarely make tampering with a past entry — by you,
by malware, or by anyone with file access — actually difficult. A
database row is a database row; anyone who can open the file can rewrite
it.

## The Solution

Smara Account keeps everything on your own device — no server, no cloud
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

## What This Gives You

Most people do not think in audit or cryptography terms. The practical
benefit is simpler: when you look back at your books, restore a backup,
or hand an export to an accountant, the app can tell whether its recorded
history still matches what was originally posted.

- **More trustworthy history:** old entries are not changed in place; a
  correction is recorded beside the original, so you can see what changed.
- **Warnings instead of silent wrong totals:** if a stored entry no longer
  verifies, the app can flag it and exclude the unverifiable part from
  balances rather than quietly accepting damaged data.
- **Safer backups and exports:** a restored ledger can be checked against
  its signed history, and exported rows can carry whether each entry still
  verifies.
- **Better handoff:** if you share records with an accountant, tax adviser,
  or future version of yourself, the history includes evidence about
  whether the data stayed intact.

It does **not** stop someone from entering a false transaction while they
legitimately have the app open, and it does **not** replace backups or
device security. It is a way to detect hidden changes to recorded history,
not a promise that every recorded transaction is true.

## What It Does Today

Recording income and expenses, multiple accounts and account groups
(including different currencies), transfers between accounts, importing
bank statements from OFX and CSV files with saved category rules, a
running register, and a summary view. See [What's built](whats-built.md)
for the full, current list.

## Try It Or Contribute

The project is open source. See [How it was built](how-it-was-built.md)
for the development approach, or head straight to the
[repository](https://github.com/bhoopathyvm-cloud/smaraAccount) to read
the code, file an issue, or open a pull request.

## Background Reading

The design uses common integrity and audit-trail ideas, translated into a
small local app:

- [NIST: integrity](https://csrc.nist.gov/glossary/term/integrity) —
  why detecting improper modification matters.
- [NIST: digital signature](https://csrc.nist.gov/glossary/term/digital_signature)
  and [hash function](https://csrc.nist.gov/glossary/term/hash_function) —
  the cryptographic building blocks behind signed history.
- [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html)
  and [Schneier/Kelsey secure audit logs](https://www.schneier.com/academic/archives/1999/05/secure_audit_logs_to.html)
  — why logs and histories should detect tampering.
- [OpenStax: audit trails in accounting](https://openstax.org/books/principles-financial-accounting/pages/7-1-define-and-describe-the-components-of-an-accounting-information-system)
  and the [IRS electronic accounting records FAQ](https://www.irs.gov/businesses/small-businesses-self-employed/use-of-electronic-accounting-software-records-frequently-asked-questions-and-answers)
  — why transaction history and record integrity matter outside the app.
- [AWS QLDB journal overview](https://aws.amazon.com/blogs/aws/now-available-amazon-quantum-ledger-database-qldb/)
  — an industry example of cryptographically verifiable ledger history.
