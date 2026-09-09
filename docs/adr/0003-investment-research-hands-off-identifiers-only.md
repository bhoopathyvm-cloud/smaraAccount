# Investment research hands off identifiers only

The Investment Research feature lets a user research an Instrument with a
consumer AI assistant (the Research Tool: ChatGPT, Claude, Gemini, Meta AI).
The Investment Research Prompt is built from the Instrument's identifiers
only — name, ticker, ISIN — and never its quantity, cost basis, or owning
account. It is delivered by opening the tool's public `?q=` query URL, or by
copying the prompt to the clipboard when the tool has no query URL or the
launch fails. The app makes no server-side AI API call and holds no API key.

We decided the identifiers-only rule is a hard privacy boundary, not a
convenience default. A richer prompt (holdings size, gain/loss, which
account) would let an assistant give more tailored answers, but it would
also hand a third party a picture of the user's finances — exactly the
household-books-on-one-device promise SMARA makes. Handing off only what
publicly identifies the security keeps research useful without turning an
optional assistant into a data-exfiltration path. Delivery over a URL /
clipboard (rather than a direct API) keeps the boundary inspectable: what
leaves the device is the visible query the user can read before sending.

This trades tailored analysis for a boundary that survives adding new
Research Tools: a new tool is a display name plus an optional `?q=`
template, and cannot widen what data is packed into the prompt, because the
prompt builder never reads holdings in the first place. Any future
"personalized research" idea must reopen this ADR, not quietly extend
`buildInvestmentResearchPrompt`.

Established with `investment-research-enablement`; the identifiers-only
constraint is asserted by the `investment_research` acceptance group and the
`investment_research_prompt` unit tests, and named in `CONTEXT.md`
(Investment Research Prompt).
