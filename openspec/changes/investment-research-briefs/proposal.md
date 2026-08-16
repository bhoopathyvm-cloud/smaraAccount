## Why

Once a user can record what they hold (`investment-holdings`), they still
have no in-app way to think about *those companies* — latest news,
downside risks, possible upside — without leaving the app and starting
from a blank chat. Consumer AI tools they already pay for (Claude,
ChatGPT, Gemini, Meta AI, and others) are good at that briefing work.
SMARA should not become a research vendor or a shadow brokerage. It
should hand those tools a strong, privacy-preserving prompt, and
optionally run it with a key the user already owns.

## What Changes

- Add an optional **research brief** flow on an instrument: recent news,
  downside risks if the price falls, and possible upside — always labeled
  as not financial advice and not a price feed.
- **Copy-prompt is the default and always works offline.** The app builds
  a packed prompt from the instrument's name, ticker, and optional ISIN
  only. The user pastes it into Claude, ChatGPT, Gemini, Meta AI, or any
  other consumer chat they already use. That is how "I have an account
  with that tool" becomes deeper research: *their* session, *their*
  browsing, not SMARA logging into it.
- **Optional in-app run**, disabled by default: the user picks a
  predefined provider (Anthropic, OpenAI, Google) and stores *their own*
  API key in OS secure storage. SMARA calls that API with the same
  prompt. There is no SMARA server, no SMARA-held key, and no custom
  endpoint URL.
- A request SHALL transmit only instrument identifiers (name, ticker,
  ISIN). It SHALL NOT include quantities, costs, account names, balances,
  or other ledger contents — the same discipline as reference FX lookup.
- Meta AI and any tool without a stable official consumer API in this
  set remain **copy-prompt only** in this change. No unofficial session
  scraping.
- Out of scope: live quotes, trade recommendations, auto-trading,
  uploading the portfolio for "portfolio advice," and logging into
  claude.ai / chatgpt.com / gemini.google.com on the user's behalf.

## Capabilities

### New Capabilities

- `investment-research-briefs`: copy-prompt packs, optional user-owned
  API runs, local brief storage, and the privacy/advice constraints for
  instrument research.

### Modified Capabilities

- `user-guide`: document the research flow, the copy-prompt path, the
  optional API-key path, and that briefs are not advice.

## Impact

- Settings: research enable flag (default off), predefined provider
  list, per-provider API key in `flutter_secure_storage` (not SQLite).
- Holdings / instrument UI: Copy prompt; optional Run brief when
  research is enabled and a key exists.
- Local cache table for the last brief per instrument (not on the
  journal hash chain).
- Network only when the user explicitly runs a brief with a stored key.
- Depends on `investment-holdings` having shipped (instruments exist).
