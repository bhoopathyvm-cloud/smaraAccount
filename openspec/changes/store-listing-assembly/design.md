## Context

See proposal.md for motivation. This is content-assembly work, not a code
change — no new architecture, dependency, or data model is involved. The
design here is really about where each piece of content comes from and
how it stays consistent, not how anything is built.

## Goals / Non-Goals

**Goals:**
- One clear source for each piece of listing content, so the same fact
  (what the app does, what data it touches) isn't independently
  re-invented in three different places (website, App Store Connect,
  Play Console) and drifting between them.
- Real screenshots from a real build, not mockups.

**Non-Goals:**
- Signing, entitlements, archive, or submission mechanics — those stay in
  `app-store-launch-readiness` and `macos-app-store-sandbox`.
- Marketing strategy, ASO (App Store Optimization) keyword research, or
  paid promotion — out of scope; this is "get accurate, complete listings
  done," not "optimize them."

## Decisions

### 1. Description/keywords derived from the existing website copy, not written fresh
`pages/open-source/smara-account/index.md` already has a settled
"what it is / the problem / the solution" narrative. Reusing it (adapted
to each store's length limits — App Store Connect's promotional text and
description fields vs. Play Console's short/full description) keeps the
public description of the app consistent everywhere, and avoids
re-litigating positioning decisions that are already made.

**Alternative considered:** write store copy independently, optimized
for each store's conventions. Rejected for now — the app doesn't have
users yet to test messaging against, so there's no signal to optimize
toward; consistency with the existing copy is more valuable than a
speculative rewrite.

### 2. Screenshots start from iOS Simulator, not a real device
The Simulator gives every required iPhone/iPad size class from one
machine without needing physical devices for each. A real device pass
(the same iPhone used for acceptance testing) is a fallback only if a
Simulator-captured screen looks visibly different from real hardware
(font rendering, safe-area insets).

**Alternative considered:** capture from the real iPhone only, matching
how the acceptance suite already runs on real hardware. Rejected as the
primary path — one physical device can't produce every size class Apple
lists without also using Simulator or multiple devices, so Simulator is
required either way; starting there covers more ground per pass.

### 3. Privacy forms filled in by direct line-by-line diff against the privacy policy, not from memory
Both stores' privacy forms are structured questionnaires, not free text —
easy to fill in "from general knowledge of the app" and get subtly wrong.
Treating `privacy-policy.md` as the literal source of truth and checking
each form field against a specific line in it (not a paraphrase of it)
is the only way to guarantee the two can't say different things about
what the app actually does with data.

### 4. App name stays "Smara Accounting," not "Smara Ledger" or "Smara Finance Book Keeping"
Considered three options against two different audiences: how an actual
accountant reads the word, and how a person on the street reads it.
"Ledger" is precise, correct bookkeeping vocabulary to an accountant (the
app does implement a real general ledger), but to a general audience it
collides with the **Ledger crypto hardware wallet** — a well-known,
unrelated consumer brand — and risks reading as a crypto product rather
than an accounting app. "Smara Finance Book Keeping" is too long: app
names truncate on home screens (roughly 11-13 visible characters on iOS
before an ellipsis), and "Finance" plus "Book Keeping" is redundant.
"Accounting" needs no specialized knowledge and is what people actually
search for ("accounting app," "expense tracker," "bookkeeping app," not
"ledger app"). Since this app is explicitly aimed at regular people and
small-business owners rather than professional accountants, the
street-level audience's comprehension wins over the thematically neater
but narrower "Ledger" pitch.

**Alternative considered:** "Smara Books" — colloquial on both sides
(accountants say "the books" too), no crypto-brand collision, but sits
close to Apple's own "Apple Books" reading app. Rejected in favor of
"Smara Accounting," which is also already the real `CFBundleDisplayName`
everywhere (iOS, macOS, Android) — zero migration cost, nothing to
rename in code.

## Risks / Trade-offs

- **[Risk]** The privacy policy itself might have gaps or be slightly
  stale relative to what the shipped app actually does (e.g. a data flow
  added after the policy was last reviewed) → **Mitigation:** if a
  privacy-form question can't be answered from the policy text, treat
  that as a signal to fix the policy first, not to guess an answer for
  the form and leave the policy out of sync.
- **[Risk]** iOS Simulator screenshots don't always match real-device
  rendering exactly (fonts, scaling) → **Mitigation:** spot-check at
  least one Simulator screenshot against the real iPhone before treating
  the full Simulator set as final.
- **[Trade-off]** Deriving copy from the existing website narrative means
  the store listing inherits that copy's framing and tone as-is, rather
  than being written for store-specific conversion optimization —
  accepted per Decision 1; revisit once there's real usage data to
  optimize against.

## Migration Plan

Not applicable — this produces new content (descriptions, screenshots,
form answers) rather than changing anything that exists today. No
rollback needed beyond not submitting.
