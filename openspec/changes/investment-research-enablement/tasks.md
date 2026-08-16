## 1. Favourite tool setting

- [ ] 1.1 Predefined enum (ChatGPT, Claude, Gemini, Meta AI, plus any other consumer tool with a known query URL). Persist selection. No API key, no custom URL.
- [ ] 1.2 Settings UI: picker only (`EntityPickerField` or the same shape as the FX provider list).

## 2. Prompt and open-in-browser

- [ ] 2.1 Build the research prompt from name + optional ticker/ISIN only (news, downside, upside, not advice, no buy/sell).
- [ ] 2.2 Tapping the instrument name on an inventory row opens the system browser with the favourite tool's query URL, or copies the prompt if offline / no query URL.
- [ ] 2.3 Unit tests: prompt has identifiers and research asks; prompt omits quantity, cost, account name.
- [ ] 2.4 Widget test: tap name invokes open-URL (mocked) or copy fallback.

## 3. Docs and verification

- [ ] 3.1 User guide: tap name, favourite tool, not an integration, not advice, quotes are a different feature.
- [ ] 3.2 Apply only after `investment-holdings` inventory UI exists.
- [ ] 3.3 `dart analyze` and the new tests.
