## 1. Translations

- [ ] 1.1 Generate AI translations into `app_bn.arb`, `app_as.arb`, `app_or.arb`, `app_mni.arb`, `app_brx.arb`, `app_sat.arb` (preserve keys, placeholders, `@` metadata; use the foundation household glossary)
- [ ] 1.2 Verify key parity with `app_en.arb`
- [ ] 1.3 Use Meitei Mayek for Manipuri and Ol Chiki for Santali unless a font gap forces a documented fallback

## 2. Registration and fonts

- [ ] 2.1 Register `bn`, `as`, `or`, `mni`, `brx`, `sat` in `supportedLocales` (Odia as `Locale.fromSubtags(languageCode: 'or')`) and the picker's native-name table: বাংলা, অসমীয়া, ଓଡ଼ିଆ, ꯃꯩꯇꯩꯂꯣꯟ (or documented Bengali-script fallback), बरʼ, ᱥᱟᱱᱛᱟᱲᱤ with English secondary names Bengali, Assamese, Odia, Manipuri, Bodo, Santali
- [ ] 2.2 Add fonts for Bengali–Assamese, Odia, and best-effort Meitei Mayek / Ol Chiki to the foundation font registry (or document gaps)

## 3. Verification

- [ ] 3.1 Smoke-test Bengali and Assamese on primary screens
- [ ] 3.2 Spot-check Odia, Manipuri, Bodo, Santali in the picker and one screen each
- [ ] 3.3 When the other three Indian locale packs are also present, confirm the picker lists all 22 scheduled languages (excluding English). If those packs are not on the branch, record the check as blocked rather than failing this pack.
- [ ] 3.4 Add Bengali, Assamese, Odia, Manipuri, Bodo, and Santali to the user-guide list of available languages
