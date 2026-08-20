## 1. Translations

- [x] 1.1 Generate AI translations into `app_ar.arb`, `app_ru.arb`, `app_id.arb`, `app_tr.arb`, `app_vi.arb`, `app_th.arb`, `app_ms.arb`, `app_uk.arb`, `app_pl.arb`, `app_nl.arb`
- [x] 1.2 Verify key parity with `app_en.arb`

## 2. Registration, fonts, RTL

- [x] 2.1 Register all ten locales in `supportedLocales` and the language picker, including each language's native name (العربية, Русский, Bahasa Indonesia, Türkçe, Tiếng Việt, ไทย, Bahasa Melayu, Українська, Polski, Nederlands) in the picker's native-name lookup table
- [x] 2.2 Ensure fonts cover Arabic, Cyrillic, Thai, and Vietnamese
- [x] 2.3 Verify Arabic RTL on Home, Record Transaction, and Settings/language picker

## 3. Verification

- [x] 3.1 Smoke-test Arabic and Russian end-to-end
- [x] 3.2 Spot-check Indonesian, Turkish, Vietnamese, Thai, Malay, Ukrainian, Polish, Dutch
- [x] 3.3 Confirm English fallback behavior
