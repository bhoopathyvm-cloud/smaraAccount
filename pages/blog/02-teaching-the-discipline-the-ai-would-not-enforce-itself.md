# Teaching the Discipline the AI Wouldn't Enforce Itself

Writing specifications before code fixed one problem and immediately
exposed another. There was now a clear record of what a piece of work was
supposed to do — but nothing was making sure the actual implementation
followed a disciplined process to get there. I wanted strict test-first
development: write a failing test, then write the smallest code that makes
it pass, every time. Asking for that directly didn't reliably produce it.

## What kept happening

A specification would go in, and what came back was often a large volume
of code at once — a full feature, written in one pass, tests included after
the fact if at all. Sometimes it worked. Often, once I actually ran it
against real scenarios, something broke, and untangling *why* was harder
precisely because so much had arrived in one block rather than as a series
of small, individually-verified steps. Asking for test-first development
as an instruction competed with the AI's own tendency to just solve the
whole problem in front of it, and the instruction usually lost.

## Turning the question around

The fix wasn't a better-worded instruction. It was asking a different
question entirely: not "please follow test-first development," but "how do
I make it structurally impossible to skip this." That's a question about
mechanism, not about willpower — mine or the AI's — and it pointed toward
an answer that didn't depend on anyone remembering to follow a rule.

The actual mechanism, once built, was unglamorous: a script that runs
automatically before any commit is allowed to complete, checking formatting
and static analysis, and refusing the commit outright if either one fails.
A second check, run before anything can be pushed, refuses to let a unit of
work be filed away as "done" while any part of its own stated checklist is
still incomplete. Neither of these is enforcing test-first development
directly — but together, they close off the path of least resistance that
had been making it easy to skip. A large, untested, unreviewed pile of
changes now has to pass the same gate as everything else, with nowhere to
hide.

## Extending the same idea to the specifications themselves

The same discipline needed to apply to the requirements side, not just the
code side, or it would just move the problem one layer up: nothing stopping
a "specification" from being three vague sentences that don't actually
constrain anything. So the same completion rule that governs code applies
to the written requirements too — a proposed piece of work isn't
considered finished, and can't be filed away as complete, unless every task
it explicitly listed is checked off, with real evidence behind each check.
Not "the important ones." All of them, including the boring verification
steps that are the easiest to quietly skip under time pressure.

## What this actually bought

None of this made the AI inherently better at writing correct code on the
first try. What it did was make every deviation *visible and blocking*
instead of silent. A shortcut that skips a test, or a change that claims to
be finished while leaving a real task unchecked, now fails loudly and
immediately, at the point where it's cheapest to fix — rather than
surfacing later as a mysterious regression, or not surfacing at all until a
user hits it.

It also changed the working relationship in a specific way: instead of
repeatedly asking for discipline and hoping it would be followed, the
discipline became a property of the environment itself. The AI wasn't being
asked to remember a rule anymore. It was working inside a system that
simply wouldn't let a certain class of shortcut through. That distinction —
enforced structurally instead of requested repeatedly — is the thing I'd
tell anyone starting a similar project to build first, before almost
anything else.

Even with all of this in place, though, the quality of what shipped still
wasn't where it needed to be. That gap needed a different kind of test
altogether — the subject of the next post.
