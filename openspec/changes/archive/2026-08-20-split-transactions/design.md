## Context

Checked the actual posting/display code before scoping this: three
places assume a transaction has exactly one category leg.

- `core-ledger-single-account`'s `Record a Transaction` requirement:
  "providing... **a category**" (singular) and "affecting the selected
  Income category" (singular) — this is the requirement text itself, not
  just an implementation detail, so a split needs a real MODIFIED delta
  here, not a same-capability-untouched ADDED requirement living next to
  a contradicted one.
- `RegisterViewModel`: `entry.postings.firstWhere((p) => p.accountId !=
  accountId, orElse: () => ownPosting)` picks exactly one "other"
  posting to label the row. For a split entry (1 financial-account leg +
  N category legs), this silently returns whichever category leg
  `firstWhere` hits first and drops the rest from that row's label —
  the amount shown is still correct (it comes from the financial-account
  leg), only the category text is incomplete. This is a real display bug
  the split-posting change introduces if left unaddressed, not a
  cosmetic nice-to-have.
- `reverseEntry` and `watchSummary`, checked and **not** affected:
  reversal already iterates `originalPostings` generically and negates
  each one, so an N-posting split entry reverses correctly with no code
  change; Summary already joins at the posting level (each posting's own
  account, not the entry as a whole), so each split leg lands in its own
  category's total without any change either.

## Goals / Non-Goals

**Goals:** One user action posts one balanced entry with multiple
category legs; register, summary, and reversal all correctly represent
it.

**Non-Goals:** Splitting an already-imported/already-posted row after
the fact (proposal.md's "import row (later)" — deferred); splitting a
transfer (asset-to-asset) rather than an income/expense transaction.

## Decisions

### 1. `core-ledger-single-account`'s `Record a Transaction` gets a MODIFIED delta
Widen the requirement text to: the user provides one or more (category,
amount) lines whose amounts sum to the transaction total, instead of
exactly one category. The single-category case becomes the N=1 case of
the same mechanism, not a separate code path — existing single-category
scenarios keep passing unchanged.

### 2. Repository: `recordSplitTransaction` posts one entry, multiple category postings
`Dr/Cr` the financial-account leg once for the full amount; post one
category leg per split line. Validate the split lines' amounts sum
exactly to the total before posting anything (reject the whole action,
not a partial post, on a mismatch).

### 3. Register row: replace the single "other posting" lookup with all of them
`RegisterViewModel` collects every posting on the entry other than the
viewed account's own leg (not just the first), and `RegisterRow` carries
a list, not a single counterpart. `RegisterRowTile` renders it as a
summarized label for more than one: the first category name plus "+N
more" (exact wording is a UI-copy decision at apply time), tappable to
see the full breakdown if useful. A single-category entry (N=1) renders
exactly as it does today — this is additive to the existing display
logic, not a rewrite of it.

### 4. No change needed to reversal or Summary
Confirmed by reading the actual code (see Context) — both already
operate at the individual-posting level, not assuming a fixed posting
count per entry. Called out explicitly so a future implementer doesn't
add unnecessary special-casing for splits in either path.

## Risks / Trade-offs

- [Risk] A split's category legs could each need independent validation
  (active category, etc.) — more failure surface than a single-category
  transaction. → Mitigation: validate every line before posting any of
  them; reject-and-explain-which-line, not a partial post.
- [Risk] Interaction with other child changes (`payees-and-spending-memory`
  autofill, `recurring-templates` templates) assuming one category per
  transaction. → Mitigation: out of scope for v1; those changes keep
  working against single-category transactions, splitting is opt-in per
  entry.

## Migration Plan

Additive: existing entries are unaffected (they're already the N=1 case).
No schema change beyond what multiple postings on one entry already
supports (the schema already allows an entry to have more than 2
postings — nothing currently using it, but nothing prevents it either).

## Open Questions

None that block apply.

## Filled in during implementation

Design.md's mechanics were accurate; a few concrete choices weren't
spelled out and are recorded here:

- **No foreign-currency support for v1.** `recordSplitTransaction` always
  posts in the financial account's own currency - splitting and the
  foreign-currency/provisional-settlement flow are mutually exclusive in
  this change (the record screen hides the foreign-currency fields while
  splitting). Not called out as a Non-Goal in the original draft, but
  consistent with it: nothing in the proposal asked for a split *and*
  cross-currency transaction at once.
- **`recordSplitTransaction` validates against a caller-supplied
  `totalAmountMinor`, not just the sum of its own lines.** The repository
  receives both the split lines and the transaction's overall total (the
  same "Amount" field a non-split entry already has) and rejects a
  mismatch - defense-in-depth beyond the record screen's own live
  remainder check, matching this codebase's general pattern of the
  repository re-validating rather than trusting the ViewModel alone.
- **`RegisterViewModel.isRowFixable` now also requires exactly one
  counterpart.** Design.md's Decision 3 covered the row *label*; it didn't
  say what Fix-eligibility should do for a split. Resolved conservatively:
  a split entry gets no Fix tap target at all, since the Fix form has one
  category field to prefill and a split has none that's uniquely correct.
- **Removing a split line down to one auto-collapses back to the
  non-split form**, repromoting that line's category into the ordinary
  `categoryId` field. This is what makes splitting "an in-place expansion
  ... reversible the same way" (split-transactions spec's own framing)
  actually true in the implementation, not just the forward direction.
