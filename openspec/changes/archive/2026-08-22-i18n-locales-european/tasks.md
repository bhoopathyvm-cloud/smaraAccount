## 1. Translations

- [x] 1.1 Generate AI translations into `app_de.arb`, `app_fr.arb`, `app_es.arb`, `app_it.arb`, `app_pt.arb`, `app_hu.arb`, `app_ro.arb`
- [x] 1.2 Verify key parity with `app_en.arb`

## 2. Registration

- [x] 2.1 Register `de`, `fr`, `es`, `it`, `pt`, `hu`, `ro` in `supportedLocales` and the language picker, including each language's native name (Deutsch, Français, Español, Italiano, Português, Magyar, Română) in the picker's native-name lookup table

## 3. Verification

- [x] 3.1 Smoke-test German and French on Home and a dialog-heavy screen (check overflow)
- [x] 3.2 Spot-check Spanish, Italian, Portuguese, Hungarian, Romanian switching
- [x] 3.3 Confirm English fallback behavior
