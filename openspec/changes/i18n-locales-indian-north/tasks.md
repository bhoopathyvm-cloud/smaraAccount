## 1. Translations

- [ ] 1.1 Generate AI translations into `app_hi.arb`, `app_ur.arb`, `app_pa.arb`, `app_ne.arb`, `app_sa.arb`, `app_doi.arb`, `app_ks.arb`, `app_mai.arb` (preserve keys, placeholders, `@` metadata; use the foundation glossary)
- [ ] 1.2 Verify key parity with `app_en.arb` for all eight files

## 2. Registration, fonts, RTL

- [ ] 2.1 Register all eight locales in `supportedLocales` and the picker's native-name table with these primary endonyms (verified): हिन्दी, اردو, ਪੰਜਾਬੀ, नेपाली, संस्कृतम्, डोगरी, کٲشُر, मैथिली — plus English secondary names Hindi, Urdu, Punjabi, Nepali, Sanskrit, Dogri, Kashmiri, Maithili
- [ ] 2.2 Bundle/select fonts for Devanagari, Gurmukhi, and Perso-Arabic (Urdu + Kashmiri) in the foundation font registry
- [ ] 2.3 Verify Urdu **and** Kashmiri activate RTL layout on a primary screen, including after switching language without restart

## 3. Verification

- [ ] 3.1 Smoke-test Hindi and Urdu end-to-end (picker → Home → one error path)
- [ ] 3.2 Spot-check Punjabi, Nepali, and Kashmiri render without tofu (Kashmiri picker label کٲشُر must be visible)
- [ ] 3.3 Confirm English fallback for a deliberately omitted key in one locale file during testing
- [ ] 3.4 Confirm `hi_IN` follow-device resolves to Hindi
- [ ] 3.5 Add these eight languages to the user-guide list of available languages
