# SmaraAccounting — Design System

> Adapted from an earlier project's design system (same 3-color discipline and
> component structure). All care-home/domain-specific content has been
> replaced with accounting semantics. The rule itself — and its exact palette
> — carries over unchanged; only what the colors and components *mean* has
> changed.

## The 3-Color Rule

SmaraAccounting uses exactly 3 colors. No exceptions.

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
             Destructive action (archive category, reverse entry)
             Validation error (e.g. unbalanced entry, invalid amount)
             Mandatory field indicator
```

There is no separate "success" or "warning" color. Money in and money out are
distinguished by **label, icon, and sign** (`+`/`−`), never by color — adding a
green/amber tint would break the 3-color rule.

---

## Typography

```
Font family: system-ui, -apple-system, sans-serif (platform default — no custom font)

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

/* Destructive — red outlined (e.g. "Archive category", "Reverse entry") */
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
```

### Register Row
```
[icon]  Category name                    +/- CHF amount
        transaction date · description   running balance (muted, #6b7280)
```

### Navigation
```
Bottom tab bar — mobile (Android/iOS):
  Active: navy background, white icon + label
  Inactive: transparent, gray icon + label

Desktop/macOS/Windows: sidebar or top bar, same active/inactive treatment.
```

---

## Responsive Breakpoints

```
Mobile (phone):    320px — 768px   — primary design target
Tablet:            768px — 1024px  — adapted layout
Desktop:           1024px+         — wide register/table layout

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
  ti-corner-up-left Reverse entry
  ti-archive        Archive category
  ti-check          Confirm / save
  ti-x              Close / cancel
  ti-calendar       Transaction date picker
  ti-lock           Immutable / posted (non-editable) indicator
```
