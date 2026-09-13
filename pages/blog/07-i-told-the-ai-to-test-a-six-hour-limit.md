# I Told the AI to Test a "Six-Hour Limit." It Found a Real Limit at Eleven Minutes.

For a while, one part of this project's testing process was accepted as
something that simply could not be automated: a thorough, real-device test
suite that took eight to ten hours to run for a single language, on a
single platform. Running it across every language the app supports would
have taken weeks. The assumption — reasonable, on its face — was that this
could never move into automated CI, because hosted CI runners cap every job
at six hours, full stop. Ten hours doesn't fit in six.

Nobody had actually tried, though. The six-hour number was true, and the
conclusion drawn from it — "so this can never run in CI" — had never
actually been tested against a different platform target than the one that
produced the ten-hour number in the first place.

## Trying it anyway

The app had recently gained a second desktop target — Linux, alongside the
original macOS build — and nobody knew how long the same test suite would
take there. Rather than reason about it, I asked for it to just be tried:
dispatch the real suite, on the real Linux target, on a real CI runner, and
see what actually happens.

The first attempt found something nobody expected: every single job got cut
off after about eleven minutes, regardless of how much progress it had
made. That's nowhere near six hours. For a moment this looked like
confirmation of the "impossible" theory, just arriving faster than
expected.

It wasn't that. Reading the actual timestamps across all forty-three
parallel jobs — not just the summary, the literal minute-by-minute record —
showed something specific: every job died at almost exactly the same
elapsed time from when it *started*, no matter when in the batch it had
started running. That's not a six-hour platform limit. That's a completely
different ceiling, coming from the specific type of runner being used, one
that reclaims jobs after roughly ten minutes for reasons that have nothing
to do with the six-hour number anyone had been reasoning from.

Switched to a different runner type. Ran it again.

## What was actually true

The full suite — the real thing, all thirty-seven checks, driving a real
launched build through its actual interface — finished in about eleven
minutes per language. Not eleven hours. Eleven minutes. Across all
forty-three supported languages, in parallel, well within any limit anyone
had been worried about. What had been assumed to be a multi-week, physically
impossible undertaking turned out to be forty to fifty times faster than the
process everyone had been treating as the only option.

The six-hour number had been true the entire time. It had simply never been
the actual constraint in play.

## Why this is worth writing down

It would have been completely reasonable to never test this. The reasoning
that ruled it out wasn't sloppy — a real platform limit really did exist,
and ten hours really doesn't fit in six. The mistake wasn't in the logic.
It was in never re-checking whether that logic still applied once one of
its inputs — which platform the suite ran on — had quietly changed.

An "impossible" conclusion inherited from an old constraint is worth
re-testing the moment anything that constraint depended on changes,
even if the change seems unrelated. And this is exactly the kind of work an
AI collaborator is well suited for: dispatching a real run, reading
thousands of lines of raw log output across dozens of parallel jobs, and
reporting back only the specific number that mattered — the tedious,
unglamorous verification work that's easy for a person to skip and easy
for an AI to simply do.
