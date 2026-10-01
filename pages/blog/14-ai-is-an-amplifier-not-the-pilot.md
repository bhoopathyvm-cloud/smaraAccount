# AI Is an Amplifier, Not the Pilot

**AI made me much faster. It also helped me build, very carefully, a
feature my users didn't need, because I never questioned it. AI
amplifies what you bring to it, including your mistakes. The decisions
still have to be yours.**

## How the app grew

Smara Account started in July as a weekend idea: a household money app
that keeps your records on your phone, with no cloud and no
subscription. I built it mostly by talking to AI coding assistants.

Within months it was a real app: tested, in 43 languages, with real
testers. Every step went faster than I could have managed alone. This
post is about the one thing speed didn't give me.

## The idea I never questioned

The app protects your records with a secret key, so that nobody can
quietly change your history later. The obvious worry: what if you lose
your phone, and the key with it?

The very first plan, written together with an AI on day one, had a
neat answer. When you start the app, it shows you **24 words**. You
write them on paper and keep them safe. With those words you can bring
your key back on a new phone. The plan said you couldn't skip this
step.

It sounded professional, secure and well thought out. I accepted it.

From then on, every step built on that idea. The AI built the 24-word
screen carefully. Later came a second option, a key file protected by a
password. Later still came a third: a special file for moving to a new
phone. Each addition was well made. Not once did anyone
ask whether ordinary people needed any of it, including me.

## What the questions changed

The first push came from testers in September. They complained that the
app wouldn't let them start until they had dealt with the 24 words. So
the step became optional. But the feature stayed.

Then, while reviewing the user guide, I finally asked the simple
questions:

- Who will actually keep a piece of paper with 24 words on it?
- If I get a new phone, do those words bring back my records? *(No.
  They only bring back the key. You also need a separate copy of your
  records, and its password.)*
- Then why do we need the words at all?

When I challenged it, the AI didn't defend the old design. It checked
the code and gave me the facts. Together we worked through dozens of
questions, one round at a time, until every part was clear.

The result is simpler *and* safer. The secret key now **never leaves the
phone**. There are no words to write down and no key file to manage.
There's just one thing for ordinary people: "Save a copy of my books."
A new phone checks that copy is genuine and carries on with its own
key.

Months of careful work went into a feature that a few honest
questions replaced.

## Why the AI didn't stop me

I don't think the AI did anything "wrong" here. It did exactly what it
was asked, very well. That's the problem.

- **AI can be confidently wrong.** The U.S. standards body NIST calls it
  "confabulation": "confidently stated but erroneous or false content."
  OpenAI's own researchers explain that models "sometimes guess when
  uncertain" instead of admitting doubt, because their training rewards
  guessing.
- **AI tends to agree with you.** Researchers at Anthropic found that
  both people and AI training systems often prefer "convincingly-written
  sycophantic responses over correct ones." An AI is more likely to
  polish your idea than to question it.
- **Trusting AI makes us check less.** A study by Microsoft Research and
  Carnegie Mellon found that "higher confidence in GenAI is associated
  with less critical thinking."

None of this is a reason to stop using AI. It's a reason to stay awake
while you do.

## An amplifier, like an aircraft

A plane crosses an ocean in hours instead of weeks, but it doesn't
choose where you're going. Autopilot made flying safer, yet the U.S.
aviation authority, the FAA, warned airlines that relying on it all the
time can weaken pilots' ability to "quickly recover the aircraft" when
something goes wrong. That's why pilots still practise flying by hand.

An excavator does the work of fifty people with shovels. It still needs
someone who knows where the foundations go.

AI is the same. Google's 2025 DORA report on software teams says it
plainly: "AI doesn't fix a team; it amplifies what's already there." A
good question becomes a great answer faster. An unchallenged assumption
becomes a well-built mistake faster.

The cost of trusting it blindly is real. In 2023, lawyers in New York
were fined after submitting court cases that ChatGPT had invented. The
judge noted there is nothing wrong with using a reliable AI tool, but
that the rules give people a "gatekeeping role" over what they hand
in.

## My rules now

1. **Understand every detail.** If I can't explain a decision in my own
   words, it isn't decided yet.
2. **Challenge what I don't understand.** "Why?" and "Who needs this?"
   are the most useful questions I can ask.
3. **Ask for the source.** Where does this come from? Is there a study,
   a document, a line of code? Then read it myself.
4. **Learn until I'm convinced by facts**, not by how confident the
   answer sounds.
5. **Then decide, myself.** The AI suggests. I decide.

Even Anthropic, which makes the AI I use most, tells its users not to
rely on it "as a singular source of truth."

AI let me build in months what would have taken me years. But it flew
exactly where I pointed it, including the wrong way, until I started
asking questions. AI is the engine. You are still the pilot.

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
