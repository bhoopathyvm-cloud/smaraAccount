# project-website

## Purpose

A static GitHub Pages site deployed via GitHub Actions and served from the
author's personal domain, `bhoopathy.com`. The site introduces Bhoopathy
on the landing page, then organizes public work under an Open Source
section. Smara Account is the first project in that section, with its
problem statement, build-approach narrative, technical documentation, and
capability listing kept under the project page.

## Requirements

### Requirement: Public Site Has Personal Home and Open Source Sections
The repository SHALL contain a static website under `pages/` whose home page introduces Bhoopathy and his interests in visitor-facing terms, without making Smara Account the whole site's landing page. The top-level navigation SHALL expose Home and Open Source. The Open Source section SHALL list public projects, with Smara Account as the first project and room for future projects.

#### Scenario: Home page introduces the author
- **WHEN** a visitor opens the site's home page
- **THEN** it introduces Bhoopathy, his background, and his software interests in 200 words or fewer

#### Scenario: Open Source page lists projects
- **WHEN** a visitor opens the Open Source section
- **THEN** it lists Smara Account as the first project and leaves the structure open for more projects later

#### Scenario: Open Source page welcomes requests and contributors
- **WHEN** a visitor wants to request a feature or contribute
- **THEN** the Open Source section invites issues and contributions, suggests describing the real problem and desired outcome, allows optional AI-assisted issue refinement, and states that issues are picked up as time permits

### Requirement: Smara Account Project Page States the Name, Problem, Approach, and User Benefit
The Smara Account project page SHALL explain the Sanskrit meaning of "Smara" as remembrance, memory, or recollection, and connect that meaning to the project's goal of preserving financial history. It SHALL then state, in visitor-facing terms, the problem Smara Account solves (existing accounting tools require trusting a cloud provider, or don't make tampering with recorded history genuinely difficult), how this project solves it (a local-first, tamper-evident, double-entry ledger with no server), and what a non-technical user gets from that design (verified history, warnings instead of silently wrong totals, safer backup/export review, and an honest correction trail). A separate page under the Smara Account project SHALL describe how the project was built: the AI spec-driven development approach via OpenSpec, and the propose → apply → archive workflow.

#### Scenario: Smara project page explains the project
- **WHEN** a visitor opens the Smara Account project overview
- **THEN** it explains what the name means, what problem the project solves, how, and why that helps an ordinary user, without requiring the visitor to already know the codebase

#### Scenario: Smara project page explains how to request or contribute
- **WHEN** a visitor reads the Smara Account project overview
- **THEN** it links to the repository issues, welcomes feature requests and contributions, suggests using AI tools to improve a request if helpful, and explains that larger contributions normally start with an OpenSpec proposal

#### Scenario: Site gives background references without requiring them
- **WHEN** a visitor reads the public site
- **THEN** the Smara Account pages provide optional cross-references to relevant security and accounting material, including NIST integrity/signature/hash definitions, OWASP logging guidance, secure audit-log research, accounting audit-trail explanations, electronic accounting record guidance, and an industry example of a cryptographically verifiable journal

#### Scenario: A dedicated page explains the build approach
- **WHEN** a visitor navigates to the "how it was built" page
- **THEN** it explains the OpenSpec-driven, AI-authored development approach and the propose/apply/archive workflow

### Requirement: Technical Documentation Links to the Repository as Source of Truth
The Smara Account project section SHALL contain a technical/architecture page summarizing the stack, layering, and security/privacy stance in visitor-friendly terms, and SHALL link to the corresponding files in the repository (`Specs/architecture/smara-architecture.md`, `smara-tech-guidelines.md`) rather than duplicating their full content, so the two never silently diverge.

#### Scenario: Architecture page summarizes rather than duplicates
- **WHEN** a visitor reads the site's architecture page
- **THEN** it presents a summary of the stack, layering, and security/privacy stance
- **AND** it links to the full internal documentation in the repository for anyone wanting complete detail

### Requirement: Site Lists Implemented Capabilities
The Smara Account project section SHALL contain a page listing the project's implemented capabilities, derived from `openspec/specs/`, so a visitor can see concretely what the spec-driven approach has produced.

#### Scenario: Capability listing reflects shipped work
- **WHEN** a visitor reads the "what's built" page
- **THEN** it lists capabilities that correspond to entries under `openspec/specs/` at the time the page was last updated

### Requirement: Site Deploys Automatically via GitHub Actions
A GitHub Actions workflow SHALL build the Markdown source under `pages/` into a static site and deploy it to GitHub Pages on every push to `main` that changes files under `pages/`, the site generator's configuration file, its pinned dependency file, or the workflow file itself, using the GitHub Actions Pages deployment method (not the classic branch/folder dropdown), so an arbitrary source directory name is usable as the site source.

#### Scenario: A push to a page redeploys the site
- **WHEN** a commit changing a file under `pages/` is pushed to `main`
- **THEN** the GitHub Actions workflow builds and deploys the updated site

#### Scenario: An app-only commit does not redeploy the site
- **WHEN** a commit that changes no file under `pages/`, the site generator's configuration, its pinned dependency file, or the workflow file is pushed to `main`
- **THEN** the site deployment workflow does not run

### Requirement: Site Is Configured for a Custom Domain
The `pages/` directory SHALL contain a `CNAME` file naming the domain the site is served at, matching the domain configured in the repository's Pages settings and in the domain's DNS records.

#### Scenario: CNAME file matches the intended domain
- **WHEN** the repository's GitHub Pages custom domain is configured
- **THEN** the `pages/CNAME` file's contents match that domain exactly
