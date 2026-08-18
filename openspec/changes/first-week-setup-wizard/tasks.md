## Tasks

- [ ] 1.1 Wizard route(s) after onboarding completes, reachable exactly once on first run.
- [ ] 1.2 Main-account naming step calls the existing `createFinancialAccount`; optional credit-card and cash-account steps do the same, skippable.
- [ ] 1.3 Expand the starter category seed list (Food out, Phone, Health added).
- [ ] 1.4 Verify (no code expected): an empty account group is already omitted from Home — confirm the existing `watchHomeOverview` behavior still holds, don't add new hiding logic.
- [ ] 1.5 Tests: wizard creates the expected accounts for each combination of answers; skipping optional steps creates only the main account; expanded categories appear in the picker after first launch.
- [ ] 1.6 User guide: the first-week wizard and expanded starter categories.
