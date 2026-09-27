# The Words in the Code Are the Model

Late in August I finally wrote down the vocabulary of Smara Account in one
place: a glossary file called `CONTEXT.md`. The first entry, the most
basic term in the whole app, said that a Journal Entry is "a posted,
immutable double-entry entry with exactly two Postings."

That was wrong. Split transactions had shipped eight days earlier, and a
split has three or more legs. The code handled them fine. The tests
covered them. But the sentence that was supposed to define the core of
the ledger described a model the app had already outgrown, and nobody,
me or the AI, had noticed. It took a structured review of the glossary
itself, ten rounds of an agent questioning every definition against the
code, before "exactly two" became "two or more." That review, and the
glossary format it worked on, came from Matt Pocock's open-source agent
skills, which I'll come back to below.

This post is about why that file exists, why the words in it matter more
when an AI writes much of the code, and what keeping the code aligned
with those words actually did for this project. As with the rest of this
series, it's one person's data point, not a controlled study.

## What "ubiquitous language" actually asks for

Domain-driven design has a term for this: *ubiquitous language*. It's
often read as "agree on some vocabulary in meetings." Eric Evans, who
coined it, asks for much more. His DDD Reference says:

> Use the model as the backbone of a language. Commit the team to
> exercising that language relentlessly in all communication within the
> team and in the code. […] Recognize that a change in the language is a
> change to the model. […] Then refactor the code, renaming classes,
> methods, and modules to conform to the new model.
> — Eric Evans, *Domain-Driven Design Reference* (2015)

Two parts of that did real work for me. *In the code*: the vocabulary
isn't documentation next to the software, it's the names inside it. And
*a change in the language is a change to the model*: when I changed
"exactly two" to "two or more," I wasn't fixing a typo. I was correcting
what the project believed about its own core object.

Evans also says the cost of *not* doing this is translation, and that
"translation blunts communication." With an AI collaborator, I'd put it
more strongly. Every place where the code says one thing and the
conversation says another is a place where the model has to guess.

## What the glossary looks like here

`CONTEXT.md` has around fifty terms, grouped by area: the ledger core,
integrity and signing, accounts, imports, investments. Each entry has a
short definition and, for most of them, a line starting with *Avoid*:

- **Journal Entry.** *Avoid:* "Transaction" in domain code (that's the
  word the *user* sees), "Entry" alone.
- **Posting.** *Avoid:* debit, credit, line item.
- **Reversal.** *Avoid:* edit, delete, undo, "none of these happen to a
  posted entry."
- **Trusted Tip.** *Avoid:* head, latest entry, because the latest stored
  entry might be quarantined, and treating it as trusted is exactly the
  bug the term exists to prevent.
- **Import Profile.** *Avoid:* template, because that word already
  belongs to Recurring Template.

I didn't invent this format. It's the one Matt Pocock's `domain-modeling`
skill uses for `CONTEXT.md`, with the rule "be opinionated": when several
words exist for the same concept, pick the best one and list the others
under *Avoid*. The *Avoid* lines turned out to be the most useful part. A human glossary
rarely bothers to list the words you *shouldn't* use; people pick that up
by being corrected. An AI agent doesn't get corrected in the hallway. It
reads files, greps for words, and pattern-matches. A list of rejected
synonyms is something it can check its own output against: test names,
issue titles, new method names.

The agent instructions make this explicit. The skills' setup step wrote
them into `docs/agents/`, and they tell every agent to read
the glossary before exploring, to use terms as defined, not to drift to
synonyms the glossary avoids, and to treat a missing term as a signal
that the model needs sharpening, not as a gap to fill with whatever word
seems close.

## Two languages, on purpose

Smara Account has an unusual constraint. Underneath, it's a signed,
double-entry ledger. On screen, it has to read like a household notebook,
in forty-three languages. Nobody tracking their grocery spending wants to
see the word "posting."

So there are two vocabularies, and a map between them
(`docs/household-term-map.md`):

| Ledger (code, specs) | Household (what the user sees) |
| --- | --- |
| Reverse an entry | Fix |
| Archive an account | Hide from new entries |
| Quarantined entry | Unverified |
| Transfer | Moved money |

The rule is simple. Code, domain models and specs keep the ledger names.
Only user-visible strings use the household words. The seam is easy to
see in the code. The repository method is `reverseEntry`. The screen's
view model exposes `fix()`, with a comment saying the original entry is
never edited or deleted. The button's translation key is `actionFix`.

In DDD terms, that's a boundary between two contexts, with an explicit
translation at the edge. Martin Fowler's classic example of why this
matters is a utility company where "meter" meant subtly different things
to different departments. People smooth that over in conversation;
computers can't. Smara Account's version is the word "Account," which
covers a bank account, a spending category and internal system rows. The
glossary splits them into Financial Account, Category and system
accounts, each with its own repository, so neither I nor an agent has to
guess which one a given `accountId` means.

The order of the work mattered too. The term map was written *before*
the app was translated. Once translation keys encode a meaning in
forty-three languages, changing that meaning is expensive. Getting the
words right first was far cheaper than fixing them in every language
later.

## When the code reads like the glossary

The payoff shows up in small places. Here's the rule for whether a row
in the register can go through the Fix flow:

```dart
bool isRegisterRowFixable({
  required RegisterRow row,
  required Set<String> categoryIds,
  required Set<String> reversedEntryIds,
}) {
  return row.counterpartAccountIds.length == 1 &&
      categoryIds.contains(row.counterpartAccountIds.single) &&
      !row.isReversal &&
      !reversedEntryIds.contains(row.entryId) &&
      row.isVerified &&
      !row.isSupersededByMigration;
}
```

Each condition is a sentence from the glossary. A Split or an Opening
Balance can't be fixed. A Reversal, or an entry that's already been
reversed, can't be fixed. A Quarantined entry can't be fixed until it's
verified. An entry superseded by a Migration can't be fixed. Nothing had
to be translated to write it, and nothing has to be translated to review
it.

The tests read the same way: "quarantined entries stay visible but skip
running balance," "skips quarantined and superseded entries." The
glossary defines a quarantined entry as excluded from every balance but
kept *visible*. The test name is almost the definition.

So when I ask an agent "can the user fix a split?", the answer can be
found three ways (the glossary, the predicate, the tests) using the
*same words*. That's the practical meaning of "the code mirrors the
model." Search works. Review works. The agent's first grep lands in the
right place.

It even reaches security. One of the glossary review rounds surfaced a
privacy question about the investment research feature. It's now recorded
as a decision (ADR 0003) and pinned to a glossary term, Investment
Research Prompt, whose *Avoid* line says: not export, not sync, "the app
hands off a prompt; it never uploads holdings." A guarantee that lives
in a noun is much harder to erode by accident than one buried in a
code comment.

## The skills that did the heavy lifting

Most of this structure didn't come from me reading DDD books and
applying them by hand. It came from [Matt Pocock's skills
repository](https://github.com/mattpocock/skills), a set of small,
open-source "agent skills": plain Markdown instructions that a coding
agent loads when a task calls for them. The README describes them as
skills to "do real engineering - not vibe coding," designed to be
"small, easy to adapt, and composable," and they work across agents. I
installed them in late August and copied them into the Cursor and Codex
skill folders too, so every agent I use reads the same instructions.

The skills are built on domain-driven design on purpose. The README's
section on agents that talk too much opens with the same idea from
Evans: "With a ubiquitous language, conversations among developers and
expressions of the code are all derived from the same domain model."
Matt's diagnosis of the agent version of the problem is blunt: agents
"are usually dropped into a project and asked to figure out the jargon
as they go. So they use 20 words where 1 will do." Even the file name
comes from DDD. The docs explain that "context" is "the standing DDD word
for a bounded area of the model," which is why the glossary is called
`CONTEXT.md` and not `GLOSSARY.md`.

Four of them shaped the domain model directly:

- **Setup** (`setup-matt-pocock-skills`) scaffolded `docs/agents/`: where
  issues live, the triage labels, and, most importantly, how every agent
  should read the domain docs before touching code.
- **`domain-modeling`** is the discipline of *changing* the model, not
  just reading it: challenge terms, invent edge cases, and write the
  glossary entry or decision record the moment it's settled. It defines
  the `CONTEXT.md` format and when a decision deserves an ADR.
- **`grill-with-docs`** combines that with a `grilling` skill. The agent
  interviews you in rounds. Each round asks every question whose
  prerequisites are already settled, with a recommended answer for each,
  and updates the glossary and ADRs as answers land. Ten rounds of this
  in early September caught the "exactly two" error, added
  terms like Quarantine, Trusted Tip and Split, and produced the privacy
  decision in ADR 0003.
- **`improve-codebase-architecture`**, with its companion
  `codebase-design`, looks for shallow modules worth deepening, with the
  stated aim of "testability and AI-navigability." About twenty
  "architecture cycle" pull requests came out of it, each named in a
  small vocabulary of its own: `extract-`, `deepen-`, `unify-`,
  `finish-`. New domain modules such as `RegisterProjection` are named
  after glossary concepts, not implementation details.

What made them genuinely helpful wasn't any single clever prompt. It was
that they turned practices I knew I *should* follow into things that
actually happened, every time, in the same way. A glossary is easy to
start and easy to let rot. A skill that says "write the term down the
moment it's resolved," and an interview that won't move on until the
definition is sharp, keeps it alive. And because each skill is only a
Markdown file, I could read exactly what the agent was being told and
adapt it to this repo instead of adopting someone else's whole process.

## Why this matters more with AI, not less

A common argument goes: if AI writes and rewrites the code, human
readability matters less. The evidence I found points the other way.

**Names are how models understand intent.** Research on code models is
fairly consistent here. One study found that deliberately misleading
method names cut code-generation pass rates by 32–44% (Yang et al.,
*ACM TOSEM*). Another found that stripping names out of code "severely
degrades" tasks that depend on intent, such as summarization, with models
falling back to line-by-line descriptions (Le et al., 2025). A third,
testing thirteen models including GPT-4o, found that renaming variables
dropped average accuracy by 18.6 percentage points (Nikiema et al.,
2025). These used older or smaller models and deliberately bad names, so
I read them as direction, not magnitude. The direction is clear: names
carry meaning the structure alone doesn't.

**Agents navigate by reading and searching.** Birgitta Böckeler's
writing on coding agents calls file reading and searching "the most
basic and powerful context interfaces," and suggests asking "how well
your existing code serves as context." The Thoughtworks Technology Radar
goes further in its "AI-friendly code design" entry: "AI coding
assistants also perform better with well-factored codebases," and
"expressive naming provides domain context and functionality." It ends
on a line I found reassuring: "the best AI-friendly patterns align with
established best practices." Nothing about this is new. It just matters
more.

**Anthropic says the same thing about tools.** Anthropic's guidance on
writing tools for agents says to think about the context you bring
without noticing, including "definitions of niche terminology," and
"make it explicit." Their piece on context engineering notes that
"naming conventions […] provide important signals that help both humans
and agents." That's written about tool design and context, not
application code, but a codebase is the biggest tool an agent uses.

**AI amplifies what's already there.** The 2025 DORA report puts it
bluntly: "AI doesn't fix a team; it amplifies what's already there."
DORA's 2024 report linked higher AI adoption with an estimated 7.2%
drop in delivery stability. GitClear's 2025 analysis of code changes
found copy-pasted code overtaking refactored code for the first time.
None of that proves bad names cause bad outcomes. But it fits a simple
picture: AI makes it cheap to write code, which also makes it cheap to
write the *wrong* names at scale. When writing code costs little, the
hard part is keeping the model right.

**And it helps keep the always-loaded context small.** Anthropic's Claude
Code guidance says to keep `CLAUDE.md` short and to leave out anything
the agent can work out by reading the code. In this repo `CLAUDE.md`
doesn't paste the glossary in; it points to it, and the agent reads it
when it needs it. The more the domain can be read straight from the
code, the less has to be said up front. Good names are context you've
already paid for.

## What it doesn't solve

Three honest caveats.

First, the glossary drifts too. While researching this post, I found
two code comments that still said "Every entry has exactly two
postings." They dated from the first scaffold, weeks before splits
existed. The glossary had been fixed; the comments hadn't. Nothing broke,
since the code and tests handled splits correctly, but an agent that
trusted the comment over the glossary could have written a validation
that rejected every split. This is the same paperwork drift from post 10,
only for vocabulary.

The fix was small: one search for "exactly two", two comments corrected
to "two or more", and a short OpenSpec change to record why. What's
worth noting is how it was found. It wasn't a bug report. It was a
search for the glossary's own words across the code. A glossary is only
as good as the grep that keeps it in sync with the code, and that
search belongs in the routine every time a definition changes.

Second, I haven't measured any of this. I found no controlled study
showing that a project glossary makes coding agents more accurate. The
argument here is built from nearby evidence (naming studies, tool-design
guidance, industry reports) plus my own experience. METR's 2025 study is
a useful warning: experienced developers using AI tools were 19% slower
on their own mature codebases while believing they were 20% faster. How
fast something feels isn't evidence that it is fast. I'd rather say "this
made the agent's first attempt land closer more often, in my experience"
than invent a number.

Third, the people who built the tooling are careful about this too. The
documentation for Matt's `domain-modeling` skill openly asks whether a
glossary earns its keep. Its answer is: sometimes it doesn't. DDD's
payoff, it says, is "upstream, in naming and concept alignment, not in
aggregates and layer ceremony." Controlling synonyms matters at naming
boundaries such as module names, table names, status enums and issue
titles, and much less in ordinary prose. It also records a live
objection: an agent may respond just as well to a plain-English
description, in which case the glossary's real value is "keeping you and
your reviewers aligned with what the agent is doing, not making the
agent better." And it gives the sharpest warning I've read on the
subject: "an unreviewed, agent-authored glossary is worse than none: it
becomes confident-sounding lore that later sessions treat as truth."

That's exactly what "exactly two" was: a confident line in the glossary
that was never checked against the code. It didn't cause harm because the
grilling rounds reviewed every definition before anything depended on
it. So I'd add one rule to everything above: a glossary is worth having
only if someone keeps questioning it.

## What I'd tell myself at the start

- **Write the glossary early, and include the words to avoid.** A
  rejected-synonyms list is cheap to write and it's the part an agent
  can actually check against.
- **Put the words in the code, not next to it.** Class names, method
  names, test names. If a rule in the glossary doesn't map to one
  condition in the code, one of them is wrong.
- **Treat a vocabulary change as a model change.** When a definition
  shifts, rename things. Don't leave the old word in the code "for now."
- **Keep the user's language separate and mapped.** Two vocabularies
  are fine if the boundary is explicit and written down.
- **Have the AI question the glossary, not just follow it.** The "exactly
  two" error was caught by an agent asking hard questions of each
  definition. That's the structured version of post 11: letting the AI
  push back, aimed at the model itself.
- **Don't build the discipline from scratch.** Small, readable skills
  like Matt Pocock's gave me a working glossary format, an interview
  loop and an architecture review on day one. Then I adapted them.

In post 00 I said that working with AI forces you to write down
knowledge that would normally stay in senior engineers' heads. The
glossary is the most concrete example of that in this project. It's
the least glamorous file in the repo, and probably the one that has
saved the most wrong guesses.

## References

- Matt Pocock, *Skills For Real Engineers* (agent skills, including
  `domain-modeling`, `grill-with-docs`, `grilling`, `codebase-design` and
  `improve-codebase-architecture`). <https://github.com/mattpocock/skills>
- Matt Pocock, `domain-modeling` skill documentation (including "Does a
  glossary actually earn its keep?").
  <https://github.com/mattpocock/skills/blob/main/docs/engineering/domain-modeling.md>
- Eric Evans, *Domain-Driven Design Reference: Definitions and Pattern
  Summaries* (Domain Language, 2015), sections "Ubiquitous Language",
  "Model-Driven Design", "Intention-Revealing Interfaces".
  <https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf>
- Martin Fowler, "UbiquitousLanguage" (2006).
  <https://martinfowler.com/bliki/UbiquitousLanguage.html>
- Martin Fowler, "BoundedContext" (2014).
  <https://martinfowler.com/bliki/BoundedContext.html>
- Martin Fowler, "DomainDrivenDesign" (2020).
  <https://martinfowler.com/bliki/DomainDrivenDesign.html>
- Thoughtworks Technology Radar, "AI-friendly code design" (April 2025).
  <https://www.thoughtworks.com/radar/techniques/ai-friendly-code-design>
- Birgitta Böckeler, "Context Engineering for Coding Agents"
  (martinfowler.com, February 2026).
  <https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html>
- Anthropic, "Writing effective tools for AI agents — with agents"
  (September 2025).
  <https://www.anthropic.com/engineering/writing-tools-for-agents>
- Anthropic, "Effective context engineering for AI agents" (September
  2025).
  <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>
- Anthropic, "Best practices for Claude Code".
  <https://code.claude.com/docs/en/best-practices>
- Guang Yang et al., "How Important are Good Method Names in Neural Code
  Generation? A Model Robustness Perspective", *ACM TOSEM*.
  <https://arxiv.org/abs/2211.15844>
- Cuong Chi Le et al., "When Names Disappear: Revealing What LLMs
  Actually Understand About Code" (2025, preprint).
  <https://arxiv.org/abs/2510.03178>
- Serge Lionel Nikiema et al., "The Code Barrier: What LLMs Actually
  Understand?" (2025, preprint). <https://arxiv.org/abs/2504.10557>
- Google Cloud / DORA, "Announcing the 2024 DORA report" (October 2024).
  <https://cloud.google.com/blog/products/devops-sre/announcing-the-2024-dora-report>
- Google Cloud / DORA, "Announcing the 2025 DORA Report" (September
  2025).
  <https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report>
- GitClear, "AI Copilot Code Quality: 2025 Data Suggests 4x Growth in
  Code Clones".
  <https://www.gitclear.com/ai_assistant_code_quality_2025_research>
- METR, "Measuring the Impact of Early-2025 AI on Experienced
  Open-Source Developer Productivity" (July 2025).
  <https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/>
