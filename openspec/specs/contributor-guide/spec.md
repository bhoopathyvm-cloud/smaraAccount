# contributor-guide

## Purpose

A discoverable, root-level entry point explaining how to propose and
submit a contribution, and where the architecture and
engineering-discipline rules that govern it live. (Purpose derived from
the `project-documentation` change; refine as the capability evolves.)

## Requirements

### Requirement: Root-Level Contributor Entry Point
The repository SHALL contain a `CONTRIBUTING.md` file at the repository root explaining how to propose and submit a contribution: the OpenSpec propose → apply → archive workflow, the branch-per-change convention (one branch per OpenSpec change, named after the change), the rule against committing directly to `main`, and the pull-request submission process. `CONTRIBUTING.md` SHALL link to the existing `Specs/architecture/smara-architecture.md` and `Specs/architecture/smara-tech-guidelines.md` for architecture and engineering-discipline rules rather than restating their content.

#### Scenario: CONTRIBUTING.md exists at the root
- **WHEN** a contributor opens the repository on GitHub and starts a pull request or issue
- **THEN** `CONTRIBUTING.md` is present at the repository root for GitHub to surface automatically

#### Scenario: Contributor guide explains the OpenSpec workflow
- **WHEN** a contributor reads `CONTRIBUTING.md`
- **THEN** it explains, in order, how a change is proposed, implemented, and archived using OpenSpec

#### Scenario: Contributor guide links to architecture docs instead of duplicating them
- **WHEN** a contributor reads `CONTRIBUTING.md` looking for architecture or coding-discipline rules
- **THEN** it links to `Specs/architecture/smara-architecture.md` and `Specs/architecture/smara-tech-guidelines.md` rather than repeating their content inline

### Requirement: README Links to Contributor and User Documentation
`README.md` SHALL link to `CONTRIBUTING.md` from its "Contributing" section and to `docs/user-guide.md` from a usage-oriented section, so a reader lands on the right document for their goal without needing to browse the repository tree.

#### Scenario: README's Contributing section links to CONTRIBUTING.md
- **WHEN** a reader views the "Contributing" section of `README.md`
- **THEN** it links to `CONTRIBUTING.md`

#### Scenario: README links to the user guide
- **WHEN** a reader views `README.md` looking to learn how to use the app
- **THEN** it links to `docs/user-guide.md`
