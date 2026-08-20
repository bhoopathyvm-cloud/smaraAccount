## Context

See proposal.md for why. `settlePendingTransfer` already resolves `foreignTransaction` to `pending.sourceAccountId` and sets `isShortfallComparable` only when `kind == transfer` and the target is the source. Tests in `ledger_repository_test.dart` assert no shortfall and reject a fee category on that path. The ViewModel hides the destination picker for foreign transactions and documents the no-shortfall path. The main spec still says "same-currency shortfall comparison."

Provisional foreign-currency posting puts the category (or known) leg in the transaction's native currency and the Transfers-in-transit leg in that same native amount. Settlement then posts against the financial account in the account's group currency. Those amounts are not comparable.

## Goals / Non-Goals

**Goals:**
- Make the main spec describe the behavior the code and tests already enforce.
- Keep transfer source-settlement shortfall/fee rules unchanged.
- Point comments at the updated spec instead of "corrected during apply."

**Non-Goals:**
- Changing how a foreign-currency transaction is first posted (known-rate vs provisional).
- Changing destination-delivery or source-return rules for `kind == transfer`.
- Re-opening whether a foreign-currency shortfall *should* exist in some other currency — that would be a new capability, not this alignment.

## Decisions

### 1. Spec follows the apply-time correction, not the other way around
Comparing a native-currency provisional amount to an account-currency settlement amount would either invent an FX rate the user never entered or treat two different currencies as one number. The code's no-shortfall path is the only rule that stays inside `foreign-currency-settlement`'s existing "no implied rate" stance. Updating the spec is the Golden Rule #1 fix; changing the code to match the old sentence would introduce a new, unspecified FX comparison.

### 2. Zero settlement stays rejected on this path
A zero destination-delivery or foreign-transaction settlement would flip status to settled without posting an entry that closes Transfers-in-transit. Keep the existing reject. Total loss remains a transfer-to-source concept (settle back for 0 with a fee category).

### 3. No schema or API change
`settlePendingTransfer` already ignores `settledToAccountId` for `foreignTransaction`. This change is spec, comments, and any missing named test — not a new method.

## Risks / Trade-offs

- [Risk] A later implementer "fixes" the code to match an old printout of the spec. → Mitigation: archive this delta into the main spec in the same workflow as any other change; tests already fail if shortfall is applied.
- [Risk] Users expect a shortfall fee when the card-currency charge differs from the receipt. → Mitigation: they settle the account-currency amount as charged, then record any later adjustment as an ordinary income/expense. Document that in a comment on the ViewModel if the user-guide settlement paragraph needs a one-line clarification (user-guide wording is already transfer-centric).

## Migration Plan

None. Behavior is already in production code.

## Open Questions

None.
