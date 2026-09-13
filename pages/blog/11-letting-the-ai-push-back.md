# Letting the AI Push Back — and Correcting It When It's Wrong

Some of the most useful moments in this project weren't the AI getting
something right on the first try. They were the moments where a wrong
assumption got caught and corrected in the same conversation — sometimes
more than once on the same decision, in quick succession.

## Assuming "tested here" means "only works here"

Partway through a discussion about which platforms a testing process should
cover, an AI-drafted plan quietly assumed a particular platform simply
wasn't supported by the app, and scoped an entire proposal around that
assumption. It was wrong, and the reasoning behind it was a specific,
nameable mistake: the *only* testing that had actually happened during that
particular working session was on one platform, and the AI had conflated
"this is the only platform I've personally exercised so far" with "this is
the only platform this product supports." The product had, in fact, already
been used successfully on other platforms — just not in that conversation.

That correction took one sentence to make and one sentence to accept.
Because the plan existed as a document, not as code, fixing it meant
editing a paragraph, not unwinding an implementation built on the wrong
premise.

## Changing course twice on the same decision

A separate decision — whether a new, faster automated check should
*supplement* an existing, much slower manual process, or *replace* it
outright — went through two rounds of revision in a matter of minutes. The
first framing was "keep both, for safety." Almost immediately after, that
got corrected to "no, replace the old one entirely." Then, once the actual
trade-off became concrete — replacing it fully meant losing a specific kind
of real-device coverage that the faster check genuinely couldn't provide —
it was corrected once more, landing on a version that kept a narrower,
cheaper version of the old check specifically for what the new one
couldn't cover.

Three positions on the same question, each one an improvement on the last,
arrived at within the same short exchange. None of the earlier positions
were unreasonable given what was known at the time; each correction came
from a piece of the trade-off becoming clearer as the conversation
continued.

## What made the corrections cheap

Both of these were fast, low-stakes corrections for the same reason: the
decision existed as a written proposal before any implementation started.
Reversing course meant rewriting a few sentences in a document that hadn't
been acted on yet. If either decision had already been half-built into
running code before the correction happened, the same conversation would
have needed to include "and now let's also undo this" — a much more
expensive sentence to say, and a much easier one to avoid saying by just
going along with the first draft instead.

## The mindset this produces

Treat an AI's first answer as a draft worth reacting to, not a conclusion
worth accepting. The value isn't in the AI being right immediately — it's
in the cost of being wrong staying low enough that correcting it is a
one-line comment instead of a rewrite. That only holds if the habit on the
other side is actually saying "wait, that's not right" the moment it's
noticed, rather than waiting to see whether the plan works out anyway. The
fastest corrections in this project were the ones made out loud,
immediately, before anything downstream had a chance to depend on the
mistake.
