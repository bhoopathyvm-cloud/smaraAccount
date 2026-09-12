# The Bug That Taught Me to Stop Trusting a Good Story

An AI agent I was working with built a genuinely convincing theory for why a
test was crashing. It named a specific mechanism, pointed at a specific line
of code, and the reasoning held together. It was completely wrong. The real
cause was a typo in a translation file, several files away from anything the
theory mentioned.

## The setup

A batch of automated tests was failing across several languages, all with a
similar-looking crash: something calling `setState()` on a piece of UI that
had already been torn down. One language in particular — Kashmiri — kept
failing at a spot involving a "restore from backup" flow: a dialog opens, an
operation runs in the background, and eventually the dialog is supposed to
either succeed or show an error.

## The first theory

Reading the relevant code in isolation, a plausible explanation emerged: a
button that starts the restore operation is supposed to disable itself while
the operation is running, so a second tap can't start it twice. But that
disabling only takes effect after the UI rebuilds — and if the test's own
retry logic tapped the button again just before that rebuild landed, it
could plausibly fire the same action twice. The first tap succeeds and
closes the dialog; the second tap's result comes back later, finds the
dialog already gone, and crashes trying to update it.

That's a real category of bug. It's the kind of race condition that
genuinely happens in real apps. The explanation was detailed, specific, and
entirely consistent with the code as written.

It was also not what was actually happening.

## What was actually happening

Going back to the raw failure log — rather than reasoning from the code —
turned up something the double-tap theory didn't predict: there was no
retry message in the log at all. A genuine double-tap race, given how the
test's retry logic works, should have printed a specific diagnostic line
before anything crashed. It wasn't there. Whatever was going wrong, it
wasn't that.

The real cause, found by directly comparing two lines in a translation
file, was almost embarrassingly simple: the text used for "the backup
finished successfully" and the text used for "open the restore backup
dialog" had been translated to the exact same string in that one language.
A part of the test looking for "did the success message appear" was instead
finding the still-visible button from *before* the operation even started —
because it happened to say the same thing. The test thought the operation
had already finished, moved on to the next step, and tore down the dialog
while the real operation was still running in the background. When it
finally finished, it tried to update a dialog that was already gone.

Same symptom. Completely different cause. Fixed by changing one word in one
translation file — no code change at all.

## What actually caught it

Not cleverness. A habit: when a theory explains a failure, ask what else
that theory predicts, and go check whether that other thing is actually
true. The double-tap theory predicted a specific log line. That log line
wasn't there. That single check would have ended the wrong theory in thirty
seconds, well before any time was spent thinking about how to fix a race
condition that didn't exist.

## The generalizable lesson

An AI-generated explanation — or, honestly, a human-generated one — can be
fluent, specific, mechanistically plausible, and still wrong. Plausibility
is not evidence. The question worth asking isn't "does this explanation
sound right," it's "what does this explanation predict that I haven't
checked yet, and is that thing actually true." That question is cheap to
ask and it's the difference between fixing the real bug in five minutes and
confidently fixing the wrong one.
