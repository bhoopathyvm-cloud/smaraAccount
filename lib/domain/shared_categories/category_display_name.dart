/// Resolves the name shown for a category given optional translations
/// (shared-categories: prefer app-locale translation, else default name).
String resolveCategoryDisplayName({
  required String defaultName,
  required String appLocale,
  Map<String, String> translationsByLocale = const {},
}) {
  final normalizedApp = normalizeLocaleTag(appLocale);
  final exact = translationsByLocale[normalizedApp];
  if (exact != null && exact.trim().isNotEmpty) return exact;

  // Fall back to language-only match (e.g. `de` for `de-CH`).
  final language = languageFromLocale(normalizedApp);
  if (language != normalizedApp) {
    final languageMatch = translationsByLocale[language];
    if (languageMatch != null && languageMatch.trim().isNotEmpty) {
      return languageMatch;
    }
  }
  return defaultName;
}

/// Lowercases and trims a BCP-47 tag; keeps script/region when present.
String normalizeLocaleTag(String locale) {
  final trimmed = locale.trim().replaceAll('_', '-');
  if (trimmed.isEmpty) return 'en';
  final parts = trimmed.split('-');
  if (parts.isEmpty) return 'en';
  final language = parts.first.toLowerCase();
  if (parts.length == 1) return language;
  final rest = parts
      .skip(1)
      .map((p) => p.length <= 3 ? p.toLowerCase() : p.toUpperCase())
      .join('-');
  return '$language-$rest';
}

String languageFromLocale(String locale) {
  final normalized = normalizeLocaleTag(locale);
  final dash = normalized.indexOf('-');
  return dash < 0 ? normalized : normalized.substring(0, dash);
}
