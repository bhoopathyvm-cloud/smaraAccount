## Context

`lib/ui/core/` already holds the app's shared, flat (no subfolders)
building blocks: `app_colors.dart`, `app_spacing.dart`, `app_typography.dart`,
`app_theme.dart`, `app_shell.dart`, `money_formatter.dart`. It's the
correct home for new shared widgets, matching existing convention.

`Specs/design/smara-design-system.md` already specifies a single
"Destructive — red outlined" button pattern (`border: 1.5px solid #e24b4a;
color: #e24b4a; background: transparent`) — the design intent was always
one pattern. The code just never centralized it: it's hand-copied at three
call sites (`account_management_view.dart` lines 374 and 464,
`category_management_view.dart` line 147), with the account-management
copies even missing the design system's specified `1.5px` border width
that category-management's copy has — a small, real inconsistency this
change also fixes by construction (all three converge on one
implementation).

`Specs/architecture/smara-tech-guidelines.md`'s Golden Rules already cover
dependency duplication (#8: "don't add a second package that does what one
already in pubspec.yaml already does") and code cleanup after replacement
(#9). Neither currently covers UI component duplication specifically —
this change adds that as a new rule, closing the gap the user identified.

## Goals / Non-Goals

**Goals:**
- One implementation each for: destructive-action confirmation, money
  amount entry, entity-by-id picking, and status/error banners — used at
  every currently-identified call site.
- No user-visible behavior change: every migrated screen looks and
  behaves the same; only where the markup and minor-unit-parsing logic
  live changes.
- A stated rule (Golden Rule addition) so a fifth copy of any of these
  doesn't get written next time, per the user's "architectural constraint"
  ask.

**Non-Goals:**
- A general-purpose component library or design-system tooling (Storybook
  equivalent, `flutter-add-widget-preview` wiring) — out of scope unless a
  future change calls for it. `flutter-add-widget-preview` remains
  available per-widget if a contributor wants it later.
- Consolidating things that only superficially look similar but serve
  different purposes — e.g. the CSV column-mapping picker in
  `statement_import_view.dart` is a different shape (mapping a file
  column to a field, not picking an existing entity by id) and is left
  alone; forcing it into the entity-picker widget would distort that
  widget's contract for one non-matching caller.
- Any change to `smara-design-system.md` itself — its "Destructive" pattern
  is already correct; this change makes the code match it, not the other
  way around.

## Decisions

- **Four separate small widgets, not one mega-component.** Each solves a
  distinct, independently-useful shape (confirmation dialog, text field,
  dropdown, banner) with its own call signature. A single configurable
  do-everything widget would need enough parameters to cover all four
  shapes that it stops being simpler than the duplication it replaces.

- **`confirmDestructiveAction`: a function returning
  `Future<bool>`, not a widget class.** The two identical call sites
  (`_confirmArchiveGroup`, `_confirmArchive`) are entirely `showDialog`
  invocations with no state of their own — a top-level function
  (`Future<bool> confirmDestructiveAction({required BuildContext context,
  required String title, required String message, String
  confirmLabel = 'Archive'})`) matches that shape exactly and is the
  simplest possible replacement. `category_management_view.dart`'s
  inline archive button (no confirmation dialog today) is unaffected in
  behavior — only its `OutlinedButton.styleFrom` block is replaced by a
  new shared `destructiveButtonStyle` constant it can reuse without
  adding a confirmation step that didn't exist before (scope discipline:
  this change deduplicates markup, it doesn't add new confirmation UX not
  already present).

- **`MoneyAmountField`: a widget wrapping `TextField`,** taking a
  `TextEditingController`, a `labelText`, an optional `suffixText`
  (currency code), an optional `helperText`, and an
  `ValueChanged<int?> onChangedMinor` callback that already does the
  `double.tryParse` → minor-unit-rounding conversion internally — so the
  parsing logic duplicated in every `onChanged` callback today is also
  deduplicated, not just the field's markup. Call sites keep owning their
  own `TextEditingController` (unaffected by this change, sidesteps the
  dispose-timing issue this branch's `account-group-dialog-dispose-race`
  fix depends on lifecycle ownership staying with the caller).

- **`EntityPickerField<T>`: a generic widget wrapping
  `DropdownButtonFormField<String>`,** taking a `labelText`, a
  `List<T> items`, `String Function(T) idOf`, `String Function(T) labelOf`,
  the current `String? value`, and `ValueChanged<String?> onChanged`.
  Generic over `T` so both `Account`-typed callers (most call sites) and
  any future non-`Account` entity can use it without a cast. Callers that
  need extra filtering (e.g. transfer's "exclude the from-account from the
  to-account list") filter their own `items` list before passing it in —
  the widget itself stays filter-agnostic.

- **`StatusBanner`: a thin wrapper over `MaterialBanner`,** taking a
  `message`, an optional `onDismiss` (renders a "Dismiss" action when
  provided, matching `account_management_view.dart`'s existing behavior),
  and an optional `isError` flag controlling text color (matching
  `statement_import_view.dart`'s red currency-mismatch text vs.
  `account_management_view.dart`'s default-styled error text) —
  covers both existing call sites' actual behavior without inventing new
  banner variants neither currently uses.

- **Migrate every identified call site in this change**, per Golden Rule
  #9 — no old copy of any of the four patterns is left behind once its
  replacement exists.

- **Add the new Golden Rule directly to
  `Specs/architecture/smara-tech-guidelines.md`'s existing numbered list**
  (after #9), not a separate document — keeps all Golden Rules in the one
  place contributors already know to check.

## Risks / Trade-offs

- [`EntityPickerField<T>`'s generic-callback shape could be seen as
  overengineered for what's currently only ever called with `Account`.] →
  Mitigation: `idOf`/`labelOf` are two one-line closures at each call
  site — negligible overhead versus a non-generic `EntityPickerField`
  that would need a second near-identical widget the day a non-`Account`
  entity needs picking (e.g. a future currency or provider picker).
- [Migrating 8 view files in one change is a wide diff to review.] →
  Mitigation: each file's migration is mechanical (swap markup for the
  new widget, delete the old block) and behavior-preserving; existing
  widget tests for each view continue to pass unchanged and are the
  primary safety net, not manual review alone.
- [A new Golden Rule is easy to state and easy to ignore without
  enforcement.] → Mitigation: out of scope for this change to build
  automated enforcement (e.g. a custom lint); stated as a rule now,
  revisit tooling if duplication recurs despite it.
