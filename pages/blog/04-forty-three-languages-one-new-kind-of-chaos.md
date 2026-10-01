# Forty-Three Languages, One New Kind of Chaos

With real integration testing in place, the app was genuinely solid — in
one language. The next step was translating it into forty-three, almost
entirely using AI rather than hiring a human translator for each one. That
turned out to be a different category of problem than anything the process
so far had been built to catch, and it took real trial and error to figure
out why.

## Why this wasn't just "more testing"

Everything built up to this point assumed a fixed set of interface text
underneath the behavior being tested. A test would look for a specific
label, tap a specific button, and check for a specific confirmation
message — all written in English, all stable. Once every one of those
strings could independently change across forty-three languages, an entire
new axis of variation opened up that none of the existing tests had ever
needed to think about.

Some of what surfaced was about the *languages themselves*, not the code:
right-to-left script direction needed genuine support, not just mirrored
layout. A financial security recovery phrase — a sequence of words used to
restore access to an account — is only standardized in a handful of the
world's languages; every other supported language needed an honest,
explicit notice that this one specific piece of the app would stay in
English, rather than silently defaulting to it and leaving a person to
wonder why. Several languages render numbers using their own native digit
characters instead of the ones a test author, working in English, would
naturally assume.

## The harder part

The more persistent problem wasn't any single language quirk — it was that
the translations themselves, being AI-generated, could be subtly wrong in
ways that were genuinely hard to catch systematically. Not wrong in an
obviously broken way. Wrong in a way where two different pieces of
interface text, meant to say two different things, occasionally ended up
saying the exact same thing in a given language — invisible unless you
happened to be looking at that specific pair of strings, in that specific
language, at the same time.

Running the full, real, end-to-end test suite against every single
language, the way it already ran reliably in English, wasn't something I
could realistically do by hand at first — each full pass took hours per
language, and forty-three of those adds up to weeks. The honest first
answer was a compromise: pick a smaller, deliberately varied set of
languages — different scripts, different text directions, one with the
recovery-phrase gap, one flagged as lower-confidence in its own
translation quality — and treat passing that set as the real, if partial,
bar.

## Where the actual discovery happened

Running that suite for real, language by language, is where a genuinely
new and recurring class of bug showed up — the exact translation-collision
problem described above, appearing more than once, in more than one
language, in ways that looked unrelated to each other until they weren't.
Getting a real automated test pipeline running across every language,
quickly enough that this could actually be checked routinely instead of as
a rare, expensive event, turned into its own multi-step effort — including
discovering that a testing platform everyone had assumed was too slow for
this kind of check was, once actually measured on the right target,
dramatically faster than assumed.

Both of those threads — the recurring translation bug, and the surprising
discovery about testing infrastructure — turned out to be substantial
enough stories on their own. The rest of this series picks them up in
detail from here.
