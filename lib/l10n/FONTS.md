# Font strategy

Smara does not download fonts at runtime (no Google Fonts CDN). Theme
`fontFamilyFallback` lists Noto families so Android (which already ships
Noto) and desktop installs that include Noto can render Latin, Indic,
CJK, Arabic, and Thai without tofu.

Asset paths for optional bundled fonts (add files here if a device shows
missing glyphs):

- `fonts/NotoSans-Regular.ttf`
- `fonts/NotoSansDevanagari-Regular.ttf`
- `fonts/NotoSansTamil-Regular.ttf`
- `fonts/NotoSansTelugu-Regular.ttf`
- `fonts/NotoSansKannada-Regular.ttf`
- `fonts/NotoSansMalayalam-Regular.ttf`
- `fonts/NotoSansGujarati-Regular.ttf`
- `fonts/NotoSansGurmukhi-Regular.ttf`
- `fonts/NotoSansBengali-Regular.ttf`
- `fonts/NotoSansOriya-Regular.ttf`
- `fonts/NotoNaskhArabic-Regular.ttf`
- `fonts/NotoSansSC-Regular.otf`
- `fonts/NotoSansJP-Regular.otf`
- `fonts/NotoSansKR-Regular.otf`
- `fonts/NotoSansThai-Regular.ttf`
- `fonts/NotoSansMeeteiMayek-Regular.ttf`
- `fonts/NotoSansOlChiki-Regular.ttf`

v1 relies on platform fallback. Locale-pack changes should add a bundled
file under `fonts/` and register it in `pubspec.yaml` only when a target
device cannot render that script.
