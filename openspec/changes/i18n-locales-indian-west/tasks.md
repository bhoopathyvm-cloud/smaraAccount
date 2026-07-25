## 1. Translations

- [ ] 1.1 Generate AI translations into `app_mr.arb`, `app_gu.arb`, `app_kok.arb`, `app_sd.arb`
- [ ] 1.2 Verify key parity with `app_en.arb`
- [ ] 1.3 Document Sindhi script choice used in the ARB (Arabic vs Devanagari)

## 2. Registration and fonts

- [ ] 2.1 Register `mr`, `gu`, `kok`, `sd` in `supportedLocales` and the language picker, including each language's native-script name (मराठी, ગુજરાતી, कोंकणी, and Sindhi in whichever script task 1.3 settles on) in the picker's native-name lookup table — verify each spelling against a reliable source rather than assuming a remembered one
- [ ] 2.2 Ensure fonts cover Marathi/Konkani Devanagari, Gujarati, and the chosen Sindhi script

## 3. Verification

- [ ] 3.1 Smoke-test Marathi and Gujarati on Home and one form
- [ ] 3.2 Spot-check Konkani and Sindhi rendering
- [ ] 3.3 Confirm English fallback behavior
