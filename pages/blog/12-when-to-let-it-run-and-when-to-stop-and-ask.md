# When to Let It Run, and When to Stop and Ask

Across two months and roughly a hundred shipped changes, the large majority
of decisions got made and executed without a check-in first: merge this
routine dependency update, run this experiment, fix this bug found along
the way, archive this finished piece of work. A small, specific set of
moments got an explicit pause instead, on purpose, every time.

## What ran on its own

Most day-to-day work fell into a category where autonomous execution was
clearly the right call: things that are easy to verify after the fact and
easy to reverse if wrong. Routine dependency bumps, once their automated
checks passed. Bug investigations that turned up a clear, isolated fix.
Re-running a failed experiment with an adjusted parameter to see if the
adjustment worked. Filing away a piece of work as complete once every part
of it was genuinely verified. None of this needed a pause, because none of
it was expensive to undo if it turned out to be wrong — worst case, revert
a commit and try again.

## What didn't

A small number of moments got treated differently, and looking back at
them, they share a specific shape rather than a specific subject:

- Generating a real, production signing key for an app store submission —
  something that, once created and used, becomes very difficult to fully
  walk back.
- A decision that would drop a specific kind of real-device test coverage
  entirely, in exchange for speed — something that trades away a safety net
  in a way that's hard to notice is missing until it's needed.
- Anything that would commit to a domain name, a public identity, or a
  policy stated in a place other people would read and rely on.

Each of these got an explicit stop, a clear explanation of the trade-off,
and a wait for a direct answer before proceeding — even when the answer
seemed likely to be "yes, go ahead."

## The actual filter

The distinguishing question was never "does this feel risky" in some vague
sense. It was concrete: if this turns out to be the wrong call, how
expensive is it to undo? A dependency bump that breaks something is a
revert away from fixed. A production signing key generated with the wrong
settings, or lost after generation, can mean permanently losing the ability
to update an already-published app. Those aren't the same category of
decision, even though both are, technically, "just running a command."

Reversibility isn't always obvious in advance, either — sometimes it only
becomes clear once you know what a specific action actually does under the
hood. Part of the point of pausing on unfamiliar or unusually consequential
steps is learning the actual answer to "how hard would this be to undo"
before finding out the hard way.

## What this isn't

This isn't a fixed checklist of "always ask before doing X." Different
projects, different stakes, different levels of trust built up over time
will put the line in different places. It's a habit of asking one specific
question before acting, rather than a policy of asking permission for broad
categories of task regardless of context. The goal was never fewer
questions or more questions — it was putting the pause exactly where
reversibility actually breaks down, and getting better at recognizing where
that point is, project by project, rather than applying the same caution
everywhere or the same confidence everywhere.
