## 1. Translations

- [x] 1.1 Generate AI translations into `app_ja.arb`, `app_zh.arb`, `app_ko.arb`
- [x] 1.2 Verify key parity with `app_en.arb`

## 2. Registration and fonts

- [x] 2.1 Register `ja`, `zh`, `ko` in `supportedLocales` and the language picker, including each language's native name (日本語, 简体中文, 한국어) in the picker's native-name lookup table
- [x] 2.2 Bundle or configure CJK fonts; check binary size impact

## 3. Verification

- [x] 3.1 Smoke-test Japanese, Simplified Chinese, and Korean on Home and one form
- [x] 3.2 Confirm glyphs are not tofu on a physical device or emulator with the bundled fonts
- [x] 3.3 Confirm English fallback behavior
