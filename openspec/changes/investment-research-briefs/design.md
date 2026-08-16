## Context

See proposal.md for why. This change depends on `investment-holdings` (instruments exist). Architecture still says the app has no server and no telemetry. The one shipped network exception is opt-in FX lookup that sends *only* currency codes. Research must be at least that strict, and stricter on secrets: API keys go in OS secure storage, like the signing key, not SharedPreferences.

We cannot honestly "log into" Claude.ai, ChatGPT, Gemini, or Meta AI. Those are browser/app sessions. Claiming deep research *because the user has a Plus account* only works if *they* paste the prompt into that session. In-app run is the official API with *their* key — a different product surface than the consumer chat.

## Goals / Non-Goals

**Goals:**
- A strong, reusable prompt pack (news, downside, upside, not-advice).
- Copy-prompt with zero network, identifiers only.
- Optional in-app run: predefined official APIs, user-owned keys, default off.
- Local last-brief cache that is not on the hash chain.

**Non-Goals:**
- Scraping or automating consumer chat UIs.
- Custom endpoint URLs or SMARA-hosted proxy.
- Sending the portfolio, quantities, or cost basis to any model.
- Live prices, trade ideas presented as recommendations, or auto-trading.
- Meta/Llama in-app API in v1 (copy-prompt only).
- Implementing holdings (owned by `investment-holdings`).

## Decisions

### 1. Copy-prompt is the real "use my ChatGPT/Claude/Gemini/Meta account" path
The app shows Copy prompt and a one-line hint: paste into the tool you already use; a paid/consumer session there may browse and go deeper. That is the only honest integration with consumer accounts.

### 2. In-app providers are official APIs only
Fixed enum, e.g. `anthropic`, `openai`, `google`. Each mapping lives in code (model id, URL). No user-supplied base URL (avoids turning the app into an open proxy). Keys in `flutter_secure_storage`. Enable flag in SharedPreferences, default false — same split as FX (non-secret flag) vs signing key (secret).

**Alternative considered:** one "bring any OpenAI-compatible URL" field. Rejected — it is a custom endpoint, which the FX spec already forbids for the same class of setting, and it is an easy exfiltration footgun.

### 3. Payload is the prompt, not the ledger
Build the same string copy-prompt uses. HTTP body is that string plus the provider's required wrapper. No account ids, no quantities, no costs. If we later want "deeper" in-app research, the user can *optionally* tick "include my quantity" in a *future* change; v1 has no such tick.

### 4. Briefs are cache, not journal
`instrument_research_briefs` (instrument_id, retrieved_at, provider, body_text). Overwrite last brief per instrument. Never `_appendSignedEntry`. Deleting a brief is allowed (it is not a posted entry).

### 5. Prompt content (normative enough to implement, not a marketing page)
The packed prompt SHALL instruct the model to:
- Identify the company/issuer from name/ticker/ISIN
- Summarize recent material news (with dates if known)
- List downside risks that could pressure the price
- List possible upside drivers
- Separate facts from speculation
- Refuse to give a buy/sell/hold recommendation
- Say it is not financial advice and may be wrong or stale

### 6. Failure is silent on the ledger
Timeouts, 401, offline: show a banner, keep copy-prompt. Do not block holdings UI.

## Risks / Trade-offs

- [Risk] Users think SMARA is giving advice. → Mitigation: disclaimer on copy, run, and stored brief; prompt forbids recommendations.
- [Risk] A key in secure storage is still a secret on a shared device. → Mitigation: same threat model as the signing key; no cloud backup of the API key by us.
- [Risk] Provider APIs change or require paid accounts. → Mitigation: copy-prompt still works; in-app run is best-effort like FX.
- [Risk] Models hallucinate news. → Mitigation: prompt asks for dates and uncertainty; UI says it can be wrong; we do not treat a brief as a mark or a price.

## Migration Plan

Additive table + settings keys. No journal migration. Rollback: revert; leftover brief rows are unused.

## Open Questions

None that block apply. A later change could add an official Meta/Llama API case or an explicit "include quantity" opt-in.
