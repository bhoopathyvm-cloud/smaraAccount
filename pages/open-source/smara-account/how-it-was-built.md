# How It Was Built

SMARA Account is a learning implementation of two things at once: a
tamper-evident ledger, and AI spec-driven development. Every line of
application code is written by AI — but not freely. It's constrained by
a strict set of engineering guidelines and by feature specifications
defined through [OpenSpec](https://github.com/Fission-AI/OpenSpec). The
specs drive the implementation, not the other way around.

For an end user, that matters because the project is trying to make two
kinds of trust inspectable: the trustworthiness of the financial history,
and the trustworthiness of the development process. The ledger records
corrections instead of rewriting old entries, while the repository keeps
human-readable specs that say what each shipped feature is supposed to do.

## Why Spec-First, Not Vibe-Coded

It's tempting to treat an AI coding assistant as a fast typist and just
describe what you want in the moment. That works for small, throwaway
things. It falls apart for a project meant to keep working and stay
coherent over many sessions and many months: without a written record of
*what the system is supposed to do*, each session re-derives intent from
whatever code already exists — and drift compounds. OpenSpec exists to
keep "what should happen" written down, reviewable, and separate from
"what the code currently does."

Concretely, that means: no behavior ships that isn't backed by a spec
scenario. If a review finds code that isn't covered by one, the fix is
either a spec update or a code change to match the spec — not silence.

## The Workflow: Propose → Apply → Archive

Every change to the project goes through the same three stages:

1. **Propose** — before writing any code, describe the change: why it's
   needed (`proposal.md`), how it will work for anything non-trivial
   (`design.md`), and the exact testable behavior it adds or changes, as
   `SHALL`/`MUST` requirements with `WHEN`/`THEN` scenarios (a spec
   delta under `specs/<capability>/`). A `tasks.md` checklist breaks the
   implementation into steps.
2. **Apply** — implement the change by working through `tasks.md`,
   checking off each task as it's completed, writing tests alongside the
   code they cover.
3. **Archive** — once a change is merged, its spec deltas are folded
   into the single source of truth for that capability under
   `openspec/specs/`, and the change itself moves to an archive
   directory, keeping a record of *why* each capability exists the way
   it does.

This keeps two things true at all times: the specs under `openspec/specs/`
describe what the app actually does right now (not what's planned), and
every past change is still readable later, instead of being squashed
into an opaque commit history.

## Want To Build The Same Way?

The full workflow, branching convention, and the engineering guidelines
this project holds itself to are documented in
[`CONTRIBUTING.md`](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/CONTRIBUTING.md)
in the repository. Pull requests are welcome, and expected to follow the
same spec-first discipline as the rest of the project.
