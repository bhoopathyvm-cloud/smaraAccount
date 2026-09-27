## Why

Two doc comments still describe the posting-count invariant from the
original single-account scaffold: "Every entry has exactly two postings."
Split transactions (`split-transactions`, archived 2026-08-20) post one
financial-account leg plus one leg per category, so an entry can have three
or more postings. `CONTEXT.md` was corrected to "two or more" during the
grill-with-docs session (#122), and `core-ledger-single-account` already
specifies "one posting against the financial account and one posting per
category leg", but these comments were missed. A reader or coding agent
that trusts the comment over the glossary could write validation that
rejects valid splits.

## What Changes

- `lib/domain/models/posting.dart`: the `Posting` doc comment says every
  entry has two or more postings that sum to zero, matching the Journal
  Entry and Posting definitions in `CONTEXT.md`.
- `lib/data/database/tables/postings_table.dart`: same correction on the
  `Postings` table doc comment.
- Comment-only change. No code, schema, or behavior changes.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
<!-- none: the specs (core-ledger-single-account, split-transactions) already
describe multi-leg entries correctly; only source comments drifted. -->

## Impact

Two Dart doc comments. No API, schema, migration, dependency, or
user-visible changes.
