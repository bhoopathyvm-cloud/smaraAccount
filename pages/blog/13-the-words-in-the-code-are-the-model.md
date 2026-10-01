# The Words in the Code Are the Model

**Domain-driven design isn't only for humans. With AI writing much of
the code, a shared language is also how the AI understands your
project.**

More than twenty years ago, domain-driven design gave software teams a
simple rule: use the same words as the business, everywhere, including
inside the code. The goal was to help *people* understand each other.

Building Smara Account mostly with AI coding assistants taught me that
the rule matters even more for the AI. A person can ask a colleague what
a word means. An AI can't. It knows your project only through the words
it reads, so those words had better be the right ones.

This post covers that idea, one small mistake that showed it, and what
it changed in practice. It's one developer's experience, not a study.

## A small mistake that shows the idea

First, one piece of accounting, because the story needs it. When you
spend 50 on groceries, the app writes down two lines: 50 left your bank
account, and 50 went to "Groceries". Accountants call each line a
**posting**, and the lines together an **entry**.

About six weeks into the project, I wrote down what words like these
mean in a one-page **glossary**: a small dictionary for the project that
both I and the AI follow. It said: every entry has exactly two postings.

But that was no longer true. The app already let you split one shopping
receipt, for example 30 for Groceries and 20 for Household. A split
entry has three lines, not two: one for the bank account, one for
Groceries and one for Household.

The app itself handled splits correctly. The mistake was only in the
dictionary. It described the app as it used to be, and neither I nor
the AI had noticed.

Why does that matter? Because the AI reads the dictionary to understand
the app. An AI that trusted that sentence could one day have "fixed"
the app to allow only two lines, and broken every split purchase.

How was it found? I asked an AI to go through the dictionary one
definition at a time and compare each one with what the app actually
does. It asked me questions in ten rounds, and one of those questions
found the mistake.

That's the point of the story. Writing the rules down as plain
sentences made them possible to check, and the AI could do the
checking. While the rule lived only in my head, nobody could check it.

## Why AI needs a shared language more than people do

On a human team, shared vocabulary spreads by itself: in meetings, in
code reviews, by being corrected over coffee. My team is me plus several
AI coding agents (Claude, Cursor and Codex), and each of them starts
every session knowing nothing about the project. There is no coffee. The
agent learns the project the only way it can: by searching for words
and reading the files it finds.

So the words decide what the agent understands:

- If the code calls the same thing "entry" in one place and
  "transaction" in another, a search for either word finds only half of
  the rules.
- If a function's name says one thing and its body does another, the
  agent tends to trust the name.
- If a rule lives only in someone's head, the agent never sees it.

Research points the same way. One study found that deliberately
misleading function names cut the share of AI-generated code that
worked by 32–44% (Yang et al., *ACM TOSEM*, using older AI models).
Another found that when names are removed, AI models lose track of what
code is *for* (Le et al., 2025). The Thoughtworks Technology Radar says
AI coding assistants "perform better with well-factored codebases," and
that "expressive naming provides domain context." Anthropic's guidance
for building AI tools says to take the context you normally carry in
your head, including "definitions of niche terminology," and "make it
explicit."

To be clear about the limits: this research shows that names matter to
AI. None of it tests a project glossary directly. That last step is my
argument, not a proven result.

## What it looks like in practice

**1. The same words in the glossary, the code and the tests.** The
glossary defines a quarantined entry (one that failed the app's
tamper check) as excluded from every balance but kept visible. The test
for it is called "quarantined entries stay visible but skip running
balance." Anyone who searches for "quarantined", person or AI, finds the
definition, the rule and the proof together.

**2. A list of words *not* to use.** Most glossary entries end with an
*Avoid* line. "Posting: avoid debit, credit, line item." "Import
Profile: avoid template, because that word already belongs to Recurring
Template." People learn this by being corrected. An AI can check its own
work against the list before anyone has to correct it.

**3. Two languages, kept apart on purpose.** Inside the code, a mistake
is "reversed": a new entry cancels the old one, and nothing is ever
edited or deleted. On screen, the button just says "Fix." A short
written map lists every such pair. The code keeps the accounting words;
only on-screen text uses household words. This might look like it
breaks domain-driven design, but the shared language is meant for the
people and agents *building* the model. The user sits outside that
team, and the map is one written-down translation at that boundary, not
a silent one in someone's head.

**4. Let the AI question the glossary, not just follow it.** The format
of my glossary and the ten-round review both come from [Matt Pocock's
open-source agent skills](https://github.com/mattpocock/skills), which
I use and recommend. His `domain-modeling` skill keeps the glossary and
decision records up to date as decisions are made. His
`grill-with-docs` skill interviews you in rounds, suggests an answer to
each question, and updates the glossary as the answers come in. His
README introduces the idea with a quote from Eric Evans about shared
language, and notes that without one, agents "use 20 words where 1 will
do."

## What it changed here

I can't prove the agents got faster or more accurate. That would need a
controlled comparison I haven't run. A well-known study by METR found
that experienced developers using AI tools felt 20% faster while
actually being 19% slower, so my impression isn't evidence. What I can
show is concrete and checkable in the project history:

- **One wrong rule found before it caused harm.** The "exactly two"
  sentence could have led an agent to write a check that rejected every
  split purchase.
- **Nineteen glossary entries added or corrected** in that one ten-round
  review, including the Split concept itself.
- **A privacy rule with a name and a test.** One review round asked what
  the investment research feature may send out of the app. The answer,
  "the investment's name and identifiers only, never your holdings," is
  now a glossary term, a written decision, and a test called "prompt
  omits quantity, cost, and account name" that fails if the rule is ever
  broken.
- **Translations that didn't need redoing.** The map between accounting
  words and household words was written one day before the first
  translation file. Today the app has 574 on-screen texts in 43
  languages, close to 25,000 translations. Changing what one word means
  after that point means changing it 43 times.

For a tester, the gain is that test names read like the glossary, so the
list of tests doubles as a readable list of the rules. For a product
manager, the case is this: one short document, kept up to date, in
exchange for wrong assumptions being caught while they are still
sentences instead of code.

## Where it falls short

- **The glossary drifts too.** After the glossary was fixed, the two old
  code comments still said "exactly two" until I searched for the phrase
  while writing this post. Nothing checks this automatically. A simple
  test that flags *Avoid* words in the code would be worth adding.
- **Not all code reads like the glossary.** The rule for whether an
  entry can be fixed still checks "has exactly one category" where it
  means "is not a split." A check named after the glossary term would
  read better.
- **Accounting is an easy case.** It comes with centuries of precise
  vocabulary. A messier domain would need more judgment calls.
- **An unchecked glossary can be worse than none.** Matt Pocock's own
  documentation warns that an unreviewed, AI-written glossary "becomes
  confident-sounding lore that later sessions treat as truth." My
  "exactly two" line was exactly that until it was questioned.

## The short version

Domain-driven design was created so that people building software would
share one language with each other and with the business. With AI
writing much of the code, that same language is how the AI understands
your project. Write the words down, use them in the code and the tests,
list the words to avoid, and let the AI question the list, not just
follow it.

In [my first post](00-from-a-weekend-idea-to-a-shipping-product.md) I
said that working with AI forces you to write down knowledge that would
normally stay in senior engineers' heads. The glossary is the clearest
example of that in this project. It's the least glamorous file in the
repository, and the one I'd start with next time.

## References

- Eric Evans, *Domain-Driven Design Reference* (2015), "Ubiquitous
  Language".
  <https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf>
- Martin Fowler, "UbiquitousLanguage" (2006).
  <https://martinfowler.com/bliki/UbiquitousLanguage.html>
- Matt Pocock, agent skills (`domain-modeling`, `grill-with-docs`) and
  their documentation. <https://github.com/mattpocock/skills>
- Thoughtworks Technology Radar, "AI-friendly code design" (April 2025).
  <https://www.thoughtworks.com/radar/techniques/ai-friendly-code-design>
- Anthropic, "Writing effective tools for AI agents — with agents"
  (September 2025).
  <https://www.anthropic.com/engineering/writing-tools-for-agents>
- Guang Yang et al., "How Important are Good Method Names in Neural Code
  Generation? A Model Robustness Perspective", *ACM TOSEM*.
  <https://arxiv.org/abs/2211.15844>
- Cuong Chi Le et al., "When Names Disappear: Revealing What LLMs
  Actually Understand About Code" (2025, preprint).
  <https://arxiv.org/abs/2510.03178>
- METR, "Measuring the Impact of Early-2025 AI on Experienced
  Open-Source Developer Productivity" (July 2025).
  <https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/>
