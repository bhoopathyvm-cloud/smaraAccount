## ADDED Requirements

### Requirement: User Guide Documents Investment Research
The user guide SHALL explain how to copy a research prompt for an instrument into a consumer AI tool the user already uses, how optional in-app briefs use a user-supplied API key, that only instrument identifiers leave the device, and that briefs are not financial advice. The guide SHALL NOT describe broker dealing or live quotes as shipped.

#### Scenario: Research section exists once the flow is reachable
- **WHEN** the research-brief flow is reachable in the app
- **THEN** the user guide contains a section describing copy-prompt, optional API keys, privacy limits, and the not-advice label
