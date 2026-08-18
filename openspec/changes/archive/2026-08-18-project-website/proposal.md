## Why

The project has no public-facing website — only the in-repo `README.md`,
`docs/user-guide.md`, and `CONTRIBUTING.md`, none of which is reachable
without already being in the repository. The author wants a proper
project site — what problem SMARA Account solves, how it was built (the
AI spec-driven development approach via OpenSpec), and good technical
documentation — published via GitHub Pages and linked to their
`bhoopathy.com` domain so it can be shared and updated independently of
someone browsing the repo.

## What Changes

- Add a `pages/` directory of Markdown source files, built into a static
  site by [MkDocs](https://www.mkdocs.org/) with the
  [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
  theme — no hand-written HTML/CSS, no JavaScript framework. Chosen over
  GitHub Pages' native Jekyll build specifically because Jekyll's native
  build only serves from the repo root or a `/docs` folder, which would
  collide with the existing `docs/user-guide.md`; MkDocs' build step has
  no such constraint, so `pages/` (the author's original preference)
  works directly.
- Site content, across a small number of pages:
  - **Home**: the problem (existing accounting tools require trusting a
    cloud provider, or don't make tampering with history actually
    difficult) and what SMARA Account solves (local-first, tamper-evident
    double-entry ledger, no server).
  - **How it was built**: the AI spec-driven development approach — every
    line written by AI, constrained by OpenSpec specs and the project's
    engineering guidelines, the propose → apply → archive workflow.
  - **Architecture**: a public-friendly rendering of the technical
    documentation (stack, layering, security/privacy stance) derived from
    `Specs/architecture/`, explicitly pointing back to the repository as
    the living source of truth rather than duplicating it verbatim.
  - **What's built**: a capability listing derived from `openspec/specs/`,
    showing the spec-driven approach concretely.
- Add a `CNAME` file in `pages/` set to `bhoopathy.com` (the root domain,
  per the author's choice) — MkDocs copies non-Markdown files from the
  source directory straight into the built site, so this reaches the
  deployed output unchanged. DNS itself is outside this change; the task
  list notes what the author needs to configure with their registrar.
- Add `mkdocs.yml` at the repo root (MkDocs' own convention) configuring
  `docs_dir: pages`, the Material theme, and the page navigation.
- Add a pinned `requirements.txt` for the one new build-time dependency
  (`mkdocs-material`), following the same "commit the lockfile, everyone
  resolves the same graph" discipline `smara-tech-guidelines.md` already
  states for Flutter dependencies.
- Add a GitHub Actions workflow (`.github/workflows/pages.yml`) that
  installs the pinned MkDocs dependency, runs `mkdocs build`, and deploys
  the built output to GitHub Pages on push to `main`, scoped to `pages/**`,
  `mkdocs.yml`, `requirements.txt`, and the workflow file itself, so
  unrelated app commits don't trigger a redeploy.
- Out of scope: a JavaScript framework or component library for the site
  (Material for MkDocs already provides nav/search/theming); a blog/CMS
  for ongoing updates — the author adds a Markdown page and pushes,
  matching the site's own "no unnecessary tooling beyond what's needed"
  stance.

## Capabilities

### New Capabilities
- `project-website`: a static GitHub Pages site (problem statement,
  build-approach narrative, technical documentation, capability listing)
  deployed via GitHub Actions and served from the author's custom domain.

### Modified Capabilities

(none)

## Impact

- New: `pages/index.md`, `pages/how-it-was-built.md`,
  `pages/architecture.md`, `pages/whats-built.md`, `pages/CNAME`
- New: `mkdocs.yml`, `requirements.txt` (repo root)
- New: `.github/workflows/pages.yml`
- No application code, schema, or Flutter/Dart dependency changes — the
  one new dependency (`mkdocs-material`) is Python, isolated to the site
  build, and never touches the app.
- Requires a one-time, out-of-band DNS change at the author's domain
  registrar (an A/ALIAS record for the apex domain to GitHub Pages) and
  enabling GitHub Pages in the repository's Settings — both outside what
  this change can do from the repo itself; documented as manual tasks.
