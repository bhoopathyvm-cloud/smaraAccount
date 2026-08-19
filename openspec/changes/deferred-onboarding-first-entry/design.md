## Context

An earlier draft of this change considered deferring the *signing
identity itself* — "no signed ledger entries are committed until the
user completes recovery phrase acknowledgment" — with the mechanism left
as an open choice ("may live in a staging state or post after protect —
design picks one"). Checking that against the actual code ruled it out:
`recordTransaction`'s core posting path hard-throws (`StateError`) if no
signing identity exists yet — every posting in this app, from any
feature, funnels through that same guard. Supporting a genuinely
unsigned or staged entry would mean either weakening that guard (a
change to what "signed" means, touching the integrity model this app is
built around) or inventing a second, parallel storage path for
not-yet-signed entries that later gets migrated into the real chain — a
meaningfully larger and riskier change than the actual product problem
calls for.

The product problem is narrower than that: a user should be able to try
recording one transaction before facing a 24-word ritual. Nothing about
that requires the entry to be *unsigned* — it only requires the
**acknowledgment screen** to not be the very first thing they see. The
signing identity is already generated silently and automatically today,
before any account or entry exists (`Device Signing Identity` requirement,
unchanged) — the user has never had to do anything to make that happen.
This change resequences only the mandatory acknowledgment UI.

## Goals / Non-Goals

**Goals:**
- First value (one recorded transaction) in under two minutes.
- The recovery phrase acknowledgment stays fully mandatory — resequenced,
  never skippable, never silently deferred past "immediately after the
  first entry."
- No change to what a signed journal entry is, when the signing identity
  is generated, or the hash-chain/signature mechanism.

**Non-Goals:**
- An unsigned, staged, or "demo" transaction concept.
- Deferring acknowledgment across an entire first session or to a second
  app open. (An earlier draft considered this; rejected — see Decisions.)
- Anything from `proposal.md`'s stated non-goals.

## Decisions

### 1. Identity generation is untouched; only the acknowledgment screen moves
`generateFirstIdentity()` (or equivalent) still runs automatically at
first launch, before the first-account-naming screen — exactly as
`Device Signing Identity` already specifies. The app router's redirect
guard, which today sends any session with an unacknowledged identity
straight to `/onboarding/recovery-phrase` before `/home`, is changed to
instead allow exactly one path through: name the first account, record
one transaction, **then** the redirect to the acknowledgment screen
fires and blocks everything else. This is a router/UI sequencing change,
not a signing-path change — `recordTransaction`'s existing "identity
must exist" guard is untouched and still trivially satisfied, since the
identity already exists by the time the guided first entry calls it.

### 2. Gate immediately after the first entry, not "before second session"
An earlier draft gated on "the user's *second app open*," which would
let someone record an unbounded number of transactions in one long first
sitting before ever seeing the phrase — a larger unprotected window than
the product goal needs. This change gates on **the first entry itself**:
once it posts, the acknowledgment flow is shown and blocks every other
action (recording a second transaction, navigating away, backgrounding
the app) until completed. The user still gets exactly what they asked
for — try one thing before the ritual — with the smallest possible
window where a device loss would mean losing an un-backed-up entry (one
entry, not an open-ended first session).

### 3. What "Mandatory Recovery Phrase Acknowledgment" changes to
The existing requirement's scenario ("the user must confirm possession
of the phrase... before recording their first transaction") is modified
to move that blocking point to immediately after the first transaction.
Every other guarantee in that requirement (phrase derived from the
signing key, optional keystore export, no server escrow) is unchanged.

## Risks / Trade-offs

- [Risk] A future contributor reads "deferred onboarding" and assumes the
  signing identity itself is deferred. → Mitigation: proposal.md and this
  design.md say explicitly, more than once, that identity generation is
  unchanged; the `Device Signing Identity` requirement is not touched by
  this change's delta.
- [Risk] The app is killed (crash, OS kill) between the first entry
  posting and the acknowledgment screen being acted on. → Mitigation:
  the redirect guard re-fires on next launch (same as today's "second
  session requires protect" scenario) — the entry is already fully
  signed and safe either way; only the *screen* needs to reappear, which
  it does automatically via the existing redirect mechanism.
- [Risk] Scope creep into the guided first-entry screen's UX. → Mitigation:
  child change stays focused on sequencing, not a new entry-recording UI
  beyond what onboarding already needs.

## Migration Plan

Implementation note (found necessary while applying this change, not
anticipated when this design.md was first written): identity existence
alone can no longer signal "onboarding complete," since the identity is
now committed to the database before acknowledgment happens — the router
needs a separate signal for "committed but not yet acknowledged" so it
still forces the acknowledgment screens rather than treating an
in-progress first-run session as done. This required one additive schema
change: `signing_identities.acknowledgedAt` (nullable, schemaVersion 12).
Every identity that already exists in a database upgrading from an
earlier schema is backfilled with `acknowledgedAt = createdAt`, since
under the old flow identity commit and acknowledgment were the same
moment — an existing user is never sent back through acknowledgment
screens for a phrase this app never stored and cannot show again.
Existing installs are otherwise unaffected; the redirect guard only
applies to a session with an unacknowledged identity.

A second, related gap: the plaintext recovery-phrase words themselves are
never persisted to the database (by design) and previously lived only in
the onboarding ViewModel's memory. Under the old flow that was safe to
lose on a kill, since nothing was committed yet either. Under this
change, the identity (and the guided first entry) must survive a kill
between commit and acknowledgment, so the words are now also temporarily
stashed in the same OS-protected secure storage already trusted for the
private key (`SigningKeyService.stashPendingPhraseWords`), and cleared
the moment acknowledgment completes.

## Open Questions

None that block apply.

## Note on an existing, related requirement

`ledger-integrity-signing`'s existing `User Guide Explains the
Signing-Key Tradeoff` requirement demands the guide explain the
key-loss consequence *before* describing onboarding steps in the
**documentation's own reading order** — that's about how the guide
prose is sequenced, not the app's on-screen flow. This change doesn't
touch that requirement: the guide can and should still lead with the
key-loss warning as general education, even though the app itself now
lets a user try one entry before the phrase screen appears. Checked
before finalizing this design so the two don't read as contradictory.
