# AI translation workflow

English `lib/l10n/app_en.arb` is the only human-authored source of truth.

## Prompt structure

1. Attach `app_en.arb` and `TRANSLATION_GLOSSARY.md`.
2. Ask for `app_<locale>.arb` covering every message key.
3. Instruct: preserve keys, `{placeholders}`, and any `@` metadata
   byte-for-byte from the template. Translate values only.
4. Use household terms from the glossary (Spent, Received, Fix).
5. Do not translate BIP39 recovery words or ISO 4217 currency codes.

## Output location

- Template: `lib/l10n/app_en.arb`
- Locale packs: `lib/l10n/app_<tag>.arb`
- Glossary: `lib/l10n/TRANSLATION_GLOSSARY.md` (this folder)

Missing keys fall back to English via Flutter gen-l10n. Human linguistic
QA is not a v1 gate.
