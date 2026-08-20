## Context

An earlier draft's proposal promised "restore group if archived and
still valid" but the delta only covered accounts and categories — no
group-unarchive requirement existed at all. Checked the existing
archiving precondition before writing one: a user-created group "SHALL
be archivable once it has zero active member financial accounts," so an
archived group can never have an active member by construction on the
forward path. The only way an unarchive ever meets an archived group is
the reverse sequence: archive an account, then (now that its group has
zero active members) archive the group too, then later try to unarchive
the account. That's a real, reachable case worth handling explicitly
rather than leaving "still valid" as an unspecified escape hatch.

## Goals / Non-Goals

**Goals:** Archiving is reversible for accounts, categories, and
user-created groups; unarchiving an account never leaves it in a group
that's itself archived.

**Non-Goals:** Reversing a closeout transfer (separate, already-posted
journal entry — unarchiving doesn't touch it). Unarchiving a system
group (impossible input — system groups are never archived).

## Decisions

### 1. `archivedAt` cleared; same validations as create
Unarchiving an account or category clears `archivedAt`, subject to the
same validations account/category creation already has (e.g. an account
still needs a valid group membership — satisfied automatically since the
account already has one, transitively unarchived per Decision 2 if
needed).

### 2. Unarchiving an account transitively unarchives its group if needed
If the account's current group is archived, unarchiving the account also
clears that group's `archivedAt` in the same action — no separate
"pick a different group" step, since the group is still the account's
own, correctly-currencied group; it just also needs to stop being
archived. This is the concrete resolution of the original "if... still
valid" phrasing: there's no invalidity condition in the current data
model (a group's currency is fixed at creation and never changes), so
"still valid" always holds — the group can always be unarchived
alongside its account.

### 3. Unarchiving a group directly does not touch its (already-archived) member accounts
Unarchiving a group on its own (not via Decision 2's transitive path)
makes the group available for new/reassigned accounts again but does
not itself unarchive any previously archived accounts that happen to
reference it — that's the account-level action, done independently.

## Risks / Trade-offs

- [Risk] A user expects unarchiving a group to also bring back every
  account that was ever in it. → Mitigation: explicit in Decision 3 and
  the user guide — group and account unarchiving are independent actions
  except for the one transitive case (Decision 2) needed to keep an
  unarchived account from being homeless.
- [Risk] Interaction with other child changes. → See
  household-product-repositioning waves.

## Open Questions

None for v1.
