## 1. Landing page + About page

- [x] 1.1 Add `pages/about.md` containing the current `pages/index.md` body (village near Tiruppur, radio, textile→CS, Switzerland, bank; Interests; Open Source pointer), H1 `# About`; trim the "This site is where I collect…" line to a plain link to Open Source
- [x] 1.2 Replace `pages/index.md` with `# Smara` and a single H2 section — `## The Name` — using the relayed etymology copy verbatim (stated as-is, not embellished). The "Why We Built This" / care-worker mission copy is held back (not public yet), not included.
- [x] 1.3 Append the reserved HTML comment after "The Name" marking the seam for the held-back mission copy and a future SmaraAI section; add no heading or placeholder text for it

## 2. Site config

- [x] 2.1 `mkdocs.yml`: `site_name: Smara`, `site_url: https://smara-ai.ch`
- [x] 2.2 `mkdocs.yml` `nav`: add `- About: about.md` (placement per design Open Question — default: last, after Open Source)
- [x] 2.3 `pages/CNAME`: `bhoopathy.com` → `smara-ai.ch`

## 3. Domain references in content

- [x] 3.1 `.github/workflows/pages.yml`: update the `# DNS for bhoopathy.com is also manual…` comment to `smara-ai.ch`
- [x] 3.2 `pages/open-source/smara-account/privacy-policy.md` line ~16: `bhoopathy.com` → `smara-ai.ch`
- [x] 3.3 `pages/open-source/smara-account/index.md`: replace the "The name also links the project back to this personal site. My own story started far from software, in a farming village…" sentence with one that keeps the memory/trust idea and links to `../../about.md`; leave the rest of the page unchanged
- [x] 3.4 `grep -rn "bhoopathy.com" pages/ mkdocs.yml .github/workflows/pages.yml` — no remaining references except intended ones

## 4. Build check

- [x] 4.1 `pip install -r requirements.txt && mkdocs build --strict` passes locally (no broken internal links after moving the bio to `about.md`)
- [x] 4.2 Serve locally (`mkdocs serve`) and confirm: Home shows `# Smara` + the "The Name" section; About shows the bio and is in the nav; Open Source → Smara Account pages still render

## 5. Spec

- [ ] 5.1 Apply the `project-website` spec delta (Purpose text `bhoopathy.com` → `smara-ai.ch`; the two MODIFIED requirements) when this change is archived/synced

## 6. External (human, not code)

- [ ] 6.1 Point `smara-ai.ch` DNS at GitHub Pages (A/AAAA + `www` CNAME) per GitHub's docs
- [ ] 6.2 Set the repository's GitHub Pages custom domain to `smara-ai.ch` and re-enable HTTPS
- [ ] 6.3 Decide whether to keep `bhoopathy.com` and 301-redirect it to `smara-ai.ch`, or let it lapse
