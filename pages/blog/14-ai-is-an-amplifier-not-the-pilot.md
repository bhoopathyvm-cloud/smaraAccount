# The 24 Words Nobody Needed

I was reading the user guide of my own app when one line stopped me:

> *Recovery phrase — a 24-word phrase you write down on paper.*

I tried to picture an ordinary person doing that. Opening a money app
for the first time, being handed 24 random words, finding a pen,
copying them carefully, and then keeping that paper safe for years.

Then a more uncomfortable question arrived. *Why did I build this?*

## Day one

Smara Account began in July as a weekend idea: a simple household money
app that keeps your records on your own phone. No cloud, no
subscription. I built it mostly by talking to AI coding assistants, and
it grew faster than I ever could have managed alone.

On the very first day, the AI and I wrote the plan together. The app
would protect your records with a secret key, so nobody could quietly
change your history. And if you lost your phone? The plan had a neat
answer: show every new user 24 words to write down. With them, you
could bring the key back. The step could not be skipped.

It sounded secure. It sounded professional. It sounded like something a
serious app should have.

I nodded and moved on.

## The machine kept building

That's the thing about working with AI: once an idea is in the plan, it
gets built, and built well.

The 24-word screen came out polished. Then came a second option, a key
file protected by a password, in case paper wasn't your thing. Then a
third: a special file for moving to a new phone. Every piece was tested
and careful. Every piece made the original idea look more solid.

Nobody asked whether ordinary people needed any of it. Not the AI. Not
me.

In September, the testers grumbled. The project notes from that week
put it bluntly: "Testers are complaining about this wall." They couldn't start using the app until they had dealt with
the 24 words. So we made the step optional.

But the feature stayed. We had treated the symptom, not the question.

## The questions

Sitting with that line in the user guide, I finally asked the questions
I should have asked on day one:

*Who will actually keep a piece of paper with 24 words on it?*

*If I get a new phone, do those words bring my records back?*

The answer to the second one surprised me. No. The words only bring
back the key. To get your records back, you also need a separate copy of
them, and its password. So the 24 words, on their own, save nothing.

When I put this to the AI, it didn't defend the old design. It went into
the code and laid out the facts. Then we did something I should have
done months earlier: we went through the whole design, question by
question, dozens of them, until I understood every part.

The design that came out is almost embarrassingly simple. The secret key
will never leave the phone. Nothing to write down, no key file to
manage. Ordinary people get one button: "Save a copy of my books." A
new phone checks the copy is genuine and carries on with its own key.
I'm building it now.

Months of careful work, replaced by a few honest questions.

## Why didn't the AI stop me?

I don't blame the AI. It did exactly what I asked, very well. That was
the problem.

Researchers have names for what happened. The U.S. standards body NIST
describes AI output that is "confidently stated but erroneous". OpenAI's
own researchers explain that models "sometimes guess when uncertain"
instead of admitting doubt. Researchers at Anthropic found that people,
and the systems used to train AI, often prefer "convincingly-written
sycophantic responses over correct ones". In plain words, AI tends to
agree with you.

And the more we trust it, the less we check. A study by Microsoft
Research and Carnegie Mellon found that "higher confidence in GenAI is
associated with less critical thinking."

That was me on day one: confident in the AI, and not thinking hard
enough.

## The engine and the pilot

A plane crosses an ocean in hours instead of weeks. But it doesn't
choose where you go. Autopilot made flying safer, yet the U.S. aviation
authority warned airlines that relying on it all the time can weaken a
pilot's ability to "quickly recover the aircraft" when something goes
wrong. So pilots still practise flying by hand.

An excavator does the work of fifty people with shovels. It still needs
someone who knows where the foundations go.

AI is the same kind of machine. Google's 2025 DORA report on software
teams puts it simply: "AI doesn't fix a team; it amplifies what's
already there." A good question becomes a great answer, faster. An
unchallenged idea becomes a well-built mistake, faster.

Sometimes the cost is public. In 2023, lawyers in New York were fined
for handing a court cases that ChatGPT had made up. The judge's point
wasn't the AI. It was that nobody checked.

## What I do now

1. **Understand every detail.** If I can't explain a decision in my own
   words, it isn't decided.
2. **Challenge what I don't understand.** "Why?" and "Who needs this?"
   are my best questions.
3. **Ask for the source.** A study, a document, a line of code. Then
   read it myself.
4. **Learn until the facts convince me**, not how confident the answer
   sounds.
5. **Then decide, myself.**

Even Anthropic, the company behind the AI I use most, tells its users
not to rely on it "as a singular source of truth."

AI let me build in months what would have taken me years. But it flew
exactly where I pointed it, the wrong way included, until I started
asking questions.

AI is the engine. You are still the pilot.

## References

- NIST, *AI 600-1: Generative AI Profile* (July 2024).
  <https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf>
- Kalai et al. (OpenAI), "Why language models hallucinate" (September
  2025). <https://openai.com/index/why-language-models-hallucinate/>
- Sharma et al. (Anthropic), "Towards Understanding Sycophancy in
  Language Models" (2023). <https://arxiv.org/abs/2310.13548>
- Lee et al. (Microsoft Research and Carnegie Mellon), "The Impact of
  Generative AI on Critical Thinking", CHI 2025.
  <https://www.microsoft.com/en-us/research/publication/the-impact-of-generative-ai-on-critical-thinking-self-reported-reductions-in-cognitive-effort-and-confidence-effects-from-a-survey-of-knowledge-workers/>
- FAA, *Safety Alert for Operators 13002: Manual Flight Operations*
  (January 2013).
  <https://www.faa.gov/sites/faa.gov/files/other_visit/aviation_industry/airline_operators/airline_safety/SAFO13002.pdf>
- Google Cloud / DORA, "Announcing the 2025 DORA Report" (September
  2025).
  <https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report>
- *Mata v. Avianca, Inc.*, sanctions order (S.D.N.Y., June 2023).
  <https://www.courtlistener.com/docket/63107798/mata-v-avianca-inc/>
- Anthropic, "Claude is providing incorrect or misleading responses.
  What's going on?"
  <https://support.claude.com/en/articles/8525154-claude-is-providing-incorrect-or-misleading-responses-what-s-going-on>
