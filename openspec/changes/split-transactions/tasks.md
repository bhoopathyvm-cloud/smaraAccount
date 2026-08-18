## Tasks

- [ ] 1.1 Repository: `recordSplitTransaction` (or widen `recordTransaction`) posts one financial-account leg plus one posting per category line; validate lines sum exactly to the total and every line has an active category before posting anything.
- [ ] 1.2 Split UI on the record screen: add/remove category lines, live remainder, save disabled while remainder is nonzero (`split-transactions` capability). A single line is the existing non-split experience unchanged.
- [ ] 1.3 `RegisterViewModel`/`RegisterRow`: replace the single `firstWhere`-based "other posting" lookup with the full list of non-financial-account postings on the entry; `RegisterRowTile` renders a summarized multi-category label when there's more than one.
- [ ] 1.4 Validation: reject a split whose lines don't sum to the total, or where any line lacks an active category; surface which line failed.
- [ ] 1.5 Confirm (regression test, no code expected) reversal and Summary already handle a split entry correctly with no change: `reverseEntry` iterates all postings generically; `watchSummary` joins at the posting level.
- [ ] 1.6 Tests: split posts correctly (repository); register row shows all categories for a split (view/view-model); reversal of a split entry restores all legs; Summary totals a split's legs into their separate categories correctly.
- [ ] 1.7 User guide: recording a split, and that reversing a split reverses every leg at once.
