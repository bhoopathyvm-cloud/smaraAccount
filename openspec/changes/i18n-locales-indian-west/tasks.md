## 1. Translations

- [x] 1.1 Generate AI translations into `app_mr.arb`, `app_gu.arb`, `app_kok.arb`, `app_sd.arb`
- [x] 1.2 Verify key parity with `app_en.arb`
- [x] 1.3 Document Sindhi script choice used in the ARB (Arabic vs Devanagari)

## 2. Registration and fonts

- [x] 2.1 Register `mr`, `gu`, `kok`, `sd` in `supportedLocales` and the language picker, including each language's native-script name (मराठी, ગુજરાતી, कोंकणी, and Sindhi in whichever script task 1.3 settles on) in the picker's native-name lookup table — verify each spelling against a reliable source rather than assuming a remembered one
- [x] 2.2 Ensure fonts cover Marathi/Konkani Devanagari, Gujarati, and the chosen Sindhi script

## 3. Verification

- [x] 3.1 Smoke-test Marathi and Gujarati on Home and one form
- [x] 3.2 Spot-check Konkani and Sindhi rendering
- [x] 3.3 Confirm English fallback behavior
