# Research: AI hallucination, sycophancy, and why the human must challenge

Research notes for a planned short blog post. Gathered 2026-10-01. Not the
post itself. Quotes marked **verified** were read at the primary source (or
the publisher's own page/PDF). **Secondary** means the claim was confirmed
only through a reputable secondary report or metadata service.
**UNVERIFIED** means it could not be checked at the primary source.

---

## 1. Question and scope

The planned post argues:

1. AI can be confidently wrong ("hallucination") and can reinforce your own
   unchallenged assumptions (sycophancy).
2. Human challenge made the Smara Account design better.
3. AI is an amplifier (like an aircraft for travel, or machinery in
   construction), not a replacement.
4. Never trust it blindly: ask for sources and validate them.
5. The human makes the final decision once the facts convince them.

Part A collects external primary sources. Part B collects the story from
this repo's git history (recovery phrase, keystore, device migration
bundle, ADR 0004), plus a second, smaller example (the "exactly two
postings" glossary error).

---

## 2. Key findings

- **Hallucination is a known, explained failure mode, not a rare glitch.**
  OpenAI's own paper says models "sometimes guess when uncertain, producing
  plausible yet incorrect statements instead of admitting uncertainty", and
  that this happens because "training and evaluation procedures reward
  guessing over acknowledging uncertainty." ([Kalai et al. 2025](#oai),
  verified.)
- **Models tend to agree with you.** Anthropic's sycophancy paper: "both
  humans and preference models prefer convincingly-written sycophantic
  responses over correct ones." ([Sharma et al. 2023](#syco), verified.)
- **Trusting the tool more makes people think less.** Lee et al. (CHI
  2025): "higher confidence in GenAI is associated with less critical
  thinking, while higher self-confidence is associated with more critical
  thinking." ([Lee et al. 2025](#lee), verified.) NIST calls this
  "automation bias, or excessive deference to automated systems."
  ([NIST AI 600-1](#nist), verified.)
- **The aircraft analogy holds, and it comes with a warning.** The FAA
  says autopilots "have improved safety and workload management", but
  "continuous use of autoflight systems could lead to degradation of the
  pilot's ability to quickly recover the aircraft from an undesired
  state." ([FAA SAFO 13002](#faa), verified.)
- **Unverified AI output has real consequences, and the human stays
  accountable.** In Mata v. Avianca the court wrote that "there is nothing
  inherently improper about using a reliable artificial intelligence tool"
  but "existing rules impose a gatekeeping role on attorneys", and imposed
  a $5,000 penalty. ([Mata v. Avianca](#mata), verified.)
- **AI amplifies what is already there.** DORA 2025: "AI doesn't fix a
  team; it amplifies what's already there." ([DORA 2025](#dora),
  verified.)
- **In this repo:** the AI-co-authored initial plan (2026-07-18) made a
  24-word recovery phrase an "unskippable", mandatory onboarding step.
  Human challenge (tester complaints, then a grilling session) demoted it
  to optional (2026-09-22) and then removed the phrase and keystore
  entirely in ADR 0004 (2026-10-01). See [Part B](#part-b).

---

## 3. Part A: primary sources

Ranked by strength for this post. Eight kept, plus one supporting.

### A1. OpenAI, "Why Language Models Hallucinate" (2025) {#oai}

- **Source:** Kalai, Nachum, Vempala, Zhang. Paper PDF:
  https://cdn.openai.com/pdf/d04913be-3f6f-4d2b-b283-ff432ef4aaa5/why-language-models-hallucinate.pdf
  (blog page https://openai.com/index/why-language-models-hallucinate/
  returned HTTP 403 to the fetcher; the PDF was read directly).
- **Date:** September 4, 2025 (date on the PDF).
- **Quotes (verified, from the abstract and introduction):**
  - "Like students facing hard exam questions, large language models
    sometimes guess when uncertain, producing plausible yet incorrect
    statements instead of admitting uncertainty."
  - "language models hallucinate because the training and evaluation
    procedures reward guessing over acknowledging uncertainty"
  - "Language models are known to produce overconfident, plausible
    falsehoods, which diminish their utility."
- **Takeaway:** The model is trained to give an answer, not to say "I don't
  know", so a confident tone tells you nothing about whether it is right.

### A2. NIST AI 600-1, Generative AI Profile (2024) {#nist}

- **Source:** https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf
- **Date:** July 2024.
- **Quotes (verified):**
  - "Confabulation: The production of confidently stated but erroneous or
    false content (known colloquially as "hallucinations" or
    "fabrications") by which users may be misled or deceived."
  - "humans may over-rely on GAI systems or may unjustifiably perceive GAI
    content to be of higher quality than that produced by other sources.
    This phenomenon is an example of automation bias, or excessive
    deference to automated systems. Automation bias can exacerbate other
    risks of GAI, such as risks of confabulation"
- **Takeaway:** A US standards body lists "confidently stated but false"
  output and over-reliance on it as named risks.

### A3. Anthropic, "Towards Understanding Sycophancy in Language Models" (2023) {#syco}

- **Source:** Sharma, Tong, Korbak, Duvenaud, Askell, et al.
  https://arxiv.org/abs/2310.13548
- **Date:** v1 submitted October 20, 2023 (v4 May 10, 2025).
- **Quotes (verified, abstract):**
  - "human feedback may also encourage model responses that match user
    beliefs over truthful ones, a behaviour known as sycophancy."
  - "when a response matches a user's views, it is more likely to be
    preferred. Moreover, both humans and preference models prefer
    convincingly-written sycophantic responses over correct ones."
- **Takeaway:** If you bring a wrong assumption, the AI is more likely to
  polish it than to push back, so you must be the one who pushes back.

### A4. Lee et al., "The Impact of Generative AI on Critical Thinking" (CHI 2025) {#lee}

- **Source:** Lee, Sarkar, Tankelevitch, Drosos, Rintel, Banks, Wilson
  (Carnegie Mellon University and Microsoft Research). PDF:
  https://www.microsoft.com/en-us/research/wp-content/uploads/2025/01/lee_2025_ai_critical_thinking_survey.pdf
  Publication page:
  https://www.microsoft.com/en-us/research/publication/the-impact-of-generative-ai-on-critical-thinking-self-reported-reductions-in-cognitive-effort-and-confidence-effects-from-a-survey-of-knowledge-workers/
- **Date:** CHI 2025, April 2025 (PDF posted January 2025).
- **Quote (verified, publication page; same finding in the PDF abstract):**
  "higher confidence in GenAI is associated with less critical thinking,
  while higher self-confidence is associated with more critical thinking."
- **Supporting detail (secondary, from search summary, not re-read):**
  survey of 319 knowledge workers, 936 examples; GenAI shifts work "from
  doing tasks to supervising tasks".
- **Takeaway:** The more you trust the tool, the less you check it; your
  own domain confidence is what keeps you thinking.

### A5. FAA SAFO 13002, "Manual Flight Operations" (2013) {#faa}

- **Source:** https://www.faa.gov/sites/faa.gov/files/other_visit/aviation_industry/airline_operators/airline_safety/SAFO13002.pdf
- **Date:** 1/4/13 (January 4, 2013).
- **Quotes (verified, PDF downloaded and read):**
  - "Autoflight systems are useful tools for pilots and have improved
    safety and workload management, and thus enabled more precise
    operations."
  - "Unfortunately, continuous use of those systems does not reinforce a
    pilot's knowledge and skills in manual flight operations."
  - "continuous use of autoflight systems could lead to degradation of the
    pilot's ability to quickly recover the aircraft from an undesired
    state."
- **Takeaway:** Supports the aircraft analogy both ways: automation makes
  you faster and safer, but the pilot must keep the skill to take over.

### A6. Mata v. Avianca, Opinion and Order on Sanctions (S.D.N.Y. 2023) {#mata}

- **Source:** Case 1:22-cv-01461-PKC, Document 54, Judge P. Kevin Castel.
  PDF copy hosted by the U.S. District Court for New Hampshire:
  https://www.nhd.uscourts.gov/sites/default/files/pdf/Mata-v-Avianca-sanctions-order.PDF
  Docket: https://www.courtlistener.com/docket/63107798/mata-v-avianca-inc/
- **Date:** Filed 06/22/23 (June 22, 2023).
- **Quotes (verified, from the PDF):**
  - "Technological advances are commonplace and there is nothing
    inherently improper about using a reliable artificial intelligence
    tool for assistance. But existing rules impose a gatekeeping role on
    attorneys to ensure the accuracy of their filings."
  - Respondents "abandoned their responsibilities when they submitted
    non-existent judicial opinions with fake quotes and citations created
    by the artificial intelligence tool ChatGPT, then continued to stand by
    the fake opinions after judicial orders called their existence into
    question."
  - "A penalty of $5,000 is jointly and severally imposed on" Respondents.
- **Takeaway:** Using AI is fine; not checking it is not. The human who
  signs is responsible.

### A7. DORA 2025, State of AI-assisted Software Development {#dora}

- **Source:** Google Cloud blog, "Announcing the 2025 DORA Report", Nathen
  Harvey and Derek DeBellis:
  https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report
  Report hub: https://dora.dev/dora-report-2025/
- **Date:** September 23, 2025.
- **Quotes (verified, blog page):**
  - "AI doesn't fix a team; it amplifies what's already there."
  - "Strong teams use AI to become even better and more efficient.
    Struggling teams will find that AI only highlights and intensifies
    their existing problems."
  - Section heading: "AI, the great amplifier".
- **Takeaway:** AI multiplies whatever judgment you bring; it does not
  supply the judgment.

### A8. Anthropic guidance: verify, cite, allow "I don't know" {#anth}

- **Source 1:** Claude Help Center, "Claude is providing incorrect or
  misleading responses. What's going on?"
  https://support.claude.com/en/articles/8525154-claude-is-providing-incorrect-or-misleading-responses-what-s-going-on
  (old support.anthropic.com URL redirects here).
- **Date:** updated March 16, 2026 (as reported by the fetcher).
- **Quotes (verified):**
  - "Claude can occasionally produce responses that are incorrect or
    misleading. This is known as 'hallucinating' information"
  - "Users should not rely on Claude as a singular source of truth and
    should carefully scrutinize any high-stakes advice"
  - "Claude can write things that might look correct but are very mistaken"
- **Source 2:** Claude Platform docs, "Reduce hallucinations":
  https://platform.claude.com/docs/en/test-and-evaluate/strengthen-guardrails/reduce-hallucinations
  (no date on page).
- **Quotes (verified):**
  - "Allow Claude to say "I don't know": Explicitly give Claude permission
    to admit uncertainty."
  - "Verify with citations: Make Claude's response auditable by having it
    cite quotes and sources for each of its claims. ... If it can't find a
    quote, it must retract the claim."
  - "while these techniques significantly reduce hallucinations, they don't
    eliminate them entirely. Always validate critical information,
    especially for high-stakes decisions."
- **Takeaway:** The vendor itself says: ask for sources, check them, and
  do not treat the model as the final word.

### A9 (supporting). METR 2025 perception gap {#metr}

- **Source:** https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/
- **Date:** July 10, 2025.
- **Quotes (verified, blog page):** "when developers are allowed to use AI
  tools, they take 19% longer to complete issues"; developers "expected AI
  to speed them up by 24%" and afterwards "still believed AI had sped them
  up by 20%".
- **Takeaway:** How it feels and what is true can differ; measure, don't
  assume. (Use sparingly: a small study, 16 developers, early-2025 tools.)

### A10 (supporting). Parasuraman and Manzey (2010) {#pm}

- **Source:** "Complacency and Bias in Human Use of Automation: An
  Attentional Integration", Human Factors 52(3), 381–410,
  https://doi.org/10.1177/0018720810376055
- **Date:** June 2010.
- **Status:** citation metadata **secondary** (Semantic Scholar API and
  search result; abstract elided by publisher, PubMed page blocked by a
  cookie wall). Commonly cited finding that complacency and automation
  bias occur in both novices and experts and are not prevented by simple
  training or instructions: **UNVERIFIED**, do not quote.
- **Takeaway:** Classic human-factors grounding for "automation bias";
  cite by title only unless the abstract is checked.

---

## 4. Part B: the story in this repo {#part-b}

All facts from `git log` / `git show` in this repository, read-only.

### B1. Recovery phrase: mandatory, then optional, then removed

| Date | Commit | What happened | AI co-author trailer |
|---|---|---|---|
| 2026-07-18 | `f935a10` | Initial scaffold + OpenSpec planning. `ledger-integrity-signing/proposal.md` says onboarding shows a BIP-39 recovery phrase "shown once with unskippable messaging" and "Introduces onboarding steps (key generation, mandatory recovery-phrase acknowledgment) ahead of first ledger use." | `Co-Authored-By: Claude Sonnet 5` |
| 2026-07-18 | `6bb83b1` | Implements signing: "an Ed25519 device signing identity (generated from a BIP-39 recovery phrase, private key held only in OS secure storage)". | none in trailer |
| 2026-07-19 | `203f468` | "Onboarding UI: recovery-phrase setup, keystore export, restore flow": RecoveryPhraseView, RecoveryPhraseConfirmView ("re-enter 3 words"), KeystoreExportView, RestoreIdentityView; router "gates every route" until onboarded. | none in trailer |
| 2026-07-19 | `2861ba2` | True key-loss migration UI (re-signs history under a new key). | none in trailer |
| 2026-08-18 → 08-20 | `578ca75`, `a70119b`, archived as `2026-08-20-deferred-onboarding-first-entry` | "Twenty-four words before the first rupee makes most people bounce." The phrase moves to *after* the first entry, but is still "the mandatory Protect this ledger (recovery phrase) flow". | `a70119b`: Claude Sonnet 5 |
| 2026-09-09 | `f34bb4d` | Onboarding language selection incl. "partial BIP39 localization" (more investment in the phrase). | Claude Sonnet 5 |
| 2026-09-22 | `19afb33` / PR `c71e743` | Ship `device-migration-bundle`. Proposal: "Testers are complaining about this wall"; "**BREAKING**: Remove the mandatory, blocking recovery-phrase acknowledgment flow"; phrase "demoted from mandatory to one of several optional backup choices". Adds a combined migration bundle (key + data). | `Co-authored-by: Cursor` |
| 2026-10-01 | `803c827` (PR #203) | ADR `docs/adr/0004-private-key-never-leaves-the-device.md` + `openspec/changes/books-copy-and-continuation`: "the private key never leaves the device"; one Books Copy replaces backup + bundle; phrase and keystore removed. | Claude Opus 5.5 (x3) |

Note on attribution: the July implementation commits (`6bb83b1`,
`203f468`, `2861ba2`) carry no `Co-authored-by` trailer, so git alone does
not prove which lines an AI wrote. The *design* that made the phrase
mandatory is in `f935a10`, which does carry a Claude trailer. Across all
395 commits, AI trailers are common (Claude Sonnet 5 ~219, Cursor ~62,
Claude Opus 5.5 ~21 trailer lines).

Key quotes from the ADR (verified, file in repo):

- "Ordinary users found three key artifacts confusing, a books backup was
  useless without restoring the key separately, and anyone who tapped New
  setup could not bring old books in at all."
- "verifying an entry only needs the public key of the identity that
  signed it, and every copy of the books carries those public keys"
- Rejected option: "Keep the recovery phrase and keystore behind an
  "Advanced" option — rejected: it keeps every confusing path in code and
  support for very few users."
- Trade-off accepted: "a lost or broken phone with no saved copy means the
  books are gone".

`books-copy-and-continuation/proposal.md` opens: moving to a new phone
"means understanding three separate things: a 24-word recovery phrase, a
keystore file, and a device migration bundle." It came from "the
2026-10 grilling session" (project A of three).

**Five-line timeline, plain words:**

1. 18 Jul 2026: the first plan, written with an AI, made every new user
   write down 24 secret words before using the app.
2. 18–20 Aug: we moved those 24 words to after the first entry, but kept
   them mandatory.
3. 22 Sep: testers called it a wall; the words became optional, and a
   one-file "device migration bundle" was added.
4. Late Sep: three ways to carry a key (words, keystore file, bundle)
   still confused ordinary users.
5. 1 Oct: after a human-led grilling session, ADR 0004 decided the key
   never leaves the phone; one "Books Copy" replaces all three.

### B2. Second example: "exactly two postings"

- `1dacec3` (2026-08-28, "domain words realigning", no co-author trailer)
  added `CONTEXT.md` with: "A posted, immutable double-entry entry with
  exactly two Postings" and "Every entry has exactly two, and they sum to
  zero". This was wrong for the app: splits have three or more legs.
- `a1ccf43` (2026-09-09, PR #122, "Sharpen the domain model via
  grill-with-docs (10 rounds)", Cursor Agent trailer) corrected it:
  "correct Journal Entry/Posting from 'exactly two' to 'two or more'
  (splits have 3+ legs) and add the Split term."
- Plain point: a confident, tidy sentence in the glossary stood for twelve
  days until a structured challenge (the grilling rounds) caught it.
- Caution: git does not show whether the "exactly two" sentence was typed
  by the human or generated; describe it as "confident-but-wrong text that
  sat in the glossary", not as proven AI output, unless the author
  remembers otherwise.

---

## 5. Suggested framing for the post (notes, not prose)

- Hallucination (A1, A2) + sycophancy (A3) = the AI can be wrong *and*
  agree with your wrong idea.
- Automation bias (A2, A4, A10) = the risk grows the more you trust it.
- Aircraft (A5) + DORA (A7) = amplifier, not replacement; keep the skill to
  fly by hand.
- Mata (A6) + Anthropic guidance (A8) = ask for sources, check them, the
  human signs off.
- Repo story (B1, B2) = the human challenge that fixed the design.

## 6. Not used / dropped

- OpenAI blog page (403 to fetcher); the paper PDF is the primary anyway.
- NTSB material on automation dependency: not checked; FAA SAFO 13002 is
  enough for the analogy.
- Parasuraman and Manzey abstract wording: not verified (see A10).
