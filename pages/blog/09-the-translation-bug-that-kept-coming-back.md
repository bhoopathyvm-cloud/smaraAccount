# The Translation Bug That Kept Coming Back

The exact same *category* of bug turned up three separate times in this
project, in three different languages, weeks apart — and nobody noticed it
was a pattern until the third occurrence.

## What the bug actually looks like

Smara Account supports forty-three languages. Most of the translations were
AI-generated rather than written by a human translator for each one, which
is a reasonable and explicit trade-off for a project at this scale — full
human review of forty-three languages' worth of interface text simply isn't
realistic for a project like this.

The specific failure mode that kept recurring: two different concepts in
the interface — say, "Create a group" and "Edit a group" — would get
translated to the *exact same string* in a given language. In English these
are obviously different words. In an AI-translated batch, where each string
is often translated somewhat independently, it's entirely possible for two
different English phrases to collapse onto the same translated output,
especially when the underlying concepts are related.

The consequence isn't cosmetic. A test — or a real user — trying to tap
"edit" on a specific item would find every single item's edit button
matching the same label, because they were all now indistinguishable
strings as far as the interface was concerned.

## Why it took three tries to notice the pattern

Each occurrence looked, in isolation, like its own unrelated problem: a
crash in a backup-restore flow in one language, an ambiguous button match
in a completely different flow in another language. Nothing about the
symptoms screamed "this is the same root cause as last time" — because,
technically, it wasn't the same root cause. It was the same *class* of root
cause, showing up in a different pair of strings each time.

It was only once the third instance turned up, and someone went looking
specifically for "is there a matching pair of identical strings anywhere
near this bug," that the pattern became obvious in hindsight: this project
now had a known, specific, previously-seen failure mode for AI-translated
content, and the fix each time was the same shape — find another word
already used correctly elsewhere in that language's translations, and reuse
it, rather than trying to write a brand-new translation from scratch with
no local precedent to check against.

## What this changes about trusting AI-generated content

This isn't an argument against using AI to generate translations at this
scale — the alternative was either no translations at all, or years of
professional translation work this project was never going to get. It's an
argument for knowing the *specific* way this kind of content tends to fail,
rather than treating "AI-generated" as a single, vague risk to worry about
in general.

The useful version of caution here isn't "review everything by hand" — that
defeats the entire point of generating it this way. It's "know the one or
two concrete failure signatures this generation method actually produces,
and build a cheap check for exactly those." A duplicate-string scan across
translation files would have caught every one of these three bugs before
any of them shipped, at a cost of seconds. That's a much more useful kind of
skepticism than a general unease about trusting AI output — specific,
checkable, and cheap enough to actually do.
