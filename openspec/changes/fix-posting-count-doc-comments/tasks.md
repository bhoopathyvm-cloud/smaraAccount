## 1. Correct the doc comments

- [x] 1.1 Update the `Posting` doc comment in `lib/domain/models/posting.dart` to "two or more postings", matching `CONTEXT.md`.
- [x] 1.2 Update the `Postings` table doc comment in `lib/data/database/tables/postings_table.dart` the same way.
- [x] 1.3 Confirm no other source or spec outside the archive still states "exactly two" postings (`git grep -n -i "exactly two"`).

## 2. Verify

- [x] 2.1 `dart format --output=none --set-exit-if-changed .` and `flutter analyze` pass.
- [x] 2.2 `flutter test` passes.
