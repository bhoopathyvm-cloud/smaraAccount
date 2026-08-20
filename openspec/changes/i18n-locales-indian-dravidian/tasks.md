## 1. Translations

- [x] 1.1 Generate AI translations from `app_en.arb` into `app_ta.arb`, `app_te.arb`, `app_ml.arb`, `app_kn.arb` (preserve keys, placeholders, `@` metadata)
- [x] 1.2 Verify every English key exists in all four ARB files

## 2. Registration and fonts

- [x] 2.1 Add `ta`, `te`, `ml`, `kn` to `supportedLocales` and the language picker, including each language's native-script name (தமிழ், తెలుగు, മലയാളം, ಕನ್ನಡ) in the picker's native-name lookup table
- [x] 2.2 Ensure Tamil/Telugu/Malayalam/Kannada fonts are bundled or selected so sample screens do not show tofu

## 3. Verification

- [x] 3.1 Smoke-test language switch into each locale on Home and one form screen
- [x] 3.2 Confirm a sample error message localizes (not raw English) when locale is Tamil
- [x] 3.3 Confirm missing-key fallback to English still works
