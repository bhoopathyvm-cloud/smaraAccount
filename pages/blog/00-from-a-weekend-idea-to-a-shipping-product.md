# From a Weekend Idea to a Shipping Product

Smara Account started as a learning exercise, not a plan. I wanted to
understand how far I could get building a real application almost entirely
in conversation with AI, with no fixed idea of where it would end up. A few
months later, it's a working, tested, multi-platform app, translated into
forty-three languages, with a real release process behind it. This post is
the short version of how it got from one of those states to the other — the
rest of this series goes deep on the specific moments that mattered along
the way.

## Where it actually started

The first stretch of this project was what I'd call vibe coding: describing
what I wanted in plain language, letting the AI write whatever it thought
that meant, running it, and iterating by feel. This is a genuinely good way
to explore an idea. It told me quickly whether a feature concept even made
sense, without spending real design effort on something that might not
survive contact with reality.

It's also a way of working that quietly stops scaling the moment the
project has more than a screen or two worth of behavior to keep straight.
There was no fixed record of what the app was actually supposed to do, so
there was no way to evaluate whether a given change was correct — only
whether it looked right in the moment. Regressions crept in unnoticed.
Explaining context to a fresh conversation, or to myself a week later, got
slower every time. It became genuinely painful before I admitted that the
approach itself, not any specific bug, was the problem.

## The turn

Around that point, a training session at work happened to be about
spec-driven development — writing down what a system should do, in a
structured way, before writing the code that does it. I'd seen the idea
before in the abstract; this was the first time I connected it directly to
the pain I was already feeling on this project.

What I actually learned went further than that one practice. Alongside
spec-driven development, I found myself relearning architecture as a
guardrail, design as a guardrail, and a required development approach —
test-driven development, specifically — as a guardrail too. These aren't
new ideas. What was new was realizing *where* this knowledge normally
lives: mostly in the heads of a handful of senior engineers on any given
team, passed on through review comments, hallway conversations, and
osmosis, rarely written down in full because a human colleague can absorb
most of it without a document. Working with an AI collaborator removes that
shortcut entirely. It has no tenure on the team, no hallway conversations to
have absorbed, nothing to fall back on except what's actually written down.
For the first time, I had to take knowledge that normally stays implicit
and put it into an explicit document, in real depth — not because the AI
demanded it, but because nothing less was going to work.

## Writing it down is not the same as it being followed

Here's the part that surprised me most, and it's worth saying plainly: even
with all of that written down, the AI does not reliably follow it. Most of
the time it does. Often enough, it doesn't — and it doesn't fail loudly or
ask for clarification when it skips something, it just quietly proceeds as
if the instruction weren't there.

I saw this most starkly once, on a separate codebase I was experimenting
with around the same time. I asked directly for test-driven development —
write the failing test first, then the code. What I got instead was code.
Straight ahead, fast, confident-looking code, with no tests leading it and
no tests following it, as if the instruction had simply been noted and set
aside. It's a good image for what an unguided AI actually does: like a
horse at full gallop with no blinders and no reins — genuinely fast, and
headed wherever its own momentum takes it, not necessarily where you
pointed it. The breakage only became visible once real interface testing
started. Everything had looked fine right up until then.

That single experience reframed how I thought about instructions to an AI
collaborator. An instruction in a document is a request, not a constraint.
If a rule actually needs to hold, it needs a mechanism that enforces it,
not a sentence that asks for it.

## Building the mechanism, one layer at a time

The mechanism I ended up building was a stack of tests, not a single kind:
unit tests for individual pieces of logic, integration tests for how those
pieces behave together against a real database and real local state, and —
the layer that mattered most — a kind of business-acceptance test that
actually drives the compiled application through its real interface, the
way a person would use it, and checks that the outcome is what the
requirement actually promised.

This did not come for free. As the test coverage got more serious, a
development-and-test cycle that used to take minutes started taking hours.
That's a real cost, and I paid it deliberately, because the alternative —
fast cycles producing code that only *looked* right — was the exact problem
I was trying to get out of.

What made the cost worth it was what started happening once the pieces
were all in place: I could let an agent run a full piece of work end to
end, without stepping in along the way, and it would routinely introduce a
real bug or two during that run — and then find it and fix it itself,
before anything ever reached a pull request I'd need to review. That's a
genuinely different working relationship than reviewing a wild first draft
line by line. The guardrails weren't just catching mistakes for me anymore;
they were letting the AI catch its own.

## How the work actually split

In practice, I ended up using more than one AI tool for more than one
purpose: research and detailed requirement-writing through Claude, and most
of the day-to-day implementation through Cursor's agents, working from
whatever had been specified. I'd assumed, going in, that simply routing
everything through one strong model would be what brought the bug rate
down. It wasn't. What actually moved the needle was the engineering
discipline wrapped around whichever model was writing the code — the
guardrails, not the brand name.

## The lesson underneath all of it

An AI model is trained on an enormous amount of code, and a meaningful
share of that code is not good code. Left with a vague instruction and no
constraints, it's just as likely to confidently reproduce the bad patterns
as the good ones — fast, capable, and completely unconcerned with which
direction it's actually running. A horse that fast is genuinely useful.
It's also not something you'd want to simply sit on and hope for the best.
You train it, you fit it with blinders and reins, and only then does that
speed become something you can actually steer. Put real guardrails around
an AI collaborator — architecture, design, a required development approach,
enforced mechanically rather than requested politely — and the same
underlying model narrows down to consistently good results. That
distinction, more than any specific tool or model, is what actually
determined how this project turned out.

## Where the story gets more interesting

Once the app was working reliably in one language, the next real test was
scale: forty-three languages, nearly all of the translation work done by AI
rather than a human translator for each one. That's where a whole new
category of problem showed up — not "does the code work," but "does the
same tested behavior actually hold once you change the words underneath
it." That turned out to be its own long story, worth its own posts.

The rest of this series walks through the specific moments in more detail:
the discipline that made corrections cheap, the bugs that looked like one
thing and were three, the assumption about a testing platform that turned
out to be completely wrong, and the very particular way AI-generated
translations tend to fail. None of it happened in a straight line, and none
of it happened without real setbacks along the way — but a weekend
exploration did become a real, working product, and I think the path
between those two points is worth writing down honestly.
