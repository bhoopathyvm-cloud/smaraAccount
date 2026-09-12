# From a Weekend Idea to a Shipping Product

Smara Account started as a learning exercise, not a plan. I wanted to
understand how far I could get building a real application almost entirely
in conversation with an AI, with no fixed idea of where it would end up. A
few months later, it's a working, tested, multi-platform app, translated
into forty-three languages, with a real release process behind it. This
post is the short version of how it got from one of those states to the
other — the rest of this series goes deep on the specific moments that
mattered along the way.

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
the pain I was already feeling on this project. I started experimenting
with the same discipline here, deliberately in small pieces rather than
rewriting everything at once, to see whether it would actually hold up
against a real, AI-assisted workflow rather than just a classroom example.

## It didn't fix everything immediately

Having a written specification made it much easier to tell *whether* a
change was right. It didn't automatically make the AI write good code, or
write tests, or follow the specification faithfully rather than
approximately. Early on, a spec would go in, and a large volume of code
would come back — more than I'd asked for, more than I could easily review
line by line — and testing it would turn up real breakage. The discipline
on the *requirements* side wasn't yet matched by discipline on the
*implementation* side.

I'd wanted a strict test-first style from the start — write the failing
test, then write the code that makes it pass — but simply asking for that
didn't reliably produce it. What actually worked was turning the question
back around: instead of asking for TDD, I asked how to make it
*impossible to skip*. The answer was mechanical, not aspirational — real
checks that run automatically and block a commit outright if formatting,
static analysis, or the project's own completion rules don't pass, rather
than a style guideline anyone (including the AI) could quietly ignore under
time pressure. The same instinct got applied to the specification side too:
a change can't be filed away as finished unless every task it committed to
is actually, verifiably done.

## The bigger win came after that

Even with all of that in place, the quality of what shipped still wasn't
where I wanted it. The gap that actually closed it was real integration
testing — tests that launch the genuine, compiled app and drive its actual
interface, not a simplified stand-in for it — combined with making that
kind of test a requirement for *every* significant piece of behavior, and
having the AI run those tests itself and see them pass before it was
allowed to consider anything finished. That change, more than the process
discipline that came before it, is the single biggest reason the app
actually works as well as it does today.

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
