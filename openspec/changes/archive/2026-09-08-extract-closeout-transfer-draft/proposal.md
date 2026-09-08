# Proposal: extract-closeout-transfer-draft

## Why
The archived-account closeout dialog held its in-progress state as scattered `StatefulBuilder` locals (`toAccountId`, `transactionDate`, `destinationAmountMinor`), with the closeout currency rules split between the View (`viewModel.isCloseoutCrossCurrency`, clear-on-account-change in `setDialogState`) and the ViewModel/Repository. Architecture cycle 17 pulls those rules into one Flutter-free draft, matching `TransferOrderDraft` / `SettlePendingDraft`.

## What Changes
- Add Flutter-free `lib/domain/transfer/closeout_transfer_draft.dart` with mutable `CloseoutTransferDraft`: destination account + currency snapshots, date, description, destination amount, plus computed `isCrossCurrency`, `hasDestinationAccount`, `destinationAmountForSubmit`, and `setDestinationAccount()`.
- `RegisterView`'s closeout dialog owns one draft; the ViewModel keeps `closeoutSelectedAccount` orchestration.
- Remove the now-dead `RegisterViewModel.isCloseoutCrossCurrency` (its only caller, the dialog, now reads cross-currency from the draft's currency snapshots).
- Structure-only: field visibility, submit gating, and posting behavior unchanged.

## Impact
- Spec: new `closeout-transfer-draft` capability.
- Callers: register closeout dialog only; product behavior unchanged. No Drift schema change; no ADR 0002 conflict (leaf domain module).
