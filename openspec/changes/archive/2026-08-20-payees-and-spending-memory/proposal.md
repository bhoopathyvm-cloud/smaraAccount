## Why

Users re-pick category every Starbucks; import has rules but typing has no memory.

## What Changes

- Payee entity: name, default category, optional default account.
- Autocomplete on description field from payees + import history, reusing
  the existing `normalizeDescription` (trim + lowercase) match already
  used by import category rules — no new normalization logic.
- Remember last account and category per payee and globally as fallback.
- Saving a category rule from an import group assignment offers to also
  link (or create) a payee with the rule's keyword as its name, so the
  next manual entry for that payee gets the same category/account
  defaults the import rule already learned.

## Capabilities

### New Capabilities

- `payees`

### Modified Capabilities

- `import-category-rules`
- `user-guide`

## Impact

- As described in What Changes.
- Tests and user guide.
