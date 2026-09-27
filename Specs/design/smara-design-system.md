# SmaraAccounting — Design System

> Adapted from an earlier project's design system (same 3-color discipline and
> component structure). All care-home/domain-specific content has been
> replaced with accounting semantics. The rule itself — and its exact palette
> — carries over unchanged; only what the colors and components *mean* has
> changed.

## The 3-Color Rule

SmaraAccounting uses exactly 3 colors. No exceptions. The palette is
implemented once in `lib/ui/core/app_colors.dart` and assembled into
`ThemeData` by `lib/ui/core/app_theme.dart`; no widget introduces a color
outside `AppColors`. The app icon (navy-and-ivory folded S,
`assets/branding/app_icon.png`) uses the same navy.

```
PRIMARY:   #1a3a6b   Navy Blue
           Used for: headers, buttons, active states,
                     all overlays, bottom nav active,
                     the financial account's own accent

NEUTRAL:   Gray scale (not a color — a range)
           #111111   Primary text
           #444444   Secondary text
           #6b7280   Muted / metadata text
           #9b9b9b   Disabled / placeholder
           #d0d0d0   Borders (input fields)
           #e0e0e0   Borders (cards, dividers)
           #f4f5f7   Page background
           #ffffff   Card background

SIGNAL:    #e24b4a   Red
           Used ONLY for:
             Negative / overdrawn account balance
             Destructive action (e.g. "Hide from new entries")
             Validation error (e.g. unbalanced entry, invalid amount)
             Mandatory field indicator
```

There is no separate "success" or "warning" color. Money in and money out are
distinguished by **label, icon, and sign** (`+`/`−`), never by color — adding a
green/amber tint would break the 3-color rule.

---

## Typography

```
Font family: platform default sans (no custom font, no runtime font download)
Fallback:    ThemeData.fontFamilyFallback = Noto families for Latin, Indic,
             Arabic, CJK, Thai, Meetei Mayek, Ol Chiki (kFontFamilyFallback in
             lib/ui/core/app_theme.dart). No font files are bundled yet —
             this renders reliably on Android; iOS/desktop rely on their
             own system fonts (see lib/l10n/FONTS.md).
Direction:   Right-to-left locales (Arabic, Urdu, Sindhi, Kashmiri) mirror
             automatically via Flutter's Directionality; never hardcode
             left/right — use start/end.
Implemented: lib/ui/core/app_typography.dart (sizes below)

Scale:
  10px   Section labels (uppercase + letter-spacing: 1px)
  11px   Metadata, timestamps, category tags
  12px   Secondary info, table data
  13px   Body text, card content
  14px   Buttons, form labels
  15px   Card titles, important content
  16px   Screen titles
  17px   Main page heading
  18px   Header titles
  20px   Navigation icons
  24px   Balance / summary numbers
  32px   Logo wordmark

Weight:
  400    Regular — body text, standard rows
  500    Medium — standard labels, nav items
  600    Semibold — card titles, running balance
  700    Bold — screen-level totals (e.g. summary period total)
```

---

## Spacing

```
Micro:   4px   — gap between badge elements
Small:   6px   — gap between buttons in a row
Base:    8px   — standard gap
Medium:  12px  — card internal padding
Large:   16px  — screen edge padding (mobile)
XLarge:  24px  — screen edge padding (desktop)

Border radius:
  Small:  4px   — badges, pills, category tags
  Medium: 8px   — buttons, inputs
  Large:  12px  — cards
  XLarge: 16px  — bottom sheets (top corners only)
```

---

## Component Patterns

### Cards
```css
/* Standard card (e.g. register row, category row) */
background: #ffffff;
border: 0.5px solid #e0e0e0;
border-radius: 12px;
padding: 16px;

/* Selected / active card */
border-left: 3px solid #1a3a6b;

/* Negative balance / error card */
border-left: 3px solid #e24b4a;

/* Never use colored backgrounds on cards */
```

### Buttons
```css
/* Primary — navy */
background: #1a3a6b;
color: #ffffff;
border: none;
padding: 12px 16px;
border-radius: 8px;
min-height: 44px; /* touch target */

/* Secondary — outlined */
background: #ffffff;
color: #444;
border: 0.5px solid #d0d0d0;
padding: 12px 16px;
border-radius: 8px;

/* Destructive — red outlined (e.g. "Hide from new entries") */
border: 1.5px solid #e24b4a;
color: #e24b4a;
background: transparent;

/* Ghost */
background: transparent;
border: none;
color: #6b7280;
```

### Transaction Direction (money in / money out)

Direction is never color-coded. Use icon + sign + label only:

```
Money in:  ↓ arrow icon (or ti-arrow-down), amount prefixed "+"
Money out: ↑ arrow icon (or ti-arrow-up), amount prefixed "−"

Both rendered in NEUTRAL primary text (#111111). Only an archived category
tag or an amount that would take the account negative uses SIGNAL red.

User-facing words are household terms, never ledger terms: "Spent" /
"Received", "Moved money", "Fix", "Hide from new entries", "Money in
transit" (canonical list: docs/household-term-map.md).
```

### Shared components

Reuse before writing a new one (tech guidelines, Golden Rule #10). All live
in `lib/ui/core/`:

```
confirmDestructiveAction   destructive_confirmation.dart — red confirm dialog
MoneyAmountField           money_amount_field.dart — per-currency amount input
EntityPickerField          entity_picker_field.dart — account/category/payee picker
StatusBanner               status_banner.dart — inline info/error banner
showManagedDialog          show_managed_dialog.dart — dialog that owns text
                           controllers and disposes them after exit animation
showCaptureActionSheet     capture_action_sheet.dart — the single Add hub
                           (Spent / Received / Moved money / Import statement)
MonthlyLimitProgress       monthly_limit_progress.dart — informational limit bar
SnapshotHidingOverlay      snapshot_hiding_overlay.dart — app-switcher privacy cover
```

### Money formatting

Amounts are formatted by the **currency's** own convention, never the UI
language (₹10,00,000 lakh grouping, ¥ with no decimals, € with `.`
grouping and `,` decimal). Use `formatAmountMinor` / `parseAmountToMinor`
(`money_formatter.dart`) or `MoneyAmountField`;
never format money with a locale-based `NumberFormat` directly.

### Register Row
```
[icon]  Category name                    +/- CHF amount
        transaction date · description   running balance (muted, #6b7280)

Split entry:       "Groceries +1 more", full transaction amount
Reversal row:      ti-corner-up-left marker
Unverified row:    SIGNAL red left border + ti-lock, still visible,
                   excluded from balances
Migrated row:      ti-history marker (superseded by a key migration;
                   historical, excluded from active balances)
```

### Navigation
```
Five top-level destinations (lib/ui/core/app_shell.dart):
  Home (ti-home) · Register (ti-receipt) · Summary (ti-chart-bar)
  · Accounts (ti-wallet) · Categories (ti-tag)
Settings is reached from Home's gear icon (ti-settings), not a tab.

Chosen by available window width, not device type:
  width <= 600px   Bottom navigation bar
  width  > 600px   NavigationRail sidebar
Both: navy (#1a3a6b) background; selected = white (#ffffff) icon + label,
unselected = light gray (#e0e0e0) icon + label.
```

---

## Responsive Breakpoints

```
Mobile (phone):    320px — 768px   — primary design target
Tablet:            768px — 1024px  — adapted layout
Desktop:           1024px+         — wide register/table layout

Implemented breakpoint: the navigation switch at 600px window width
(AppShell). Other layouts adapt with LayoutBuilder/Expanded rather than
fixed breakpoints.

Mobile-first approach:
  Design for phone touch first
  Enhance for desktop second (wider register table, side-by-side
  register + summary panel becomes viable above 1024px)
```

---

## Iconography

```
Icon library: Tabler Icons (ti-*)
  Free, MIT licensed
  Consistent stroke width
  Touch-friendly at 20-22px

Key icons used:
  ti-arrow-down     Money in
  ti-arrow-up       Money out
  ti-receipt        Transaction / register
  ti-tag            Category
  ti-wallet         Financial account
  ti-chart-bar      Income vs. expense summary
  ti-corner-up-left Reversal (Fix) entry marker
  ti-history        Migration-superseded entry marker
  ti-archive        Hide from new entries
  ti-check          Confirm / save
  ti-x              Close / cancel
  ti-calendar       Transaction date picker
  ti-lock           Unverified (quarantined) entry; lock screen; locked lot
  ti-home           Home tab
  ti-settings       Settings (from Home)
  ti-plus           Add
  ti-pencil         Rename / edit
  ti-trash          Delete (payee, template, rule — never a posted entry)
  ti-search         Register / instrument search
  ti-arrows-exchange Moved money (transfer)
  ti-file-import    Import statement
  ti-file-export    Export CSV
  ti-folder-plus    New account group
  ti-credit-card    Credit card account
  ti-clock-hour-4   Due recurring template
  ti-target         Monthly category limit
  ti-user-circle    Payee
  ti-adjustments    Import mapping / rules
  ti-alert-triangle / ti-alert-circle   Warning / error banners
  ti-dots-vertical  Row overflow menu

Only icons from tabler_icons_plus (TablerIcons.*) are used.
```
