## ADDED Requirements

### Requirement: Register view model async reads are teardown-safe
The register view model SHALL NOT raise an unhandled error, call
`notifyListeners`, or recompute rows after it has been disposed, and its
one-shot reads of repository streams (e.g. the category list) SHALL tolerate a
stream that closes without emitting — treating it as "no data" rather than an
error.

#### Scenario: Categories stream closes empty during teardown
- **WHEN** the accounts stream emits, then the view model is disposed and the
  category-list stream closes without ever emitting
- **THEN** no exception escapes and no `notifyListeners` fires after disposal

#### Scenario: Categories stream emits normally
- **WHEN** the category-list stream emits a list while the view model is alive
- **THEN** register rows are enriched with category names exactly as before
