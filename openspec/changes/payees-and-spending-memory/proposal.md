## Why

Users re-pick category every Starbucks; import has rules but typing has no memory.

## What Changes

- Payee entity: name, default category, optional default account.
- Autocomplete on description field from payees + import history.
- Remember last account and category per payee and globally as fallback.
- Link import keyword rules to payee names where possible.

## Capabilities

### New Capabilities

- `payees`

### Modified Capabilities

- `import-category-rules`
- `user-guide`

## Impact

- As described in What Changes.
- Tests and user guide.
