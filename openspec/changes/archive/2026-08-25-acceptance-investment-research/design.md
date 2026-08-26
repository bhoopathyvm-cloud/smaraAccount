## Context

`investment-research-enablement` shipped as tap-instrument-name →
favourite consumer AI site with a packed prompt (no API key, no custom
URL). Coverage today is unit tests for prompt construction and one
`HoldingsView` widget test that injects `launchUrlFn`. Nothing walks
Settings → favourite tool → holdings tap on the real `SmaraAccountingApp`
tree.

This change adds a small independently runnable acceptance file. It
depends on harness helpers from `acceptance-investment-holdings` to
create an account and a holding through the GUI, but is a separate
capability because research is a separate product spec.

## Goals / Non-Goals

**Goals:**
- Prove the favourite-tool setting is a fixed predefined list on the
  real Settings screen.
- Prove tapping an instrument name on real holdings launches the
  research path (browser URL or clipboard fallback) with identifiers
  and research asks, and without quantity, cost, or account name.

**Non-Goals:**
- Asserting that a particular third-party site rendered the prompt
  (no control of ChatGPT/Claude/etc.).
- API keys, custom URLs, or in-app model calls (the product forbids
  them; the test only checks they are absent from Settings).
- Investment cash/buy/sell/dividend math (owned by
  `acceptance-investment-holdings`).
- Offline-vs-online branching beyond what the live binding can
  observe (see Decision 2).

## Decisions

### Decision 1 — Separate file, shared setup helpers

`integration_test/acceptance/investment_research_test.dart` reuses
`createInvestmentAccountThroughGui` and a buy helper from the holdings
change rather than copying onboarding/create-account steps. If that
helper is not merged yet, this file may inline the same steps
temporarily; it MUST NOT call repository methods to seed a holding.

### Decision 2 — Observe launch without a real browser

`HoldingsViewModel` already accepts an optional `launchUrlFn` for
tests. The real app path uses `url_launcher`. Options:

**A.** Production-only launcher; acceptance asserts clipboard fallback
by forcing a failing launch (hard on a real device that can open
URLs).

**B.** Keep `launchUrlFn` as a constructor override only in widget
tests; acceptance cannot inject it because `app_router.dart`
constructs `HoldingsViewModel` without the override.

**C.** Record the launched URI via a tiny test hook that the
acceptance file registers before pumping the app (e.g. a static
or `ValueNotifier` the production `launchUrlFn` writes to when a
debug/test flag is set).

**Decision: B for widget tests (already done), and for acceptance:
assert what the live binding can see.** Preferred observation:

1. After tap, if a URL launch can be intercepted in-process, assert
   query contents.
2. Otherwise assert the clipboard contains the research prompt
   (the product's documented fallback) using `Clipboard.getData`.

Do **not** add a `lib/` test seam unless (1) and (2) both fail on
macOS during implementation. If a seam is required, it MUST default
to `url_launcher` in production and only capture URIs when the
acceptance file installs a listener — no change to user-visible
behavior.

**Alternative considered:** Patrol/`NativeAutomator` to watch the
browser. Rejected; parent suite explicitly stayed on
`integration_test` without new native drivers.

### Decision 3 — Settings assertions

Open Settings, find the favourite-research-tool dropdown, assert the
visible labels include ChatGPT, Claude, Gemini, and Meta AI, and that
no field labeled as API key or custom URL exists. Select Claude (or
any second tool) and persist across a Settings pop and re-open if
cheap; otherwise selecting once is enough.

## Risks / Trade-offs

- **[Risk]** Real `url_launcher` opens an external browser and the
  test never sees the URI → **Mitigation:** Decision 2 clipboard
  fallback / optional capture hook.
- **[Risk]** Holdings helpers not landed yet → **Mitigation:** this
  change can be applied after `acceptance-investment-holdings`;
  tasks call that out.
- **[Trade-off]** Prompt wording is asserted as substrings (news,
  downside, not advice, name/ticker) rather than exact golden text,
  so copy edits do not break acceptance.

## Migration Plan

Additive tests only.

## Open Questions

- Whether macOS `url_launcher` in `flutter test -d macos` actually
  invokes the system browser or no-ops; settle in implementation
  (clipboard vs capture hook).
