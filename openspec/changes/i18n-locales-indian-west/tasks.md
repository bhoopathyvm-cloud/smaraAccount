## 1. Translations

- [ ] 1.1 Generate AI translations into `app_mr.arb`, `app_gu.arb`, `app_kok.arb`, `app_sd.arb` (preserve keys, placeholders, `@` metadata; use the foundation household glossary)
- [ ] 1.2 Verify key parity with `app_en.arb`
- [ ] 1.3 Generate Sindhi ARB in Arabic script (سنڌي), not Devanagari

## 2. Registration and fonts

- [ ] 2.1 Register `mr`, `gu`, `kok`, `sd` in `supportedLocales` and the picker's native-name table: मराठी, ગુજરાતી, कोंकणी, سنڌي with English secondary names Marathi, Gujarati, Konkani, Sindhi
- [ ] 2.2 Ensure fonts cover Marathi/Konkani Devanagari, Gujarati, and Arabic-script Sindhi in the foundation font registry
- [ ] 2.3 Verify Sindhi activates RTL on a primary screen

## 3. Verification

- [ ] 3.1 Smoke-test Marathi and Gujarati on Home and Add spent
- [ ] 3.2 Spot-check Konkani and Sindhi rendering (Sindhi picker label سنڌي must be visible and RTL)
- [ ] 3.3 Confirm English fallback behavior
- [ ] 3.4 Add Marathi, Gujarati, Konkani, and Sindhi to the user-guide list of available languages
