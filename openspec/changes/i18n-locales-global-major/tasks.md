## 1. Translations

- [ ] 1.1 Generate AI translations into `app_ar.arb`, `app_ru.arb`, `app_id.arb`, `app_tr.arb`, `app_vi.arb`, `app_th.arb`, `app_ms.arb`, `app_uk.arb`, `app_pl.arb`, `app_nl.arb` (preserve keys, placeholders, `@` metadata; use the foundation household glossary)
- [ ] 1.2 Verify key parity with `app_en.arb`

## 2. Registration, fonts, RTL

- [ ] 2.1 Register all ten locales in `supportedLocales` and the picker's native-name table: العربية, Русский, Bahasa Indonesia, Türkçe, Tiếng Việt, ไทย, Bahasa Melayu, Українська, Polski, Nederlands with English secondary names Arabic, Russian, Indonesian, Turkish, Vietnamese, Thai, Malay, Ukrainian, Polish, Dutch
- [ ] 2.2 Ensure fonts cover Arabic, Cyrillic, Thai, and Vietnamese via the foundation font registry
- [ ] 2.3 Verify Arabic right-to-left on Home, Add spent, and Settings/language list, including after switching language without restart

## 3. Verification

- [ ] 3.1 Smoke-test Arabic and Russian end-to-end
- [ ] 3.2 Spot-check Indonesian, Turkish, Vietnamese, Thai, Malay, Ukrainian, Polish, Dutch
- [ ] 3.3 Confirm English fallback behavior
- [ ] 3.4 Confirm follow-device `ar_EG` resolves to `ar` and activates RTL
- [ ] 3.5 Add these ten languages to the user-guide list of available languages
- [ ] 3.6 Confirm follow-device legacy Android tag `in` resolves to Indonesian `id`
