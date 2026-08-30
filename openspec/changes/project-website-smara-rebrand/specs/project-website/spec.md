## MODIFIED Requirements

### Requirement: Public Site Has Personal Home and Open Source Sections
The repository SHALL contain a static website under `pages/` whose home page tells the Smara brand story — what the name means and why the work exists — in visitor-facing terms. The home page SHALL consist of clearly separated top-level (H2) sections and SHALL be structured so an additional section (for a later project) can be added without reworking the existing sections; the home page SHALL NOT be the Smara Account project's own landing page. A dedicated "About" page SHALL introduce the author, his background, and his software interests, and SHALL be reachable from the top-level navigation. The top-level navigation SHALL expose Home, Open Source, and About. The Open Source section SHALL list public projects, with Smara Account as the first project and room for future projects.

#### Scenario: Home page tells the Smara brand story
- **WHEN** a visitor opens the site's home page
- **THEN** it explains, in separated headed sections, what "Smara" means and why the work exists
- **AND** it is not the Smara Account project's landing page

#### Scenario: Home page is extensible for a later project section
- **WHEN** a later change adds a section introducing another project to the home page
- **THEN** it can be added as a new top-level section without editing the existing "name" and "why" sections

#### Scenario: About page introduces the author
- **WHEN** a visitor opens the About page
- **THEN** it introduces the author, his background, and his software interests in 200 words or fewer
- **AND** it is linked from the top-level navigation

#### Scenario: Open Source page lists projects
- **WHEN** a visitor opens the Open Source section
- **THEN** it lists Smara Account as the first project and leaves the structure open for more projects later

#### Scenario: Open Source page welcomes requests and contributors
- **WHEN** a visitor wants to request a feature or contribute
- **THEN** the Open Source section invites issues and contributions, suggests describing the real problem and desired outcome, allows optional AI-assisted issue refinement, and states that issues are picked up as time permits

### Requirement: Site Is Configured for a Custom Domain
The `pages/` directory SHALL contain a `CNAME` file naming the domain the site is served at, matching the domain configured in the repository's Pages settings and in the domain's DNS records. The site SHALL be served from `smara-ai.ch`, and the site generator's configured site URL SHALL match that domain.

#### Scenario: CNAME file matches the intended domain
- **WHEN** the repository's GitHub Pages custom domain is configured
- **THEN** the `pages/CNAME` file's contents are `smara-ai.ch`, matching that configured domain and the site generator's site URL
