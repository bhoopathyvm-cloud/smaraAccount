## Context

See proposal.md for why. The previous `investment-research-briefs` draft added API keys and in-app model calls. That is integration. The intended product is: tap the name in inventory → browser already sitting in ChatGPT/Claude/Gemini/Meta with a good question. If the user is logged in there, their account does the deep research. SMARA never holds that session.

Depends on `investment-holdings` inventory rows existing.

## Goals / Non-Goals

**Goals:**
- Predefined favourite-tool setting.
- Strong packed prompt (news, downside, upside, not advice).
- Tap name → `url_launcher` (or equivalent) with encoded prompt.
- Copy fallback. Identifiers only.

**Non-Goals:**
- Anthropic/OpenAI/Google HTTP APIs, API keys, stored briefs.
- Scraping or automating the AI site after it opens.
- Sending quantity or cost.
- Quotes (owned by `investment-holdings`).

## Decisions

### 1. Enablement, not integration
No `http` client for AI. No `flutter_secure_storage` keys for this change. Opening a URL is the feature.

### 2. URL templates live in code
Each enum case has a template such as `https://chatgpt.com/?q={prompt}`. If a vendor has no public query URL, that case is copy-only (documented in the picker subtitle). We do not let the user type an arbitrary endpoint.

### 3. Prompt is the product
Same research pack as before, minus "run it ourselves": identify issuer, recent news with dates if known, downside risks, upside drivers, facts vs speculation, no buy/sell/hold, not financial advice. Encode for the query string; keep length reasonable (truncate news-ask boilerplate last if a platform has a URL cap).

### 4. Tap target is the name, not a hidden menu
The inventory row's instrument name is the research control (with a tooltip/hint the first time). Buy/Sell stay separate buttons so research is not confused with a trade.

## Risks / Trade-offs

- [Risk] Vendors change or block `?q=` URLs. → Mitigation: copy fallback; template is a code change.
- [Risk] Prompt in the URL is visible to the OS / history. → Mitigation: identifiers only, no holdings math; same class of data as searching the company name yourself.
- [Risk] User thinks SMARA is the adviser. → Mitigation: not-advice in the prompt and a short hint near the name.

## Migration Plan

Settings key only. No schema. Rollback: revert; unused preference is ignored.

## Open Questions

None. A later change could add in-app APIs if that is ever wanted; it would be a new change, not this one.
