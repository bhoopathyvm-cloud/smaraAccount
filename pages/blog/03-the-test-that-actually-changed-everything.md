# The Test That Actually Changed Everything

Automated formatting checks, static analysis, and a strict rule against
filing away unfinished work all made this project noticeably more stable.
They didn't make it *good*. Code could pass every one of those gates —
clean, analyzed, matching a checked-off specification — and still not
actually work the way a real person using the real app would expect. The
gap between "the code is correct in isolation" and "the app behaves
correctly" needed a different kind of test to close.

## What was missing

Unit tests check that a function does what it claims, given the specific
inputs someone thought to write down. They're necessary and they were
already in place. What they can't catch is the space between functions:
whether the actual screen a user sees actually reflects what a chain of
correct individual pieces was supposed to add up to. A lot of the real
problems in this project lived exactly there — not in any single piece of
logic being wrong, but in how pieces that were each individually fine
combined into something that wasn't.

## The change

The fix was real integration testing: tests that launch the actual,
compiled application — the same code path a real user's device would run,
not a simplified stand-in — and drive it through its genuine interface.
Tap the button a person would tap. Type into the field they'd type into.
Check what's actually rendered on screen afterward, against a real
database and real local storage, not a mocked substitute for either.

The second half of the change mattered just as much as the first: the AI
runs these tests itself, watches them actually pass against the real
running app, before ever proposing that a piece of work is finished. Not
"I wrote a test for this." Ran it. Watched it pass. Only then does the
underlying work get to be considered done.

## Why this was the actual turning point

This surfaced real, previously invisible bugs that no amount of unit
testing or static analysis would ever have caught, because they only exist
at the level of the whole running application: a screen that rendered
correctly on one window size but overflowed on another, a background
process that raced against the interface changes it was supposed to be
reacting to, an interaction that worked the first time through a flow but
broke the second time because of state left over from the first. Each of
these was a real defect that would have shipped, silently, past every
earlier gate in the process.

From that point on, I pushed for something stronger than "most things have
a test": nearly every meaningful requirement needed real, end-to-end
coverage of its own, run against the actual app, before it counted as
finished. That's a genuinely expensive standard to hold — these tests are
slower to write and slower to run than unit tests, by a wide margin — and
it's the single decision I'd defend most strongly if asked to justify the
extra cost. The gap between "technically correct" and "actually works" is
exactly where this kind of testing lives, and it's exactly the gap that had
been letting real problems through everywhere else in the process.

## What came next

Once this was solid for the app running in one language, the natural next
question was whether it held up once the same interface existed in
forty-three different ones. That turned out to be a genuinely different
kind of challenge — not a bigger version of the same problem, but a new
category of failure that none of the process built so far was designed to
catch. That's where the story goes next.
