## 1. Translations

- [ ] 1.1 Generate AI translations from `app_en.arb` into `app_ta.arb`, `app_te.arb`, `app_ml.arb`, `app_kn.arb` (preserve keys, placeholders, `@` metadata; use the foundation household glossary)
- [ ] 1.2 Verify every English key exists in all four ARB files (CI untranslated-messages-file should be clean)

## 2. Registration and fonts

- [ ] 2.1 Add `ta`, `te`, `ml`, `kn` to `supportedLocales` and the language picker's native-name table: தமிழ் / తెలుగు / മലയാളം / ಕನ್ನಡ with English secondary labels Tamil / Telugu / Malayalam / Kannada
- [ ] 2.2 Register Tamil/Telugu/Malayalam/Kannada fonts in the foundation font registry so sample screens do not show tofu

## 3. Verification

- [ ] 3.1 Smoke-test language switch into each locale on Home and Add spent (check overflow on primary actions)
- [ ] 3.2 Confirm a sample error message localizes (not raw English) when locale is Tamil
- [ ] 3.3 Confirm missing-key fallback to English still works
- [ ] 3.4 Confirm a device-style locale `ta_IN` resolves to Tamil when follow-device is selected
- [ ] 3.5 Add Tamil, Telugu, Malayalam, and Kannada to the user-guide list of available languages
