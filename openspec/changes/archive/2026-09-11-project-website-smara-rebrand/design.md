## Context

The site is MkDocs (Material theme), source under `pages/`, deployed by
`.github/workflows/pages.yml` (GitHub Actions Pages method) on pushes that
touch `pages/**`, `mkdocs.yml`, `requirements.txt`, or the workflow. Today:

- `mkdocs.yml`: `site_name: Bhoopathy`, `site_url: https://bhoopathy.com`,
  `nav: Home / Open Source (Projects, Smara Account: Overview, What's
  Built, Architecture, How It Was Built, Privacy Policy)`.
- `pages/index.md`: the author's biography.
- `pages/CNAME`: `bhoopathy.com`.
- `pages/open-source/smara-account/index.md`: has "The name also links the
  project back to this personal site. My own story started far from
  software, in a farming village…".
- `pages/open-source/smara-account/privacy-policy.md` line 16 names
  `bhoopathy.com`.

The brand-story copy for the new landing page was drafted by the user and
relayed from another session. It is to be used **as written**, not
embellished; the etymology (`smara` स्मर / `smṛti` from the root `smṛ` "to
remember"; `smṛti` as one of the two streams of classical Indian textual
tradition) is factually sound and stated plainly.

## Goals / Non-Goals

**Goals**
- New domain everywhere it is named, in one change.
- Landing page introduces Smara by its name; author bio preserved on its
  own page and still one click away.
- Landing page structured so held-back sections (the mission copy, a
  future SmaraAI section) drop in later without editing "The Name".
- `mkdocs build --strict` stays green (CI runs it).

**Non-Goals**
- Publishing the mission copy ("Why We Built This" / the care-worker
  framing) or a SmaraAI section now — held back deliberately; only leave
  the seam.
- Rewriting the Smara Account project pages (Overview, What's Built,
  Architecture, How It Was Built) beyond the single "personal site"
  sentence.
- Setting up DNS, the GitHub Pages custom-domain field, or a
  `bhoopathy.com` → `smara-ai.ch` redirect — external human steps, tracked
  in tasks, not done here.
- Changing the deployment workflow's mechanism or trigger paths.

## Decisions

### 1. Landing page: one H2 now ("The Name"), a reserved comment for later

`pages/index.md` becomes:

```markdown
# Smara

## The Name
<the relayed "smara / smṛti = remembrance" paragraph, as written>

<!-- Reserved for later sections (the "why we built this" mission copy,
     and a future SmaraAI project introduction). Keep the H2 structure
     so a new "## …" section slots in without reworking "The Name". -->
```

The mission copy ("Why We Built This" — everyone gets one life / close the
admin gap / care workers first) was drafted but the user is **not making
it public yet**, so it is left out entirely rather than stubbed. No
`## …` heading, no "coming soon" text — an empty heading would render in
the page and the Material TOC. The HTML comment is the seam; a later
change adds the next H2 above it.

### 2. Author bio → `pages/about.md`, added to top-level nav

Move the current `pages/index.md` body verbatim (heading becomes
`# About` or `# About the Author`; the "This site is where I collect
personal notes and open source projects, starting with Smara Account"
line can stay or be trimmed to point at Open Source). Add
`- About: about.md` to `mkdocs.yml` `nav`, after Home (or after Open
Source — see Open Questions).

### 3. `site_name: Smara`

The site is now the Smara site. The Material header title and browser tab
follow `site_name`; `Bhoopathy` there would contradict the domain and the
landing page. The author's name lives on the About page and in
`repo_url`.

### 4. Smara Account overview: drop the "personal site" tie

Replace "The name also links the project back to this personal site. My
own story started far from software, in a farming village where memory,
trust, and spoken records mattered." with a sentence that keeps the
memory-and-trust idea but points at the About page rather than asserting
the site is a personal site. The rest of that page (What Smara Means, The
Problem, The Solution, …) is unchanged — note it already carries its own
`smara` etymology paragraph, which is fine and now complements the
landing page rather than duplicating its intent.

### 5. Spec delta scope

`project-website`'s **Purpose** and two requirements change:
- "Public Site Has Personal Home and Open Source Sections" → the home
  page tells the Smara brand story (not the author bio); a dedicated
  About page introduces the author in ≤200 words; nav exposes Home, Open
  Source, and About.
- "Site Is Configured for a Custom Domain" → `CNAME` = `smara-ai.ch`.

The deployment, architecture-page, capability-listing, and
requests/contributors requirements are untouched (the only
`bhoopathy.com` in the deploy requirement is a workflow *comment*, not
normative text — updated as a task).

## Risks / Trade-offs

- **[Note]** The drafted "Why We Built This" copy pitched care-worker
  documentation, which would have sat oddly next to the site's only linked
  project (Smara Account, personal/household tamper-evident accounting).
  The user chose to hold that copy back for now, so the landing page is
  just the etymology and the mismatch does not arise yet; when the mission
  copy (and the SmaraAI section) are published, the umbrella framing
  should be revisited alongside them.
- **[Risk]** Inbound links and search results point at `bhoopathy.com`. →
  **Mitigation:** a redirect is an external human step in tasks; the
  content itself is domain-agnostic apart from the named references fixed
  here.
- **[Trade-off]** `mkdocs build --strict` fails on a broken internal link;
  moving the bio to `about.md` means any link that pointed at the old home
  anchor must be updated. Grep for `](index` / `](/` references as a task.

## Migration Plan

1. Add `pages/about.md` with the current `pages/index.md` body.
2. Replace `pages/index.md` with `# Smara` + the "The Name" section +
   reserved comment.
3. `mkdocs.yml`: `site_name: Smara`, `site_url: https://smara-ai.ch`, add
   About to `nav`.
4. `pages/CNAME` → `smara-ai.ch`.
5. Update the `pages.yml` comment and `privacy-policy.md` domain line.
6. Fix the Smara Account overview's "personal site" sentence + any
   internal links to the old home.
7. `mkdocs build --strict` locally; check the nav and both pages render.
8. Apply the `project-website` spec delta.
9. External (human): point `smara-ai.ch` DNS at GitHub Pages, set the
   repo's Pages custom domain, optionally redirect `bhoopathy.com`.
10. Rollback = revert the `pages/` + `mkdocs.yml` + spec changes; restore
    `CNAME`.

## Open Questions

- **Nav placement of About** — right after Home, or last (after Open
  Source)? Leaning last, so Home → Open Source is the primary path.
- **Landing `# H1`** — `# Smara` alone, or a short tagline line under it?
  The relayed copy has no tagline; leaving just `# Smara` unless the user
  supplies one.
- **`bhoopathy.com` redirect** — keep the old domain and 301 it, or let it
  lapse? External decision, noted not resolved.
- **About page H1** — `# About` vs `# About the Author`. Minor.
