import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/app_localizations.dart';

/// App locales Flutter does not ship a Material/Cupertino/Widgets pack
/// for, mapped to the closest script sibling Flutter does ship - so
/// overlay chrome (date-picker OK/Cancel, the text-selection toolbar)
/// isn't silently stuck on English while our own ARB labels are already
/// translated (i18n-full-ui-and-input-language design.md Decision 5).
/// `mni`/`sat` have no honest sibling in Flutter's shipped set and stay on
/// English - document that their date-picker chrome may read English
/// until Flutter ships a pack for them.
const kMaterialLocaleFallback = <String, String>{
  'sa': 'hi',
  'doi': 'hi',
  'mai': 'hi',
  'kok': 'hi',
  'brx': 'hi',
  'ks': 'ur',
  'sd': 'ur',
  'mni': 'en',
  'sat': 'en',
};

/// Wraps a Global*Localizations delegate so a locale it does not ship
/// resolves to [kMaterialLocaleFallback]'s sibling instead of silently
/// falling through to whatever default Flutter itself picks (historically
/// English). Tamil and every locale Flutter does ship pass straight
/// through unchanged.
class _FallbackLocalizationsDelegate<T> extends LocalizationsDelegate<T> {
  const _FallbackLocalizationsDelegate(this._inner);

  final LocalizationsDelegate<T> _inner;

  Locale _resolve(Locale locale) {
    if (_inner.isSupported(locale)) return locale;
    final fallbackTag = kMaterialLocaleFallback[locale.languageCode];
    if (fallbackTag == null) return locale;
    final fallback = Locale(fallbackTag);
    return _inner.isSupported(fallback) ? fallback : locale;
  }

  @override
  bool isSupported(Locale locale) =>
      kMaterialLocaleFallback.containsKey(locale.languageCode) ||
      _inner.isSupported(locale);

  @override
  Future<T> load(Locale locale) => _inner.load(_resolve(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<T> old) => false;
}

/// The same delegate list as [AppLocalizations.localizationsDelegates],
/// except the Material/Cupertino/Widgets entries fall back to a script
/// sibling for app locales Flutter itself does not ship a pack for. Use
/// this in `MaterialApp.router(localizationsDelegates: ...)` instead of
/// the generated list directly.
final List<LocalizationsDelegate<dynamic>>
appLocalizationsDelegatesWithMaterialFallback = [
  AppLocalizations.delegate,
  _FallbackLocalizationsDelegate<MaterialLocalizations>(
    GlobalMaterialLocalizations.delegate,
  ),
  _FallbackLocalizationsDelegate<CupertinoLocalizations>(
    GlobalCupertinoLocalizations.delegate,
  ),
  _FallbackLocalizationsDelegate<WidgetsLocalizations>(
    GlobalWidgetsLocalizations.delegate,
  ),
];
