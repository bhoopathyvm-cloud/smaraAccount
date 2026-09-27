# LinkedIn post: The Words in the Code Are the Model

Companion post for `pages/blog/13-the-words-in-the-code-are-the-model.md`.
Publish it once the blog post is live at the URL below. LinkedIn shows plain
text, so paste everything between the rules exactly as written. Keep the
blog link in the post body, since the preview card is generated from it.

Blog URL: https://smara-ai.ch/blog/13-the-words-in-the-code-are-the-model/

---

The glossary for my accounting app said every journal entry has "exactly two" postings.

Split transactions had shipped eight days earlier. A split has three or more.

The code was right. The tests were right. The one sentence meant to define the core of the ledger was wrong, and neither I nor the AI I build with had noticed.

It was caught by an AI agent asked to question every definition in the glossary against the code. Not by a bug report.

That's the idea behind my new post: the words in the code are the model.

What I learned building Smara Account, mostly with AI coding agents:

→ Put the domain words in the code, not next to it. Class names, method names, test names. The rule for "can this entry be fixed?" is one line per glossary rule.

→ List the words to avoid, too. "Posting: avoid debit, credit, line item." It's the part of a glossary an agent can actually check its own output against.

→ Keep two languages on purpose. Ledger terms in the code, household words on screen ("Reverse" becomes "Fix"), with a written map between them.

→ Clean code matters more with AI, not less. Research shows misleading names cut code-generation pass rates by 32–44%. Thoughtworks says AI assistants "perform better with well-factored codebases." DORA 2025: AI "amplifies what's already there."

And an honest caveat: I found no controlled study showing that a project glossary makes coding agents more accurate. This is one developer's experience plus the nearby evidence, not a benchmark.

Full post, with sources (Evans, Fowler, Thoughtworks, Anthropic, DORA, METR):
https://smara-ai.ch/blog/13-the-words-in-the-code-are-the-model/

How does your team keep the language in the code in sync with the language of the business?

#DomainDrivenDesign #CleanCode #AIAssistedDevelopment #SoftwareEngineering

---
