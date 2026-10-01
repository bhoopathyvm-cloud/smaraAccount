# When Vibe Coding Stops Being Fun

The first real stretch of this project had no specification, no fixed plan,
and no formal process. I described what I wanted, an AI wrote code for it,
I ran it and reacted. For exploring an idea, this is genuinely effective. It
answers "does this concept even make sense" faster than almost any other
way of working. It is also, I learned the hard way, a way of working with a
built-in expiration date.

## What actually goes wrong

Nothing dramatic happens at first. Small features land, they mostly work,
the project feels alive. The problem shows up sideways: there's no longer
any fixed answer to the question "what is this app actually supposed to
do." Behavior exists because it was written, not because it was decided.
That's fine right up until something needs to change, or a new feature
needs to interact with an old one, and there's no record to check against —
only whatever the code currently happens to do, which may or may not be
what was originally intended.

Once that happens, everything gets slower in a way that's hard to notice
day to day and impossible to ignore in retrospect. Every new conversation
with the AI needs more context, because there's no document carrying that
context for it. Every change carries a small, invisible risk of quietly
undoing something that used to work, because nothing states what "working"
means well enough to check. Reviewing a batch of AI-generated code stops
being "does this look reasonable" and becomes "do I actually understand
everything this touches" — a much higher bar, reached much less often than
it should be.

I didn't have a name for this problem while I was in it. It just felt like
the project getting steadily more exhausting to work on, for reasons that
weren't obviously any single bug's fault.

## The moment it clicked

Separately from this project, a training session at work covered
spec-driven development: the practice of writing down what a system should
do, in a structured, checkable way, before writing the code that implements
it. I'd encountered the idea before in passing. What made it land this time
was recognizing, mid-session, that the exact pain I'd been feeling on this
project — no fixed record of intended behavior, no way to evaluate a change
except by feel — was precisely the problem this practice exists to solve.

## Starting small on purpose

I didn't rewrite the project around a new process overnight. I picked one
small, contained piece of upcoming work and tried writing it down properly
first — what it needed to do, why, and how I'd know it was done — before
asking for any code. Then another, slightly larger piece. The point of
going slowly wasn't caution for its own sake; it was that I genuinely
didn't know yet whether this discipline would survive contact with a real,
messy, AI-assisted project, as opposed to the clean example used in a
training session. Small pieces meant a wrong turn cost an afternoon, not a
month.

It did survive contact, though not without real friction — which turned out
to be its own lesson, worth its own post. Writing things down first didn't
automatically make the AI implement them well. But it changed what a
disagreement or a mistake actually cost to fix: a paragraph in a document
is cheap to rewrite. Code nobody wrote a specification for first is
expensive to even correctly *understand* is wrong, let alone fix.

## What this wasn't

This isn't an argument that vibe coding is bad, or that every project needs
a heavyweight process from day one. It was the right way to spend the first
stretch of this project's life, and I'd do it again for a similarly early,
exploratory idea. The lesson isn't "always plan first." It's noticing the
specific moment when an unstructured approach stops matching what a project
actually needs — and being willing to change how you work once you notice
it, rather than pushing through the growing pain because it's how you
already know how to work.
