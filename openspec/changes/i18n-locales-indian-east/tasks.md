## 1. Translations

- [ ] 1.1 Generate AI translations into `app_bn.arb`, `app_as.arb`, `app_or.arb`, `app_mni.arb`, `app_brx.arb`, `app_sat.arb`
- [ ] 1.2 Verify key parity with `app_en.arb`
- [ ] 1.3 Document Manipuri and Santali script choices if fonts force a fallback

## 2. Registration and fonts

- [ ] 2.1 Register `bn`, `as`, `or`, `mni`, `brx`, `sat` in `supportedLocales` and the language picker, including each language's native-script name (বাংলা for Bengali, অসমীয়া for Assamese, ଓଡ଼ିଆ for Odia, plus Manipuri and Santali in whichever script task 1.3 settles on, and Bodo in Devanagari) in the picker's native-name lookup table — verify each spelling against a reliable source rather than assuming a remembered one, especially for the rarer scripts (Meitei Mayek, Ol Chiki)
- [ ] 2.2 Add fonts for Bengali–Assamese, Odia, and best-effort Meitei Mayek / Ol Chiki (or document gaps)

## 3. Verification

- [ ] 3.1 Smoke-test Bengali and Assamese on primary screens
- [ ] 3.2 Spot-check Odia, Manipuri, Bodo, Santali in the picker and one screen each
- [ ] 3.3 Confirm this pack plus other Indian packs yields all 22 scheduled languages in the picker (excluding English)
