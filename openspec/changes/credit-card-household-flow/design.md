## Context

Checked the current implementation before scoping this: every account
row on Home already renders `balance.displayBalanceMinor` regardless of
asset/liability type, so a credit card's amount owed is already visible
today with zero new code — "Home shows amount owed prominently for
cards" from the original proposal doesn't need an `accounts-home-overview`
delta, only a styling choice for rows where `isCreditCard` is true.
Transfers between any two financial accounts (asset or liability) already
work generically, so "Pay card" needs no new repository method — it's the
existing transfer, pre-filled and labeled.

## Goals / Non-Goals

**Goals:** Card life visible without a new account type; "spent on card"
and "paid the card" both map onto existing mechanics with household
labels.

**Non-Goals:** Statement cycles, due dates, minimum-due tracking, or
interest modeling — this change is a label and a capture-flow default,
not a credit-card-servicing feature (a real "statement cycle" concept
would be a separate, larger change if ever wanted).

## Decisions

### 1. `isCreditCard` is a flag, not a new account type
Mirrors the `holdsInvestments` pattern: a boolean on an existing
liability account, set once at creation, immutable after. No new table,
no new posting shape — a credit card account is, mechanically, an
ordinary liability account.

### 2. "Paid from card" / "Paid from bank" is a capture-flow default, not new validation
The record-transaction screen's financial-account picker is unchanged;
when the user has at least one flagged card, the capture flow surfaces
"Paid from card" and "Paid from bank" as two labeled shortcuts that both
resolve to the same existing account-selection step underneath.

### 3. "Pay card" is a labeled, pre-filled ordinary transfer
Bank → card, using the existing `recordTransfer` unchanged. The only new
behavior is UI: a "Pay card" entry point that pre-selects the card as
the destination and labels the action in household terms, so a user
never has to reason about "transfer" vocabulary to pay down a card.

## Risks / Trade-offs

- [Risk] Users expect statement-cycle/due-date tracking once cards are
  "a thing" in the UI. → Mitigation: explicit Non-Goal; this change adds
  a label and a capture shortcut, not billing-cycle modeling.
- [Risk] Interaction with other child changes. → See
  household-product-repositioning waves.

## Open Questions

None that block apply.
