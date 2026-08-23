## 1. Translations

- [x] 1.1 Generate AI translations into `app_hi.arb`, `app_ur.arb`, `app_pa.arb`, `app_ne.arb`, `app_sa.arb`, `app_doi.arb`, `app_ks.arb`, `app_mai.arb`
- [x] 1.2 Verify key parity with `app_en.arb` for all eight files

## 2. Registration, fonts, RTL

- [x] 2.1 Register all eight locales in `supportedLocales` and the language picker, including each language's native-script name (हिन्दी, اردو, ਪੰਜਾਬੀ, नेपाली, संस्कृत, डोगरी, मैथिली, and Kashmiri's own name in its chosen script per task 2.2's decision) in the picker's native-name lookup table — verify each spelling against a reliable source rather than assuming a remembered one, especially for Kashmiri
- [x] 2.2 Bundle/select fonts for Devanagari, Gurmukhi, and Perso-Arabic scripts used by this pack
- [x] 2.3 Verify Urdu activates RTL layout on a primary screen

## 3. Verification

- [x] 3.1 Smoke-test Hindi and Urdu end-to-end (picker → Home → one error path)
- [x] 3.2 Spot-check Punjabi and Nepali render without tofu
- [x] 3.3 Confirm English fallback for a deliberately omitted key in one locale file during testing
