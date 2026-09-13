# Spec First, Code Second

Over about two months, roughly a hundred distinct changes went into Smara
Account. Every one of them has a paper trail: why the change was needed,
how it was designed, what tasks it broke down into, and — checked off one
by one — what actually got done. That habit, more than any single tool or
model, is the biggest reason this project moved as fast as it did without
falling apart.

## The workflow

I use a lightweight discipline called OpenSpec, worked through in three
steps: propose, apply, archive.

**Propose** means writing down, before any code exists, what the change is
and why. Not a ticket title — an actual paragraph explaining the problem,
what will change, and what capabilities are affected. Then a design
document for anything with real decisions to make (why this approach and
not another), and a task list broken into small, checkable steps.

**Apply** means working through that task list, one item at a time, marking
each one done only once it's genuinely done — analyzed, tested, verified,
not just written.

**Archive** means moving the finished change into a permanent record once
every single task is checked. Not "mostly done." Every task.

## Why this mattered more than I expected

The obvious benefit is traceability — I can look back at any of those
hundred changes and know exactly why a particular decision was made, months
later, without having to reconstruct it from a diff. That's useful, but it's
not the real win.

The real win is that writing the proposal *before* the code exists forces a
different kind of thinking. It's much easier to catch a bad idea, an
under-specified edge case, or a scope that's quietly grown too large when
it's three paragraphs in a document than when it's four hundred lines of
Dart. I caught real problems this way — places where the actual behavior I
wanted wasn't what I'd first assumed — at the cost of five minutes of
reading, instead of the cost of an hour of implementation and a redo.

It also changed how I could work with an AI collaborator specifically. A
proposal document is something an AI can be asked to justify, question, or
push back against *before* committing to an approach. Once code exists, the
conversation tends to become "does this work," which is a much narrower and
less useful question than "is this the right thing to build."

## The rule that did the most work

Of everything in this workflow, one rule mattered more than the rest
combined: **never mark a change complete, and never archive it, unless
every single task is checked.** Not "the important tasks." Not "the ones
that were actually about the feature, ignoring the verification steps."
Every one.

This sounds almost too simple to be a real practice, but it closed a
specific failure mode that would otherwise have been easy to fall into:
work that *looks* finished — the feature runs, the demo works — quietly
skipping the boring parts (a live-device check, a regression re-run, an
edge case the design document explicitly called out) and getting called
done anyway. With this rule enforced literally — including, at one point,
by an automated check that refuses to let a partially-finished change be
filed away as complete — that quiet drift stops being possible. A change is
either fully done, with evidence for every task, or it stays visibly open.

I found out later in this project exactly how easy that drift is: a fully
built, fully working, fully merged feature turned up with its own tracking
document still showing zero percent complete, because nobody had gone back
to update the paperwork once the real work finished. That's a story for
another post. But it's a direct illustration of why the rule needs to be
mechanical, not a matter of judgment in the moment.

## What I'd tell someone starting this

Writing the "why" before the "how" feels like overhead the first few times.
It stops feeling like overhead the first time it saves you from building
the wrong thing, or from discovering — after the fact — that a "finished"
piece of work was never actually finished at all.
