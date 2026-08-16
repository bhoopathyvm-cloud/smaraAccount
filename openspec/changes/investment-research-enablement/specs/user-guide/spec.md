## ADDED Requirements

### Requirement: User Guide Documents Tap-to-Browser Research
The user guide SHALL explain that tapping an instrument name opens the user's favourite consumer AI website with a pre-filled research prompt, that this is not an API integration and not financial advice, and that quantities and costs are not sent. The guide SHALL NOT describe in-app AI accounts, API keys, or broker dealing as part of this flow.

#### Scenario: Research enablement is documented when reachable
- **WHEN** tap-to-browser research is reachable from inventory
- **THEN** the user guide contains a section describing the favourite-tool setting, what the prompt asks, and that SMARA does not log into the AI tool
