## 1. MkDocs setup

- [x] 1.1 Add `requirements.txt` at the repo root, pinning `mkdocs-material` to its current stable version
- [x] 1.2 Add `mkdocs.yml` at the repo root: `site_name`, `docs_dir: pages`, `theme.name: material`, and an explicit `nav:` list for the four pages
- [x] 1.3 Add `pages/CNAME` containing `bhoopathy.com`

## 2. Site content (Markdown only, no hand-written HTML)

- [x] 2.1 Write `pages/index.md`: the problem (cloud-trust-required or not-genuinely-tamper-evident existing tools) and SMARA Account's solution (local-first, tamper-evident, no server), drawing on `README.md`'s existing framing without copying it verbatim
- [x] 2.2 Write `pages/how-it-was-built.md`: the AI spec-driven development story, the OpenSpec propose → apply → archive workflow, linking to `CONTRIBUTING.md` for anyone who wants to contribute the same way
- [x] 2.3 Write `pages/architecture.md`: summarize stack, MVVM+Repository layering, and the security/privacy stance from `Specs/architecture/smara-architecture.md` and `smara-tech-guidelines.md`, linking to both rather than duplicating them
- [x] 2.4 Write `pages/whats-built.md`: list each capability under `openspec/specs/` with a one-line description

## 3. Deployment

- [x] 3.1 Add `.github/workflows/pages.yml`: on push to `main` with paths filtered to `pages/**`, `mkdocs.yml`, `requirements.txt`, and the workflow file itself — set up Python, `pip install -r requirements.txt`, `mkdocs build`, then deploy the built `site/` output via `actions/upload-pages-artifact` and `actions/deploy-pages`, following `flutter-ci.yml`'s existing style (checkout action version, etc.) where applicable
- [x] 3.2 Give the workflow the `pages: write` and `id-token: write` permissions `actions/deploy-pages` requires
- [x] 3.3 Add `site/` (MkDocs' default build output directory) to `.gitignore` — it's a build artifact, never committed

## 4. Manual setup (outside this change - document, don't attempt to automate)

Not automatable from here — for the author to perform after this change merges:

- [ ] 4.1 Enable GitHub Pages in the repository's Settings → Pages, source = "GitHub Actions"
- [ ] 4.2 At the domain registrar for `bhoopathy.com`, add A records pointing at GitHub Pages' current published IPv4 addresses (and optionally AAAA records for IPv6) — see [GitHub's documentation on managing a custom domain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site) for the current addresses, since they can change
- [ ] 4.3 Once DNS has propagated, verify the domain in the repository's Settings → Pages (GitHub flags an unverified custom domain)

## 5. Verify

- [x] 5.1 Run `mkdocs serve` locally and click through all four pages, confirming navigation, search, and content render correctly in the Material theme
- [x] 5.2 Run `mkdocs build --strict` locally to catch broken internal links/nav references before relying on CI
- [x] 5.3 Confirm the workflow YAML is valid (e.g. `actionlint` if available, or a careful manual read) before relying on it to deploy
- [ ] 5.4 After merging and the author completes the manual DNS/Settings steps, confirm the live site loads at `bhoopathy.com` over HTTPS
