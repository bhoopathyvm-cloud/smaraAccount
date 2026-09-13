## Purpose

Defines what "the store listings are ready" actually means for Smara
Account, so App Store Connect and Google Play Console submissions aren't
blocked by missing or inconsistent listing content at the last minute.

## ADDED Requirements

### Requirement: App description, keywords, category, and support URL
Both stores SHALL have a finished app description, keyword list, category,
and support URL before submission. Content SHALL be adapted from the
project's existing public description of the app (`pages/open-source/
smara-account/`) rather than written independently, so the store listing
and the public project description don't drift apart or contradict each
other.

#### Scenario: Description drafted from existing project copy
- **WHEN** the app description is drafted for either store
- **THEN** it is derived from `pages/open-source/smara-account/index.md`'s
  existing "what it is / the problem / the solution" framing, adapted to
  each store's length and format constraints

#### Scenario: Category matches the app's actual nature
- **WHEN** a store category is chosen
- **THEN** it reflects that Smara Account is a personal finance / ledger
  app (matching the `LSApplicationCategoryType` of
  `public.app-category.finance` already set for the macOS build)

### Requirement: Screenshots at each store's required sizes
Both stores SHALL have screenshots captured from a real running build
(Simulator or device), organized into each store's required device/size
classes, before submission. Placeholder, mocked-up, or marketing-only
imagery SHALL NOT substitute for a real captured screen.

#### Scenario: Screenshots come from a real build
- **WHEN** a screenshot is captured for either store's listing
- **THEN** it is taken from an actual running build of the app (iOS
  Simulator, a real device, or the signed macOS build), not a mockup

#### Scenario: Screenshot sizes match store requirements
- **WHEN** screenshots are organized for submission
- **THEN** each is sized/cropped to the specific device class App Store
  Connect or Play Console requires for that image, not a single
  one-size-fits-all export

### Requirement: Privacy declarations cross-checked against the real policy
Google Play's Data Safety form and App Store Connect's App Privacy
section SHALL each be completed by cross-checking every declared data
practice against `pages/open-source/smara-account/privacy-policy.md`,
line by line, rather than filled in from memory or assumption. A
declaration SHALL NOT claim a data practice (collection, sharing,
tracking) that the actual privacy policy doesn't also describe, and
SHALL NOT omit one the privacy policy does describe.

#### Scenario: Data Safety form matches the privacy policy
- **WHEN** Google Play's Data Safety form is completed
- **THEN** every data type and purpose declared there has a corresponding,
  consistent statement in `privacy-policy.md`

#### Scenario: App Privacy section matches the privacy policy
- **WHEN** App Store Connect's App Privacy ("nutrition label") section is
  completed
- **THEN** every data type and purpose declared there has a corresponding,
  consistent statement in `privacy-policy.md`

### Requirement: Google Play content rating questionnaire completed
Google Play's content rating questionnaire SHALL be completed accurately
based on the app's actual content and functionality before submission.

#### Scenario: Content rating reflects actual app behavior
- **WHEN** the content rating questionnaire is answered
- **THEN** answers reflect what the app actually does (a personal finance
  ledger with no user-generated social content, no ads, no gambling
  mechanics) rather than defaults or guesses
