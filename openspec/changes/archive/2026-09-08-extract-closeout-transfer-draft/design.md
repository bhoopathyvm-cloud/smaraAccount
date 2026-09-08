## Decisions
1. Structure, not behavior. The submit button keeps its existing gate
   (enabled once a destination account is chosen: `hasDestinationAccount`).
   The cross-currency "requires a known destination amount" rule stays
   enforced by `AccountRepository.recordArchivedAccountCloseoutTransfer`
   (which throws `closeoutRequiresDestinationAmount`); the draft does not
   pre-disable submit on it, so the error path is unchanged. Making it a
   proactive draft-level gate would change user-visible behavior and is out
   of scope for a structure-only cycle.
2. `destinationAmountForSubmit` centralizes the "amount only for a
   cross-currency closeout" rule that was an inline `isCrossCurrency ? … :
   null` at the call site.
3. Currency detection moves from `RegisterViewModel.isCloseoutCrossCurrency`
   onto the draft's `sourceCurrency`/`destinationCurrency` snapshots. The
   dialog supplies those via the existing `RegisterViewModel.currencyFor`
   lookup, so the account→group currency seam is unchanged; the dead VM
   method is removed in this change (Golden Rule #9).
