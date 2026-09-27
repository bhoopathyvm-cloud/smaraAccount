# Research: Ubiquitous language, clean code, and AI coding agents

Research notes for a planned blog post. Gathered 2026-09-27. Not the post
itself. Quotes marked **verified** were read at the primary source (or the
publisher's own page/PDF). **Secondary** means the claim was confirmed only
through a reputable secondary report. **UNVERIFIED** means it could not be
checked at the primary source.

---

## 1. Question and scope

The author wants a post that covers:

1. Domain-driven language in code: using the ubiquitous language so code
   mirrors the domain model.
2. Why keeping code aligned with the domain model matters, and how it
   concretely helped in SMARA Account.
3. Why clean code matters even more when AI writes a lot of the code.
4. How a domain-driven model helps AI coding agents go faster or produce
   better output.
5. Trusted, primary references.

These notes cover external sources (Part A) and evidence from this repo
(Part B). They also check overlap with blog drafts 00–12.

---

## 2. Key findings

- **Evans defines ubiquitous language as a language that must reach the
  code.** It isn't just a meeting vocabulary: "Commit the team to exercising
  that language relentlessly in all communication within the team and in
  the code … Recognize that a change in the language is a change to the
  model … Then refactor the code, renaming classes, methods, and modules to
  conform to the new model." ([Evans, DDD Reference 2015](#evans-ref),
  verified.)
- **Evans ties naming to the ubiquitous language.** In Intention-Revealing
  Interfaces he writes: "These names should conform to the ubiquitous
  language so that team members can quickly infer their meaning." The same
  pattern says "Write a test for a behavior before creating it." ([Evans,
  DDD Reference](#evans-ref), verified.)
- **Thoughtworks names the AI angle directly.** The Technology Radar blip
  "AI-friendly code design" (Assess, April 2025) says "AI coding assistants
  also perform better with well-factored codebases" and "Expressive naming
  provides domain context and functionality." It also says "the best
  AI-friendly patterns align with established best practices."
  ([Thoughtworks Radar](#tw-radar), verified.) Böckeler's context
  engineering article on martinfowler.com points to this blip
  ([Böckeler 2026](#bockeler-ctx), verified).
- **Anthropic's own guidance asks for explicit terminology.** "Consider the
  context that you might implicitly bring—specialized query formats,
  definitions of niche terminology, relationships between underlying
  resources—and make it explicit." ([Anthropic, Writing tools for
  agents](#anth-tools), verified.) Another Anthropic post says "Folder
  hierarchies, naming conventions, and timestamps all provide important
  signals that help both humans and agents" ([Anthropic, Context
  engineering](#anth-ctx), verified).
- **Peer-reviewed and preprint studies show that LLM code performance
  depends on names.**
  - Adversarial method names cut Pass@1 by 32–44% in zero-shot code
    generation ([Yang et al., TOSEM](#yang), verified abstract).
  - Removing names "severely degrades intent-level tasks" ([Le et al.
    2025](#le), verified abstract).
  - Variable renaming dropped average accuracy by 18.6 points ([Nikiema et
    al. 2025](#nikiema), verified in the HTML full text).
- **AI speeds up code creation and can wear down quality unless the
  fundamentals hold.**
  - DORA 2024: a 25% increase in AI adoption goes with an estimated 1.5%
    drop in delivery throughput and a 7.2% drop in stability ([Google
    Cloud / DORA 2024](#dora24), verified).
  - DORA 2025: "AI doesn't fix a team; it amplifies what's already there."
    ([DORA 2025](#dora25), verified.)
  - GitClear: copy/paste overtook moved (refactored) code for the first
    time, and refactoring fell to under 10% of changed lines in 2024
    ([GitClear](#gitclear), verified; correlational).
  - METR: experienced developers on large, mature repos were 19% *slower*
    with early-2025 AI tools but believed they were 20% faster ([METR
    2025](#metr), verified).
- **In this repo, the glossary is a working artifact.**
  - `CONTEXT.md` defines 50+ terms with explicit "_Avoid_" lists.
  - `docs/agents/domain.md:41-45` tells every agent to use those terms and
    treat a missing term as a signal.
  - The glossary's conditions map one-to-one onto code predicates. For
    example, the Correction/Split/Opening Balance/Quarantine/Migration
    definitions become the five conditions of `isRegisterRowFixable`,
    `lib/domain/register/register_row_policy.dart:6-17`.
- **In this repo, vocabulary work caught a real modeling error.**
  - The glossary's first version (commit `1dacec3`, 2026-08-28) said a
    Journal Entry has "exactly two" Postings.
  - Splits had already shipped (`2026-08-20-split-transactions`).
  - A structured grilling session (`a1ccf43`, 2026-09-09) caught this and
    changed it to "two or more".
  - Two code docstrings still say "exactly two" today. That drift is itself
    a story (see §4.6).

---

## 3. External sources

### 3.1 DDD and ubiquitous language

<a id="evans-ref"></a>
**Eric Evans, *Domain-Driven Design Reference: Definitions and Pattern
Summaries*.** Domain Language, Inc., © 2015, CC BY 4.0.
URL: https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf
Status: **verified.** The PDF text was extracted locally and the quotes
below are verbatim.

- *Ubiquitous Language*: "The terminology of day-to-day discussions is
  disconnected from the terminology embedded in the code (ultimately the
  most important product of a software project)." And: "Translation blunts
  communication and makes knowledge crunching anemic."
- *Ubiquitous Language*, Therefore: "Use the model as the backbone of a
  language. Commit the team to exercising that language relentlessly in all
  communication within the team and in the code. Within a bounded context,
  use the same language in diagrams, writing, and especially speech.
  Recognize that a change in the language is a change to the model. Iron
  out difficulties by experimenting with alternative expressions, which
  reflect alternative models. Then refactor the code, renaming classes,
  methods, and modules to conform to the new model."
- *Ubiquitous Language*: "Domain experts should object to terms or
  structures that are awkward or inadequate to convey domain understanding;
  developers should watch for ambiguity or inconsistency that will trip up
  design."
- *Model-Driven Design*: "Tightly relating the code to an underlying model
  gives the code meaning and makes the model relevant. If the design, or
  some central part of it, does not map to the domain model, that model is
  of little value, and the correctness of the software is suspect." And,
  from the Therefore paragraph: "Design a portion of the software system to
  reflect the domain model in a very literal way, so that mapping is
  obvious."
- *Intention-Revealing Interfaces*, Therefore: "Name classes and operations
  to describe their effect and purpose, without reference to the means by
  which they do what they promise. … These names should conform to the
  ubiquitous language so that team members can quickly infer their
  meaning. Write a test for a behavior before creating it, to force your
  thinking into client developer mode."
- *Bounded Context*: "Model expressions, like any other phrase, only have
  meaning in context." Therefore: "Apply Continuous Integration to keep
  model concepts and terms strictly consistent within these bounds."
- *Anticorruption Layer*: "create an isolating layer to provide your system
  with functionality of the upstream system in terms of your own domain
  model." This is relevant to the CSV debit/credit columns in §4.5.

<a id="fowler-ul"></a>
**Martin Fowler, "UbiquitousLanguage"** (bliki, 31 Oct 2006).
URL: https://martinfowler.com/bliki/UbiquitousLanguage.html
Status: **verified** (extracted by WebFetch; confirm exact wording before
quoting).

- The language must be "rigorous, since software doesn't cope well with
  ambiguity."
- "the language (and model) should evolve as the team's understanding of
  the domain grows."

<a id="fowler-bc"></a>
**Martin Fowler, "BoundedContext"** (bliki, 15 Jan 2014).
URL: https://martinfowler.com/bliki/BoundedContext.html
Status: **verified.**

- Fowler's utility example: "meter" meant three different things in three
  departments.
- "these subtle polysemes could be smoothed over in conversation but not in
  the precise world of computers."
- Useful for the "Account" problem in this repo: one word, three kinds of
  row (§4.2).

<a id="fowler-ddd"></a>
**Martin Fowler, "DomainDrivenDesign"** (bliki, 22 Apr 2020).
URL: https://martinfowler.com/bliki/DomainDrivenDesign.html
Status: **verified.**

- Defines DDD as centering "the development on programming a domain model
  that has a rich understanding of the processes and rules of a domain."
- Describes the ubiquitous language as one "that embeds domain terminology
  into the software systems that we build."
- Models "were often only done on paper … DDD stresses doing them in
  software, and evolving them during the life of the software product."

<a id="evans-llm"></a>
**Thomas Betts (InfoQ), "Eric Evans Encourages DDD Practitioners to
Experiment with LLMs"** (18 Mar 2024). Reports Evans's Explore DDD 2024
keynote.
URL: https://www.infoq.com/news/2024/03/Evans-ddd-experiment-llm/
Status: **secondary** (a report of a talk, not Evans's own text).

- Evans reportedly said "a trained language model is a bounded context."
- He also suggested training on "the ubiquitous language of a bounded
  context" to make models "far more useful for specific needs."
- Evans stressed that his remarks were time-sensitive.
- This is the most credible direct DDD–LLM link found. Note that it is
  about fine-tuning models, not about agents reading a glossary, so don't
  overstate it.

### 3.2 Clean code and naming

<a id="clean-code"></a>
**Robert C. Martin (ed.), *Clean Code: A Handbook of Agile Software
Craftsmanship*, Prentice Hall 2009.** Chapter 2, "Meaningful Names", was
written by Tim Ottinger.

Status:
- Section headings are **verified** from the publisher's own sample PDF
  table of contents
  (https://ptgmedia.pearsoncmg.com/images/9780132350884/samplepages/9780132350884.pdf):
  "Use Intention-Revealing Names … 18", "Use Solution Domain Names … 27",
  "Use Problem Domain Names … 27".
- The body text is **not** in the sample. The widely quoted line "The name
  of a variable, function, or class, should answer all the big questions.
  It should tell you why it exists, what it does, and how it is used." is
  **UNVERIFIED verbatim**. Secondary summaries agree on it, but check it
  against a physical or ebook copy before quoting.
- Paraphrase that is safe to use: code about problem-domain concepts should
  take its names from the problem domain.

<a id="ousterhout"></a>
**John Ousterhout, *A Philosophy of Software Design*** (Yaknyam Press; 2nd
ed. 2021), Ch. 14 "Choosing Names".
Status: **secondary only.**

- Several reviews agree that the chapter asks for names that are *precise*
  and *consistent*, and that a good name creates an image of what the
  thing is and is not.
- Attribute it as a paraphrase unless checked in the book.
- The "deep modules" idea is already used in this repo's
  `docs/agents/architecture-deepening.md` via the `codebase-design` skill.

**Vaughn Vernon (*Implementing DDD*, *DDD Distilled*)**: not researched in
this pass. Nothing is claimed from these books.

### 3.3 AI agents and context

<a id="tw-radar"></a>
**Thoughtworks Technology Radar, "AI-friendly code design"** (Techniques,
Assess, Vol. April 2025).
URL: https://www.thoughtworks.com/radar/techniques/ai-friendly-code-design
Status: **verified.**

- "A common justification for this is that human-oriented code quality
  matters less since AI can handle future modifications; however, AI
  coding assistants also perform better with well-factored codebases,
  making AI-friendly code design crucial for maintainability."
- "Fortunately, good software design for humans also benefits AI.
  Expressive naming provides domain context and functionality; modularity
  and abstractions keep AI's context manageable by limiting necessary
  changes; and the DRY (don't repeat yourself) principle reduces duplicate
  code — making it easier for AI to keep the behavior consistent. So far,
  the best AI-friendly patterns align with established best practices."
- This is the single best external anchor for the post's thesis.

<a id="bockeler-ctx"></a>
**Birgitta Böckeler, "Context Engineering for Coding Agents"**
(martinfowler.com, "Exploring Gen AI" series, 05 Feb 2026).
URL: https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html
Status: **verified.**

- "The most basic and powerful context interfaces in coding agents are file
  reading and searching, to understand your current codebase."
- "It's worth reflecting on how well your existing code serves as context,
  basically if you have AI-friendly codebase design." This links to the
  Radar blip above.
- A caveat to include: "As long as LLMs are involved, we can never be
  _certain_ of anything, we still need to think in probabilities and choose
  the right level of human oversight for the job."

<a id="bockeler-harness"></a>
**Birgitta Böckeler, "Harness engineering for coding agent users"**
(martinfowler.com, 02 Apr 2026).
URL: https://martinfowler.com/articles/harness-engineering.html
Status: **verified.**

- "Not every codebase is equally amenable to harnessing. A codebase written
  in a strongly typed language naturally has type-checking as a sensor;
  clearly definable module boundaries afford architectural constraint
  rules."
- On what agents lack: "It doesn't know which convention is load-bearing
  and which is just habit … A coding agent has none of this: no social
  accountability, no aesthetic disgust at a 300-line function, no intuition
  that "we don't do it that way here," and no organisational memory."
- Quotes Ned Letcher on "ambient affordances": "structural properties of
  the environment itself that make it legible, navigable, and tractable to
  agents operating within it."

<a id="anth-tools"></a>
**Anthropic (Ken Aizawa et al.), "Writing effective tools for AI agents —
with agents"** (11 Sep 2025).
URL: https://www.anthropic.com/engineering/writing-tools-for-agents
Status: **verified.**

- "When writing tool descriptions and specs, think of how you would
  describe your tool to a new hire on your team. Consider the context that
  you might implicitly bring—specialized query formats, definitions of
  niche terminology, relationships between underlying resources—and make it
  explicit."
- "input parameters should be unambiguously named: instead of a parameter
  named `user`, try a parameter named `user_id`."
- "merely resolving arbitrary alphanumeric UUIDs to more semantically
  meaningful and interpretable language … significantly improves Claude's
  precision in retrieval tasks by reducing hallucinations."
- Caveat: this is about tool interfaces, not application code. It's an
  analogy for code, not direct evidence about code.

<a id="anth-ctx"></a>
**Anthropic (Rajasekaran, Dixon, Ryan, Hadfield), "Effective context
engineering for AI agents"** (29 Sep 2025).
URL: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
Status: **verified.**

- "Good context engineering means finding the smallest possible set of
  high-signal tokens that maximize the likelihood of some desired outcome."
- "Context, therefore, must be treated as a finite resource with
  diminishing marginal returns."
- "Folder hierarchies, naming conventions, and timestamps all provide
  important signals that help both humans and agents understand how and
  when to utilize information."
- Claude Code "employs this hybrid model: CLAUDE.md files are naively
  dropped into context up front, while primitives like glob and grep allow
  it to navigate its environment and retrieve files just-in-time." This
  explains why this repo keeps `CONTEXT.md` *referenced* from CLAUDE.md
  rather than inlined.

<a id="anth-agents"></a>
**Anthropic (Erik Schluntz, Barry Zhang), "Building effective agents"**
(19 Dec 2024).
URL: https://www.anthropic.com/engineering/building-effective-agents
Status: **verified.**

- "One rule of thumb is to think about how much effort goes into
  human-computer interfaces (HCI), and plan to invest just as much effort
  in creating good agent-computer interfaces (ACI)."
- "Put yourself in the model's shoes."
- "Think of this as writing a great docstring for a junior developer on
  your team."

<a id="anth-bp"></a>
**Anthropic, "Best practices for Claude Code"** (docs page; the old URL
anthropic.com/engineering/claude-code-best-practices now 308-redirects
here; the page is undated).
URL: https://code.claude.com/docs/en/best-practices
Status: **verified.**

- "CLAUDE.md is a special file that Claude reads at the start of every
  conversation. … This gives Claude persistent context it can't infer from
  code alone."
- The Include column lists "Architectural decisions specific to your
  project" and "Common gotchas or non-obvious behaviors".
- The Exclude column lists "Anything Claude can figure out by reading code".
- "For domain knowledge or workflows that are only relevant sometimes, use
  skills instead."
- "LLM performance degrades as context fills."
- Angle: the more the domain is readable *from the code itself*, the less
  has to live in CLAUDE.md. Good names are "free" context.

### 3.4 Empirical data on AI and code quality

<a id="yang"></a>
**Guang Yang, Yu Zhou, Wenhua Yang, Tao Yue, Xiang Chen, Taolue Chen, "How
Important are Good Method Names in Neural Code Generation? A Model
Robustness Perspective."** arXiv 2211.15844 (Nov 2022, rev. Jul 2023);
published in ACM TOSEM (doi 10.1145/3630010).
URL: https://arxiv.org/abs/2211.15844
Status: **verified abstract.**

- "RADAR-Attack can reduce the CodeBLEU of generated code by 19.72% to
  38.74% … and reduce the Pass@1 of generated code by 32.28% to 44.42% …
  in the zero-shot code generation task."
- "These results highlight the importance of good method names in neural
  code generation."
- Caveat: the models tested were 2022–23 models (CodeT5, CodeGen, Replit),
  not current frontier agents, and the names were adversarial, not merely
  "vague".

<a id="wang"></a>
**Zhilong Wang et al., "How Does Naming Affect LLMs on Code Analysis
Tasks?"** arXiv 2307.12488 (Jul 2023, v5 Jul 2024).
URL: https://arxiv.org/abs/2307.12488
Status: **verified abstract.**

- "naming has a significant impact on the performance of code analysis
  tasks based on LLMs, indicating that code representation learning based
  on LLMs heavily relies on well-defined names in code."
- Caveat: most experiments used CodeBERT, plus a GPT case study.

<a id="le"></a>
**Cuong Chi Le et al., "When Names Disappear: Revealing What LLMs Actually
Understand About Code."** arXiv 2510.03178 (3 Oct 2025, preprint).
URL: https://arxiv.org/abs/2510.03178
Status: **verified abstract.**

- "code communicates through two channels: structural semantics, which
  define formal behavior, and human-interpretable naming, which conveys
  intent. Removing the naming channel severely degrades intent-level tasks
  such as summarization, where models regress to line-by-line
  descriptions."
- The authors frame the result as a benchmark concern: models lean on
  names, sometimes as a memorization shortcut. The takeaway for practice is
  still that names carry the intent channel.

<a id="nikiema"></a>
**Serge Lionel Nikiema et al., "The Code Barrier: What LLMs Actually
Understand?"** arXiv 2504.10557 (14 Apr 2025, preprint).
URL: https://arxiv.org/abs/2504.10557
Status: **verified.** The 18.6 figure is in the HTML full text
(https://arxiv.org/html/2504.10557v1), not the abstract.

- "Variable Renaming caused significant performance degradation across
  almost all models. The average accuracy dropped by 18.6 percentage
  points, with some models experiencing declines of over 30 percentage
  points."
- Setup: 13 models including GPT-4o, on 250 Java problems.

<a id="dora24"></a>
**Nathen Harvey and Derek DeBellis, "Announcing the 2024 DORA report"**
(Google Cloud blog, 23 Oct 2024).
URL: https://cloud.google.com/blog/products/devops-sre/announcing-the-2024-dora-report
Status: **verified.** The dora.dev landing page did not show the numbers;
the Google blog did.

- "A 25% increase in AI adoption is associated with … 7.5% increase in
  documentation quality, 3.4% increase in code quality, 3.1% increase in
  code review speed. However … AI adoption may negatively impact software
  delivery performance. As AI adoption increased, it was accompanied by an
  estimated decrease in delivery throughput by 1.5%, and an estimated
  reduction in delivery stability by 7.2%."
- Secondary sources attribute the slowdown to larger batch sizes. That
  explanation is consistent with DORA, but the causal wording wasn't
  checked at the primary source.

<a id="dora25"></a>
**Nathen Harvey and Derek DeBellis, "Announcing the 2025 DORA Report"**
(Google Cloud blog, 23 Sep 2025), plus the DORA "AI-accessible internal
data" capability page (dora.dev, updated 12 Jan 2026).
URLs:
- https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report
- https://dora.dev/capabilities/ai-accessible-internal-data/

Status: **verified.**

- "AI doesn't fix a team; it amplifies what's already there. Strong teams
  use AI to become even better and more efficient. Struggling teams will
  find that AI only highlights and intensifies their existing problems."
- 90% of respondents use AI at work, and 30% report little or no trust in
  AI-generated code.
- AI adoption now correlates positively with throughput, but "continues to
  have a negative relationship with software delivery stability."
- From the capability page: AI-accessible internal data "amplifies the
  positive impact of AI adoption, serving as a statistically significant
  multiplier for individual effectiveness and code quality."
- Also from the capability page: "An AI connected to bad data will only
  produce bad answers ('garbage in, garbage out')." A glossary is exactly
  this kind of internal data.

<a id="gitclear"></a>
**GitClear, "AI Copilot Code Quality: 2025 Data Suggests 4x Growth in Code
Clones."**
URL: https://www.gitclear.com/ai_assistant_code_quality_2025_research
Status: **verified** (vendor research; correlational).

- 211M changed lines, Jan 2020 to Dec 2024.
- Refactoring-associated ("moved") lines "sunk from 25% of changed lines in
  2021, to less than 10% in 2024."
- Copy/pasted lines exceeded moved lines for the first time.
- Date is inconsistent: the page now shows Jan 2026, while press coverage
  (DevClass) dates the report to Feb 2025. Cite it as "GitClear 2025
  report" and confirm the date.
- Caveats: GitClear sells code-analysis tooling, and the study is
  correlational.

<a id="metr"></a>
**Joel Becker, Nate Rush, Beth Barnes, David Rein (METR), "Measuring the
Impact of Early-2025 AI on Experienced Open-Source Developer Productivity"**
(10 Jul 2025).
URL: https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/
Status: **verified.**

- "When developers are allowed to use AI tools, they take 19% longer to
  complete issues."
- Developers expected a 24% speedup and afterwards believed they had gained
  20%.
- Setup: 16 developers, 246 issues, repos averaging 22k+ stars and 1M+
  lines of code.
- The authors say explicitly that this does **not** show AI fails to speed
  up most developers.
- Use it for the perception gap and for "mature codebases have implicit
  context the AI lacks". Don't use it as "AI makes you slower".

---

## 4. In-repo evidence

Paths are relative to the repo root. Line numbers are as of 2026-09-27 on
branch `store-release-runbook`.

### 4.1 The glossary is explicit, including what *not* to say

- `CONTEXT.md:13-21` defines **Journal Entry**: "Once posted, no code path
  updates or deletes it (Golden Rule #7) — a correction is a new entry that
  references the original via `reversesEntryId`." Its avoid-list:
  "_Avoid_: Transaction (the household-facing term … used only in UI copy
  and feature/flow naming like `record_transaction`, never in domain code),
  Entry alone."
- `CONTEXT.md:23-28` defines **Posting**. "_Avoid_: debit, credit, line
  item."
- `CONTEXT.md:39-44` defines **Reversal**. "_Avoid_: edit, delete, undo
  (none of these happen to a posted entry)."
- `CONTEXT.md:137-138` (Trusted Tip: "_Avoid_: head, latest entry (the
  latest stored entry may be quarantined …)") shows the avoid-list encoding
  a real bug risk, not just style.
- `CONTEXT.md:349` (Import Profile: "_Avoid_: template (that word is taken
  by Recurring Template)") shows the glossary preventing name collisions.
- How it helped: an agent that greps "template" or "head" gets told what
  the project actually means. Because "_Avoid_" lists exist, an agent can
  check its own output (issue titles, test names) against them.
  `docs/agents/domain.md:41-45` requires this: "use the term as defined in
  `CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids. If
  the concept you need isn't in the glossary yet, that's a signal."

### 4.2 Two languages, one mapping (a Bounded Context boundary)

- `docs/household-term-map.md:11-30` maps ledger terms to UI words:
  Reverse → "Fix", Archive → "Hide from new entries", Quarantined entry →
  "Unverified", Transfer → "Moved money".
- `docs/household-term-map.md:32-34`: "Internal code, domain models, and
  OpenSpec specs may keep the existing ledger-facing names … only
  user-visible strings need to use the household wording."
- `docs/household-term-map.md:40`: "Never say debit, credit, journal entry,
  or posting in user-facing copy."
- Code honours the seam:
  - Repository: `LedgerPosting.reverseEntry`
    (`lib/data/repositories/ledger_posting.dart:485`).
  - Household-facing ViewModel: `CorrectionViewModel.fix()`
    (`lib/ui/features/correction_wizard/view_models/correction_view_model.dart:129-132`),
    which documents "The original entry is never edited or deleted (Golden
    Rule #7)."
  - ARB key: `actionFix: "Fix"` (`lib/l10n/app_en.arb:32`).
- The glossary is precise about the umbrella word "Account"
  (`CONTEXT.md:48-68`): Financial Account vs Category vs system rows, each
  managed by its own repository (`AccountRepository` /
  `CategoryRepository`). This is Fowler's "meter" polysemy problem, solved
  by naming.
- History:
  - `9c83981` (2026-08-18): "require household English in specs and
    translator glossary … The translator glossary must not teach
    journal/ledger jargon."
  - `6e1966c` (2026-08-19): "Replace leftover ledger jargon in household
    UI."
  - The OpenSpec change `2026-08-22-household-language-voice` created the
    term map. Its proposal says it had to land "before or with
    `i18n-foundation` so ARB keys encode the right semantics", so
    vocabulary work was sequenced *ahead of* translating into 43 languages.

### 4.3 Domain terms are the class and method names

- `lib/domain/models/`: `journal_entry.dart`, `posting.dart`,
  `signing_identity.dart`, `integrity_event.dart`, `pending_transfer.dart`,
  `investment_lot.dart`, `instrument_holding.dart`. Each is a glossary
  heading turned into a class.
- `lib/domain/models/journal_entry.dart:6-17`: the doc comment restates
  Golden Rule #7. Fields `reversesEntryId`, `deviceChainSequence`, and
  `isSupersededByMigration` (`:39,:41,:55`) are glossary terms verbatim.
- `lib/data/database/tables/journal_entries_table.dart:6-11`: "Journal
  entries are append-only … (Golden Rule #7)" and "Named JournalEntryRow
  (not the Drift default "JournalEntry") to stay distinct from
  domain/models/journal_entry.dart's JournalEntry." The name is chosen
  deliberately so the persistence row cannot be confused with the domain
  concept.
- The rule itself is in `Specs/architecture/smara-tech-guidelines.md:26-28`:
  "Posted journal entries are immutable — no code path issues an UPDATE or
  DELETE against journal_entries or postings once a row exists.
  Corrections are always a new entry."
- The Reversal mechanics are readable as the glossary definition
  (`lib/data/repositories/ledger_posting.dart:510-539`). The code refuses a
  second reversal (`AlreadyReversedException`, "This entry has already been
  corrected. The original line stays as it is.") and then appends a new
  signed entry with `reversesEntryId: original.id` and negated posting
  amounts.
- Term frequency, counted by files containing the term (grep): `lib/` vs
  tests:

  | Term | lib/ | tests |
  | --- | --- | --- |
  | JournalEntry | 19 | 9 |
  | Posting | 37 | 17 |
  | SigningIdentity | 100 | 8 |
  | PendingTransfer | 110 | 12 |
  | closeout | 95 | 7 |
  | quarantin* | 8 | 10 |

- In `lib/domain` and `lib/data`, "debit"/"credit" appear **only** in CSV
  statement-import column mapping
  (`lib/domain/csv/csv_column_mapping.dart:5` `CsvAmountConvention {
  signedColumn, debitCreditColumns }`,
  `lib/domain/statement_import/statement_import_session.dart:54`).
  - That is the *bank's* external vocabulary at the edge. In effect it is a
    small anticorruption translation into signed Postings, which matches
    `lib/domain/models/posting.dart:2-3`: "Signed-amount postings instead
    of explicit debit/credit columns".
  - This fits Evans's Anticorruption Layer pattern, but the repo never
    calls it that. It's the author's call whether to use the term.

### 4.4 The glossary reads as a spec for a predicate

- `lib/domain/register/register_row_policy.dart:4-17`, `isRegisterRowFixable`,
  has one conjunct per glossary rule:
  - `counterpartAccountIds.length == 1 && categoryIds.contains(...)`
    enforces the rule that splits and opening balances aren't fixable
    (`CONTEXT.md:33-35`, `:112-113`).
  - `!row.isReversal && !reversedEntryIds.contains(row.entryId)` enforces
    Reversal.
  - `row.isVerified` enforces Quarantine (`CONTEXT.md:165-175`).
  - `!row.isSupersededByMigration` enforces Migration
    (`CONTEXT.md:209-216`).
- `lib/domain/register/register_row.dart:42-45` explains the same
  reasoning in glossary words.
- Test names read like glossary sentences:
  - `test/domain/register/register_projection_test.dart:134`: "quarantined
    entries stay visible but skip running balance". Compare the definition
    at `CONTEXT.md:165-169`: "excluded from all balance … yet kept
    **visible**".
  - `test/domain/summary/ledger_summary_engine_test.dart:53`: "skips
    quarantined and superseded entries".
  - `test/data/repositories/ledger_repository_test.dart:3875`: "a
    quarantined entry is still exported, marked Verified=No".
- How it helped: when an agent is asked "can the user fix a split?", the
  answer is findable three ways (glossary, predicate, test) using the
  *same words*. Search and review become grep-able.

### 4.5 Vocabulary work surfaced a modeling error and a privacy boundary

- **The "exactly two postings" error.**
  - `git show 1dacec3` (2026-08-28, "domain words realigning") first
    created `CONTEXT.md` with "A posted, immutable double-entry entry with
    exactly two Postings".
  - Splits had shipped eight days earlier
    (`openspec/changes/archive/2026-08-20-split-transactions`).
  - Commit `a1ccf43` (PR #122, 2026-09-09, "Sharpen the domain model via
    grill-with-docs (10 rounds)") corrected it: "correct Journal
    Entry/Posting from 'exactly two' to 'two or more' (splits have 3+
    legs) and add the Split term."
  - It also added Quarantine, Re-anchor, Trusted Tip, Genesis, and Device
    Chain Sequence.
  - Story value: writing the language down made a false belief visible and
    testable. This is Evans's "a change in the language is a change to the
    model".
- **ADR 0003.**
  - `docs/adr/0003-investment-research-hands-off-identifiers-only.md`
    records that the identifiers-only privacy boundary "surfaced during
    grill-with-docs round 5".
  - It is "named in `CONTEXT.md` (Investment Research Prompt)" (`:30`) and
    "Any future 'personalized research' idea must reopen this ADR, not
    quietly extend `buildInvestmentResearchPrompt`" (`:24-26`).
  - A domain term (`CONTEXT.md:317-325`, "_Avoid_: export, sync (the app
    hands off a prompt; it never uploads holdings)") now carries a security
    guarantee.
  - The grilling commit is co-authored by `Cursor Agent`, so the glossary
    was sharpened *with* an agent, not only *for* one.

### 4.6 Honest counter-example: code-comment drift

- Two docstrings still carry the old invariant:
  - `lib/domain/models/posting.dart:1`: "Every entry has exactly two
    postings whose [amountMinor] values sum to zero".
  - `lib/data/database/tables/postings_table.dart:7`: "Every journal entry
    has exactly two postings".
- `git log -S'exactly two postings'` traces them to the initial scaffold
  commits of 2026-07-18/19, before splits existed.
- The glossary was fixed and the code comments weren't. This is exactly
  the "paperwork drift" pattern of post 10, but for vocabulary.
- An agent that trusts the docstring over `CONTEXT.md` could write a wrong
  validation.
- Worth either fixing in its own tiny change before publishing, or using
  openly as "the glossary is only as good as the grep that keeps it in
  sync". Not fixed here, per instructions.

### 4.7 Agent wiring: how the glossary reaches the agent

- `CLAUDE.md:41-47` doesn't inline the glossary. It points to
  `docs/agents/domain.md` ("Single-context (root `CONTEXT.md` +
  `docs/adr/`)") and to `docs/agents/architecture-deepening.md`.
  - This matches Anthropic's advice: keep CLAUDE.md short and load domain
    knowledge just in time ([anth-bp](#anth-bp), [anth-ctx](#anth-ctx)).
  - Added in `19ceacd` (2026-08-23, "Add agent skills configuration (…
    domain docs)").
- `docs/agents/domain.md:5-11` ("Before exploring, read these") and
  `:47-51` ("Flag ADR conflicts … surface it explicitly rather than
  silently overriding").
- `docs/agents/architecture-deepening.md:5-10` sets naming conventions for
  refactor *changes* (`extract-`/`deepen-`/`unify-`/`finish-`). This is a
  ubiquitous language for the architecture work itself.
  - About 36 archived OpenSpec changes follow it, all dated
    2026-08-25 to 2026-09-08 (`ls openspec/changes/archive`).
  - `:22` names domain modules by domain concept (`RegisterProjection`,
    `ActiveBalanceEngine`).
- ADR 0002 (`docs/adr/0002-repository-family-acyclic-dependency-graph.md`)
  names repositories by domain aggregate (`IdentityRepository`,
  `AccountRepository`, `LedgerRepository`). The DI-cycle rule is stated in
  those terms, which lets agents reason about it without reading
  `main.dart`.
- Scale, for context: 380 commits since 2026-07-18, 116 archived OpenSpec
  changes, and 97 main specs.

### 4.8 A related but different naming bug (already covered in the blog)

- `d202558` (2026-09-12): Kashmiri ARB `backupRestored` was byte-identical
  to `actionRestoreBackup`, so a test's success check matched the wrong
  widget.
- This is a *translation* collision, not a domain-model one, and posts
  06/08/09 already cover it. Mention it at most in passing, as "names that
  collide mislead machines too".

---

## 5. Overlap check against blog drafts 00–12

Drafts: `pages/blog/00-*.md` on the current branch, and 01–12 on
`origin/blog-drafts-01-12`.

- A keyword grep across all drafts for CONTEXT.md, glossary, ubiquitous,
  domain, vocabulary, naming, term map, and DDD found **no hits**. The only
  hit was 12:32, "domain name", meaning a web domain. **No existing post
  covers domain language or naming.**
- Adjacent posts to link to rather than repeat:
  - **00**, "From a Weekend Idea…", lines 72-85: knowledge that "normally
    stays implicit" must be written down because an AI has "no hallway
    conversations to have absorbed". The new post can pick this up, since
    the glossary is the most concrete example of it.
  - **05**, "Spec First, Code Second": OpenSpec propose/apply/archive. Don't
    re-explain OpenSpec; mention that specs use glossary terms.
  - **10**, "Paperwork Drift": status docs going stale. §4.6 is the
    vocabulary version of this. Cross-link it, don't retell it.
  - **11**, "Letting the AI Push Back": correcting wrong assumptions in
    conversation. The grill-with-docs rounds are a *structured* version of
    this. Mention the difference and link.
  - **04/06/08/09**: translation and i18n bugs, including the ARB
    collision. Avoid re-telling them. The household term map is new
    material; post 04 covers translation chaos, not the term map.
- Tone and format of the drafts:
  - First person, plain and non-hype, with "one person's data point"
    hedging (00:11-14).
  - H1 title plus several H2 sections, and short concrete anecdotes.
  - Few external citations so far. A references section would be new for
    the series, so keep it tidy.
  - Post 00 uses a mermaid diagram.

---

## 6. Suggested angles and outline hooks

1. **Hook: "exactly two".** The glossary confidently said every Journal
   Entry has exactly two Postings, eight days after splits shipped. Writing
   the language down is what exposed it (§4.5). Then admit that two
   docstrings still say it (§4.6).
2. **What ubiquitous language actually is.** Use Evans's Therefore
   paragraph: in the code, and "a change in the language is a change to the
   model". Contrast with naming as style.
3. **Two languages on purpose.** Ledger words in code, household words on
   screen, and one map between them (§4.2). This is a bounded-context story
   most readers haven't seen in a personal-finance app. Fowler's "meter"
   and the repo's "Account" make a good pair.
4. **Why agents care more than humans do.**
   - Agents navigate by grep and file read (Böckeler).
   - Names are the intent channel (Le et al.; Yang et al.).
   - Anthropic says to make "definitions of niche terminology" explicit.
   - An "_Avoid_" list is a grep-able negative example no human glossary
     usually bothers with.
5. **Clean code isn't obsolete; it's the input.** The Radar says "AI coding
   assistants also perform better with well-factored codebases". DORA 2025
   says AI is an amplifier, and DORA's AI-accessible internal data
   capability warns "garbage in, garbage out". GitClear shows duplication
   rising. Frame it as: AI makes it cheap to write code and cheap to write
   the *wrong names*, so the constraint moves to the model.
6. **Concrete payoff.** One predicate (`isRegisterRowFixable`), five
   glossary rules, and tests named in the same words (§4.4). A privacy
   guarantee held by a noun (ADR 0003).
7. **Caveats.**
   - METR's perception gap is a reason to measure, not believe.
   - The empirical naming studies use older or smaller models and
     adversarial renames.
   - There's no controlled study of "glossary vs no glossary" for agents.
     Say so.

---

## 7. Open questions and unverified claims

- **UNVERIFIED verbatim**: Clean Code Ch. 2, "The name of a variable,
  function, or class, should answer all the big questions…". The headings
  are verified from the publisher TOC; the body text isn't. Check it in the
  book.
- **Secondary only**: Ousterhout Ch. 14's precision/consistency framing.
  Check it in the book before quoting.
- **Secondary only**: Evans's "a trained language model is a bounded
  context" (InfoQ report of a talk). A primary video exists (DDD Europe
  "DDD & LLMs", YouTube `lrSB9gEUJEQ`) but wasn't watched.
- **Date ambiguity**: the GitClear 2025 report page now shows Jan 2026,
  while press dates it to Feb 2025.
- **Fowler UbiquitousLanguage quotes** came through a summarizing fetch.
  Re-read the short page before quoting verbatim.
- **Not found**: any controlled study showing that a project glossary or
  DDD naming improves *agent* task success. The link is argued by analogy
  (identifier-name studies, tool-naming guidance, the Radar blip), not
  measured. State this plainly in the post.
- **Not researched**: Vaughn Vernon; DORA 2025's full seven-capability
  list (only "AI-accessible internal data", "working in small batches",
  and "quality internal platforms" were confirmed); GitClear's 2026
  "maintainability gap" report; arXiv 2606.14796 (a technical-debt
  literature review) turned up in search but wasn't read.
- **Repo follow-up (not done here)**: fix the stale "exactly two postings"
  docstrings in `lib/domain/models/posting.dart:1` and
  `lib/data/database/tables/postings_table.dart:7`, or decide to cite them
  as-is.
- **Claim to avoid**: any "X% faster with DDD" number for this project.
  There is no measurement, only commit history and anecdotes.
