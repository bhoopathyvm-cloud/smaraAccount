## 1. Translations

- [ ] 1.1 Generate AI translations into `app_de.arb`, `app_fr.arb`, `app_es.arb`, `app_it.arb`, `app_pt.arb`, `app_hu.arb`, `app_ro.arb` (preserve keys, placeholders, `@` metadata; use the foundation glossary)
- [ ] 1.2 Verify key parity with `app_en.arb`

## 2. Registration

- [ ] 2.1 Register `de`, `fr`, `es`, `it`, `pt`, `hu`, `ro` in `supportedLocales` and the picker's native-name table: Deutsch, Français, Español, Italiano, Português, Magyar, Română (these are already Latin-script endonyms; still add English secondary names German, French, Spanish, Italian, Portuguese, Hungarian, Romanian for search)

## 3. Verification

- [ ] 3.1 Smoke-test German and French on Home and a dialog-heavy screen (check overflow)
- [ ] 3.2 Spot-check Spanish, Italian, Portuguese, Hungarian, Romanian switching
- [ ] 3.3 Confirm English fallback behavior
- [ ] 3.4 Confirm follow-device `pt_BR` and `pt_PT` resolve to the single `pt` locale
- [ ] 3.5 Add these seven languages to the user-guide list of available languages
