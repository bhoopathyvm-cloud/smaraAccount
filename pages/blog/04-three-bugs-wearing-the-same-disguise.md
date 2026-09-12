# Three Bugs Wearing the Same Disguise

A single automated test run came back with six failures. All six had the
same general shape — a language-specific test crashing somewhere in the
middle of a flow — and it would have been faster, and completely wrong, to
treat that as one bug and write one fix for "the language test issue."

## The tempting shortcut

When six failures share an obvious surface similarity — same test suite,
same rough category, same kind of error message — it's natural to assume
they share a cause. Fix the one underlying thing, and all six should turn
green. This is sometimes true. It's also exactly the assumption that leads
to declaring victory after fixing one real problem, while three others
quietly remain, waiting to reappear the next time conditions line up the
same way.

## The check that mattered

Before writing any fix, the six failing languages were re-run *in
isolation* — pulled out from the other thirty-seven that had passed, run
again on their own, specifically to answer one question: are these the same
failure, reliably, or did they just happen to fail together once?

They failed again, identically, which ruled out the failures being random
noise. But "identically" only held up at the surface level. Looking closely
at exactly *which* test failed and *why*, in each of the six, split them
into three genuinely distinct groups:

- Four languages failed the same single check, for the same underlying
  reason — a piece of test code was looking for the digit sequence "15" on
  screen, but several languages render calendar numbers using their own
  native numerals, not the digits the test assumed.
- One language failed because of a translation collision — two different
  buttons had been given the exact same translated label, so a test looking
  for one of them ambiguously found several.
- A different language failed because of the *same kind* of translation
  collision, but in an entirely different pair of strings, in a completely
  different part of the interface.

Three fixes. Three unrelated files. None of them would have been found by
writing one fix aimed at "the CI failures" and calling it done once the
test suite went green again — because a single fix aimed at any one of
these three causes would, by coincidence, have left the exact right number
of remaining tests still red for someone to notice something was still
wrong. It's entirely possible to imagine a version of this investigation
that stopped one bug too early and shipped it anyway, satisfied.

## The habit this produced

When more than one failure shares a category, the first useful question
isn't "what's the fix" — it's "are these actually the same failure."
Answering that means isolating each one and re-running it on its own before
touching any code, not just eyeballing the error messages and assuming
similarity means identity. It costs a few extra minutes. It's the
difference between fixing three real, separate problems and confidently
fixing one problem three times.
