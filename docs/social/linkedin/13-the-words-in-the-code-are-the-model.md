# LinkedIn post: The Words in the Code Are the Model

Companion post for `pages/blog/13-the-words-in-the-code-are-the-model.md`.
Publish it once the blog post is live at the URL below. LinkedIn shows plain
text, so paste everything between the rules exactly as written. Keep the
blog link in the post body, since the preview card is generated from it.

Blog URL: https://smara-ai.ch/blog/13-the-words-in-the-code-are-the-model/

---

When AI writes a lot of your code, the words you use matter more than ever.

I learned this building Smara Account, a household money app I build mostly with AI coding assistants.

Some context first. Every field has its own vocabulary. In accounting, each purchase is recorded as an "entry" with at least two sides: money leaves your bank account, and the same amount lands in a category like "Groceries". Those sides are called "postings".

I keep a one-page dictionary of these words for the project, so that I, the code, and the AI all mean the same thing.

One day that dictionary turned out to be wrong. It said every entry has exactly two sides. But I had already added split purchases: one supermarket receipt split between Groceries and Household has three sides. The app worked fine. Only the dictionary was wrong, and neither I nor the AI had noticed.

It was caught when I asked an AI to question every definition in the dictionary against the actual code, one by one. I used a free skill called "grill-with-docs" from Matt Pocock for this (github.com/mattpocock/skills).

Why does a dictionary matter so much? Because an AI assistant has no hallway conversations. It learns your project only from what it reads: file names, function names, notes. If the code says one thing and the dictionary says another, it has to guess.

What worked for me:

1. Use the same words everywhere. If the business says "entry", the code says "entry" too. Not "record" in one place and "transaction" in another.

2. Write down the words NOT to use. My dictionary says: say "posting", never "debit" or "line item". People learn this by being corrected. An AI can check it directly.

3. Keep the customer's words separate. Inside the code it's "reverse an entry". On screen, the button just says "Fix". A short list maps one to the other.

4. Let the AI question your definitions, not only follow them. That's how the mistake above was found.

5. Don't start from zero. Matt Pocock's skills gave me the dictionary format and the question-and-answer routine. Each one is a short text file you can read and change.

None of this is new. Software people call it "domain-driven design" and a "ubiquitous language" (Eric Evans, 2003). What's new is who reads the code. Research shows AI models write clearly worse code when names are misleading, and Thoughtworks notes that AI assistants "perform better with well-factored codebases".

One honest caveat: nobody has measured whether a project dictionary makes AI more accurate. This is one developer's experience, backed by related research.

Full post, with all sources:
https://smara-ai.ch/blog/13-the-words-in-the-code-are-the-model/

Does your team keep one shared vocabulary between the business, the code, and the AI?

#DomainDrivenDesign #CleanCode #AIAssistedDevelopment #SoftwareEngineering

---
