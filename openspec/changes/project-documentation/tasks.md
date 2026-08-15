## 1. User guide

- [x] 1.1 Re-verify the current feature set against `lib/ui/app_router.dart` and `lib/ui/features/*` at write time (don't rely on this proposal's snapshot — features may have changed since)
- [x] 1.2 Write `docs/user-guide.md`: onboarding & the signing identity (recovery phrase, keystore export, confirmation) with the lost-key tradeoff explained up front
- [x] 1.3 Write sections: base currency setup, restore on a new device/reinstall, home screen, recording a transaction, categories, accounts & account groups (incl. multi-currency)
- [x] 1.4 Write sections: transfers (same-currency, cross-currency, upfront fee, deducted-fee mode, pending/settlement)
- [x] 1.5 Write sections: statement import (OFX, CSV, column mapping, saved import profiles)
- [x] 1.6 Write sections: register & running balance, summary screen, settings (reference exchange rate lookup + provider)
- [x] 1.7 Cross-check every written section against the actual running app (or at minimum the relevant view/view-model source) for accuracy

## 2. Contributor guide

- [x] 2.1 Write `CONTRIBUTING.md` at the repo root: OpenSpec propose → apply → archive workflow, branch-per-change convention, no-direct-commits-to-`main` rule, PR submission process
- [x] 2.2 Link `CONTRIBUTING.md` to `Specs/architecture/smara-architecture.md` and `Specs/architecture/smara-tech-guidelines.md` for architecture/engineering rules, without restating their content

## 3. README updates

- [x] 3.1 Expand README's "Contributing" section to link to `CONTRIBUTING.md`
- [x] 3.2 Add a "Usage" section/link pointing to `docs/user-guide.md`

## 4. Verify

- [x] 4.1 Every link between `README.md`, `CONTRIBUTING.md`, `docs/user-guide.md`, and the `Specs/architecture/` docs resolves to a real file/path
- [x] 4.2 No described feature is actually unimplemented (spot-check against `openspec/specs/` and `openspec/changes/` — anything still only a proposal is excluded from the user guide)
