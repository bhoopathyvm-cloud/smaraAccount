# project-website

## Purpose

A static GitHub Pages site (problem statement, build-approach narrative,
technical documentation, capability listing) deployed via GitHub Actions
and served from the author's custom domain.

## Requirements

### Requirement: Public Site States the Problem and the Approach
The repository SHALL contain a static website under `pages/` whose home page states, in visitor-facing terms, the problem SMARA Account solves (existing accounting tools require trusting a cloud provider, or don't make tampering with recorded history genuinely difficult) and how this project solves it (a local-first, tamper-evident, double-entry ledger with no server). A separate page SHALL describe how the project was built: the AI spec-driven development approach via OpenSpec, and the propose → apply → archive workflow.

#### Scenario: Home page states the problem and solution
- **WHEN** a visitor opens the site's home page
- **THEN** it explains what problem the project solves and how, without requiring the visitor to already know the codebase

#### Scenario: A dedicated page explains the build approach
- **WHEN** a visitor navigates to the "how it was built" page
- **THEN** it explains the OpenSpec-driven, AI-authored development approach and the propose/apply/archive workflow

### Requirement: Technical Documentation Links to the Repository as Source of Truth
The site SHALL contain a technical/architecture page summarizing the stack, layering, and security/privacy stance in visitor-friendly terms, and SHALL link to the corresponding files in the repository (`Specs/architecture/smara-architecture.md`, `smara-tech-guidelines.md`) rather than duplicating their full content, so the two never silently diverge.

#### Scenario: Architecture page summarizes rather than duplicates
- **WHEN** a visitor reads the site's architecture page
- **THEN** it presents a summary of the stack, layering, and security/privacy stance
- **AND** it links to the full internal documentation in the repository for anyone wanting complete detail

### Requirement: Site Lists Implemented Capabilities
The site SHALL contain a page listing the project's implemented capabilities, derived from `openspec/specs/`, so a visitor can see concretely what the spec-driven approach has produced.

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
