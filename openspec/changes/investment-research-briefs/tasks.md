## 1. Settings and secrets

- [ ] 1.1 Settings flag `researchBriefsEnabled`, default false (SharedPreferences, same pattern as FX enable).
- [ ] 1.2 Predefined provider enum (Anthropic, OpenAI, Google). No custom URL field.
- [ ] 1.3 Store/retrieve/delete the selected provider's API key in OS secure storage only; never SQLite.

## 2. Prompt pack and copy

- [ ] 2.1 Build the research prompt from instrument name, optional ticker, optional ISIN only: news, downside risks, possible upside, not-advice, no buy/sell recommendation.
- [ ] 2.2 Copy-prompt action on an instrument; works when research is disabled and when offline; assert the copied text contains no quantity, cost, or account name.

## 3. Optional in-app run

- [ ] 3.1 When enabled and a key exists, Run brief sends only the packed prompt to the selected official API.
- [ ] 3.2 Failure/timeout/offline: StatusBanner, no journal write, copy-prompt still available.
- [ ] 3.3 Persist last brief per instrument in a local table (not journal_entries). Display with a not-advice label.

## 4. Tests and docs

- [ ] 4.1 Unit tests: prompt contains identifiers and disclaimer; prompt omits quantity/cost/account fields.
- [ ] 4.2 Tests: disabled-by-default makes no HTTP call; copied prompt still works.
- [ ] 4.3 Tests: a mock in-app run's request body has no ledger amounts; a failed run does not post a journal entry.
- [ ] 4.4 User-guide section: copy-prompt, optional keys, identifiers only, not advice, not a dealing feature.
- [ ] 4.5 Run `dart analyze` and the new tests.

## 5. Dependency

- [ ] 5.1 Apply only after `investment-holdings` has instruments in the UI; do not ship research against a missing holdings screen.
