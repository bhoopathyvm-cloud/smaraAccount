# Are You Sure Your AI Is Right?

I was sure. That was the problem.

## What I wanted to build

Old accounting books had one rule: you never erase. If something was
wrong, you wrote a correction underneath and signed the page.

I wanted the same thing in a phone app, working like Bitcoin's ledger.
Every entry is **signed**, not with ink but with a *digital key*:
a secret only your phone holds. Every entry is also **linked** to the
one before it. Change one old entry secretly and the chain breaks, and
the app notices. Mistakes are fixed only by a new correction entry.

*For engineers:* each entry is signed with Ed25519 and chained with
SHA-256 hashes. NIST describes this pattern: records "cryptographically
linked to the previous one (making it tamper evident)."

## The 24 words

A digital key starts as a huge random number. When I planned the app
with an AI on day one, the plan said: show every user **24 words**,
which is that number written as words, and make them write it down.
If you lose your phone, the words bring the key back.

The AI was sure the key had to be backed up. It sounded right, so I
didn't ask why. The AI built it beautifully, then
added a key file, then a moving file.

## The question

Then my first tester asked: *"Why do I need these words? To check my
entries, isn't the public key enough?"*

A digital key comes in two halves. The **private** half signs. The
**public** half only checks signatures, like comparing a signature with
the one on an ID card. It isn't secret.

The tester was right. Checking old entries needs only the public half.
A new phone can simply make its own key and continue. Backing up the
private half gives you nothing, and anyone who finds the 24 words could
sign as you.

NIST's key-management standard says the same: "Key backup is not
usually desirable for the private key of a signing key pair." The
public key, though, should be kept as long as you need to check
signatures.

So the new design, which I'm building now, is simpler and safer: the
private key never leaves the phone, and people get one button, "Save a
copy of my books."

## Why the AI didn't stop me

AI can be "confidently stated but erroneous" (NIST). It tends to agree
with you (Anthropic). And the more we trust it, the less we think
critically (Microsoft Research and Carnegie Mellon).

## Engine, not pilot

A plane crosses an ocean in hours but doesn't choose where you go. AI
is the same: Google's DORA report says it "amplifies what's already
there."

So now: understand every detail, question what you don't understand,
ask for the source, and decide only when the facts convince you.

One simple question from a tester was worth more than months of
confident answers.

Are you sure your AI is right? Ask one more question.

## References

- NIST, *SP 800-57 Part 1 Rev. 5: Recommendation for Key Management*
  (2020), Appendix B.3.1.
  <https://doi.org/10.6028/NIST.SP.800-57pt1r5>
- NIST, *IR 8202: Blockchain Technology Overview* (2018).
  <https://doi.org/10.6028/NIST.IR.8202>
- NIST, *FIPS 186-5: Digital Signature Standard* (2023), which includes
  EdDSA (Ed25519). <https://doi.org/10.6028/NIST.FIPS.186-5>
- NIST, *AI 600-1: Generative AI Profile* (2024).
  <https://doi.org/10.6028/NIST.AI.600-1>
- Sharma et al. (Anthropic), "Towards Understanding Sycophancy in
  Language Models" (2023). <https://arxiv.org/abs/2310.13548>
- Lee et al. (Microsoft Research and Carnegie Mellon), "The Impact of
  Generative AI on Critical Thinking", CHI 2025.
  <https://www.microsoft.com/en-us/research/publication/the-impact-of-generative-ai-on-critical-thinking-self-reported-reductions-in-cognitive-effort-and-confidence-effects-from-a-survey-of-knowledge-workers/>
- Google Cloud / DORA, "Announcing the 2025 DORA Report" (2025).
  <https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report>
