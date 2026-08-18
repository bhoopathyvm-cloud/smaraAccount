## Tasks

- [ ] 1.1 `HomeViewModel`: this-month category aggregates, reusing the existing Summary query scoped to the current calendar month.
- [ ] 1.2 Home Add action (bottom sheet or route): Spent / Received / Moved money / Import.
- [ ] 1.3 This-month-by-category list on Home.
- [ ] 1.4 Register: replace the three separate FABs with one Add action opening the same choice as Home's Add, with the current account pre-selected; preserve the existing archived-account disabled condition and the separate closeout affordance unchanged.
- [ ] 1.5 Tests: Home aggregates match Summary's own computation for the same range; register's single Add action is disabled exactly when the three FABs it replaces would have been; closeout affordance still works independently.
- [ ] 1.6 User guide: Home as the primary capture surface; register's consolidated Add.
