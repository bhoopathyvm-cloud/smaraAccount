## Why

From the inventory list, the user should be able to tap an instrument
name and continue research in a consumer AI tool they already use
(Claude, ChatGPT, Gemini, Meta AI, or similar). That is **enablement,
not integration**: SMARA does not call those products' APIs, does not
store API keys, and does not log into the user's AI account. It opens
the system browser with a strong, pre-filled research prompt. If the
user is signed in to that tool, *their* session does the deeper work.

## What Changes

- Settings: pick a **favourite AI web tool** from a predefined list
  (ChatGPT, Claude, Gemini, Meta AI, and other consumer pages this app
  knows how to open). No custom URL, no API key field.
- On an inventory row, tapping the **instrument name** opens the
  external browser at that tool with the research prompt already in the
  query (URL-encoded). Offline or if the tool cannot take a query
  parameter, the same prompt is copied so the user can paste it.
- The prompt is written to elicit useful research: recent news, downside
  risks if the price falls, possible upside, facts vs speculation, and an
  explicit "not financial advice / do not recommend buy or sell" rule.
- The prompt and URL SHALL include the instrument name and optional
  ticker/ISIN only — never quantity, cost, account name, or balances.
- Out of scope: in-app model calls, API keys, scraping chat UIs,
  storing AI replies, live quotes (owned by `investment-holdings`).

## Capabilities

### New Capabilities

- `investment-research-enablement`: favourite-tool setting, packed
  research prompt, tap-name-to-browser (copy fallback), privacy and
  not-advice rules.

### Modified Capabilities

- `user-guide`: document tap-to-browser research, the favourite-tool
  setting, and that this is not an AI integration and not advice.

## Impact

- Settings: favourite AI tool enum (SharedPreferences, not secrets).
- Holdings inventory list: instrument name is the research action.
- `url_launcher` (or equivalent already available) to open the browser.
- No new network client for AI; no secure-storage keys for this change.
- Depends on `investment-holdings` inventory UI.
