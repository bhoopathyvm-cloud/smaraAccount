# What a Fully-Built Feature Taught Me About Paperwork Drift

A feature in this project was completely built. Real code, real tests, a
real merged pull request, working exactly as intended. Its own tracking
document — the record that was supposed to say how much of it was done —
still said zero percent.

## How that happens

Nobody lied about the status. Nobody skipped the work. What happened was
simpler and more mundane: the feature got built, tested, and merged through
one path, and the document meant to track its progress simply never got
updated to reflect that, because updating it wasn't part of the path the
actual work took. The code was real. The paperwork was stale. Both things
were true about the same feature at the same time, and nothing about
looking at either one in isolation would tell you they disagreed.

This was found by accident, while starting what looked like a routine task:
"implement this feature." The very first files touched already had the
feature's fields, its settings, its comments referencing exactly this
change by name — all fully in place, none of it new.

## The instinct that would have made things worse

The obvious next move, given a task that says "implement X" and a tracking
document that says "0% done," is to start implementing. That instinct,
followed here, would have been actively harmful — at best duplicating
already-correct work, at worst subtly diverging from it in ways that would
have been much harder to untangle than starting from a blank slate.

## What happened instead

Before writing anything, the actual codebase was audited against every
single item the tracking document listed as unfinished — not read at a
glance, but checked file by file: does this specific piece exist, is it
wired up, is there a test for it. Almost everything did exist, and most of
it worked correctly.

Two things genuinely didn't, though, and they were only findable *because*
the audit was thorough rather than a quick skim:

- One part of the feature — a confirmation step in a dialog — had unit
  tests for its individual pieces, but nothing that actually drove the real
  interface through the real flow end to end. Writing that test turned up a
  second, unrelated bug: the test's own fake data source would have spun in
  an infinite loop under specific conditions, a bug that existed only in the
  test scaffolding but would have made the test itself unreliable if it had
  ever been written carelessly.
- A separate, earlier bug fix — in an unrelated part of the project — had
  changed a source file but never regenerated the derived file that the
  actual running app used. The source was fixed. The compiled app wasn't.
  Nobody would have found this by reading the tracking document for the
  feature currently under review; it only turned up because the audit
  process involved actually running the generation step fresh, rather than
  trusting that it had already been run.

Both of those were real, fixable problems that a blind re-implementation of
the "unfinished" feature would never have surfaced, because the
re-implementation would have been solving a problem — "this doesn't exist
yet" — that wasn't real.

## The lesson

A project's stated status and its actual status can silently diverge, and
neither one announces that it's happened. This is especially true the
moment more than one person, or more than one AI session, touches the same
codebase — which was very much the case here. The fix isn't more careful
bookkeeping, though that helps. It's a habit: before building something a
tracker says is missing, check whether it's actually missing. Verifying
current reality costs an hour. Discovering the divergence after building on
top of a false assumption costs considerably more.
