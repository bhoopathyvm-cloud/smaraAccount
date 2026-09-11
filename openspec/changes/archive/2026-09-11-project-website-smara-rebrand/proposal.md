## Why

The project website is moving from the author's personal domain
`bhoopathy.com` to `smara-ai.ch`. The current site is framed as
Bhoopathy's personal site with Smara Account nested under an Open Source
section, and the landing page is the author's biography. On the new
domain the site should lead with **Smara** — what the name means and why
the work exists — and keep the author biography as a separate "About"
page. The site should also be structured so a future section introducing
a separate "SmaraAI" project can be added later without reworking the
brand story.

## What Changes

- **Domain → `smara-ai.ch`** everywhere it is named: `pages/CNAME`,
  `mkdocs.yml` `site_url`, the `pages.yml` workflow comment, the Smara
  Account privacy-policy page, and the `project-website` spec's purpose
  text. `mkdocs.yml` `site_name` changes from `Bhoopathy` to `Smara`.
- **New landing page** (`pages/index.md`) opens with `# Smara` and a
  single H2 section — **"The Name"** (the Sanskrit *smara* / *smṛti* =
  remembrance etymology, presented as-is). The mission copy ("Why We Built
  This", the care-worker framing) is **deliberately held back — not yet
  public** — and a reserved HTML comment marks where it, and a later
  SmaraAI project section, slot in without reworking "The Name". **No
  placeholder content for the held-back sections now.**
- **New "About the author" page** carries the current biographical home-
  page content (village near Tiruppur, radio, textile-to-CS, Switzerland,
  writing software at a Swiss bank, interests) essentially unchanged, and
  is added to the top-level navigation.
- **`pages/open-source/smara-account/index.md`** loses its one sentence
  that calls the site "this personal site" / ties the name to the
  author's story; it points at the About page instead. No other Smara
  Account project-page content changes.
- The Open Source section, the Smara Account project pages, the
  deployment workflow's trigger paths, and the GitHub Pages Actions
  deployment method are unchanged.

## Capabilities

### Modified Capabilities

- `project-website`: the site is served from `smara-ai.ch`, not
  `bhoopathy.com`; the landing page introduces Smara by its name (one
  headed section, extensible for later mission / project sections) instead
  of introducing the author; the author biography moves to a dedicated
  "About" page reachable from the top-level navigation; the custom-domain
  requirement's `CNAME` target changes accordingly.

## Impact

- `pages/index.md` (rewritten: `# Smara` + "The Name" only)
- `pages/about.md` (new — the relocated biography)
- `pages/CNAME` (`bhoopathy.com` → `smara-ai.ch`)
- `mkdocs.yml` (`site_name`, `site_url`, `nav` gains About)
- `.github/workflows/pages.yml` (comment mentions the new domain)
- `pages/open-source/smara-account/index.md` (drop the "personal site"
  sentence; link to About)
- `pages/open-source/smara-account/privacy-policy.md` (domain reference)
- `openspec/specs/project-website/spec.md` via the delta in this change
- External, human, not code: DNS for `smara-ai.ch`, the repo's GitHub
  Pages custom-domain setting, and any redirect from `bhoopathy.com`.
