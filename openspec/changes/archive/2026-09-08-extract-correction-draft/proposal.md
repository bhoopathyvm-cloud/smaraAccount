# Proposal: extract-correction-draft

## Why
`CorrectionViewModel` still owns Fix-this form rules (direction→category filter, clear-on-direction-change, field readiness) inside Flutter + repositories. After `extract-record-transaction-draft`, Correction is the last money form on the old draft-in-`ChangeNotifier` shape. Architecture review cycle 10.

## What Changes
- Add Flutter-free `CorrectionDraft` at `lib/domain/correction/correction_draft.dart`.
- Thin `CorrectionViewModel` to stream/catalog wiring + `fixPostedTransaction` orchestration.
- Domain unit tests for filter / clear / `canSubmit`; keep VM tests for submit/errors.

## Impact
- Spec: new `correction-draft` capability.
- Callers: Correction VM/view only; product behavior unchanged.
