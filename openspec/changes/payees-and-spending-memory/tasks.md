## Tasks

- [ ] 1.1 Schema: `payees` table (name, default category, optional default financial account).
- [ ] 1.2 CRUD (minimal, inline or in Settings) for payees.
- [ ] 1.3 Record form: autocomplete on description using `normalizeDescription` (reused, not reimplemented); apply matched payee's defaults, overridable.
- [ ] 1.4 Remember last-used account/category per payee after each recorded transaction.
- [ ] 1.5 Import: when saving a category rule from a group assignment, offer to also link/create a payee named after the rule's keyword with the rule's category as default; declining leaves rule-saving unchanged.
- [ ] 1.6 Tests: payee suggestion and override; last-account/category memory updates after recording; rule-save payee-linking offer, both accepted and declined paths.
- [ ] 1.7 User guide: payees, autocomplete, and the rule-save linking offer.
