## Why

The project has no user-facing "how to use this app" guide at all, and its
existing, genuinely thorough architecture/engineering-discipline docs
(`Specs/architecture/smara-architecture.md`,
`Specs/architecture/smara-tech-guidelines.md`) live in a location a human
contributor browsing the repo on GitHub is unlikely to find — they aren't
linked from `README.md`, and there's no root-level `CONTRIBUTING.md`
(the location GitHub itself surfaces automatically in PR/issue-creation
flows). README's own "Contributing" section is three bullet points and
doesn't mention either doc exists. Two different audiences — someone
trying to use the app, and someone trying to contribute to it — currently
have nowhere to start.

## What Changes

- Add a user guide (`docs/user-guide.md`) covering the app end to end:
  onboarding and the device signing identity (recovery phrase, keystore
  export, why a lost key can't be recovered), setting up accounts and
  account groups (including multi-currency), categories, recording
  transactions, transfers (same- and cross-currency, upfront fees,
  deducted-fee mode, pending/settlement), importing bank statements
  (OFX and CSV, column mapping, saved import profiles), the register and
  running balance, the summary screen, settings (reference exchange rate
  lookup), and restoring the ledger on a new device or reinstall.
- Add a root-level `CONTRIBUTING.md` that is the actual discoverable entry
  point for contributors: the OpenSpec propose → apply → archive workflow,
  the branch-per-change and no-direct-commits-to-main rules already stated
  in `README.md`, the PR process, and a summary of/link to the existing
  Golden Rules in `smara-tech-guidelines.md` — written to point to and
  lean on the existing architecture docs rather than duplicate their
  content.
- Update `README.md`'s "Contributing" section to link to the new
  `CONTRIBUTING.md`, and add a "Usage" link to the new user guide.
- Do not rewrite or relocate `Specs/architecture/smara-architecture.md` or
  `smara-tech-guidelines.md` — they're accurate and current; this change
  makes them (and a new user guide) actually reachable.

## Capabilities

### New Capabilities
- `user-guide`: an accurate, complete end-user guide to using the app's
  features.
- `contributor-guide`: a discoverable, root-level entry point explaining
  how to propose and submit a contribution, and where the architecture
  and engineering-discipline rules that govern it live.

### Modified Capabilities

(none — documentation only, no application behavior changes)

## Impact

- New: `docs/user-guide.md`, `CONTRIBUTING.md`
- Modified: `README.md` (Contributing section, new links)
- No code, schema, or dependency changes.
