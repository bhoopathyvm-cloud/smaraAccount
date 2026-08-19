## 1. Translations

- [ ] 1.1 Generate AI translations into `app_ja.arb`, `app_zh.arb`, `app_ko.arb` (preserve keys, placeholders, `@` metadata; use the foundation household glossary). Chinese copy is Simplified.
- [ ] 1.2 Verify key parity with `app_en.arb`

## 2. Registration and fonts

- [ ] 2.1 Register `ja`, `zh`, `ko` in `supportedLocales` and the picker's native-name table: 日本語, 简体中文, 한국어 with English secondary names Japanese, Simplified Chinese, Korean
- [ ] 2.2 Bundle or configure CJK fonts via the foundation font registry; check binary size impact

## 3. Verification

- [ ] 3.1 Smoke-test Japanese, Simplified Chinese, and Korean on Home and Add spent
- [ ] 3.2 Confirm glyphs are not tofu on a physical device or emulator with the bundled or platform CJK fonts
- [ ] 3.3 Confirm English fallback behavior
- [ ] 3.4 Confirm follow-device `zh_CN` → Simplified `zh`, and `zh_TW` / `zh_Hant` → English while Traditional is unsupported
- [ ] 3.5 Add Japanese, Simplified Chinese, and Korean to the user-guide list of available languages
