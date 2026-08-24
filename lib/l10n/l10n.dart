import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';
import 'localize_error.dart';
import 'supported_locales.dart';

export 'generated/app_localizations.dart';
export 'locale_controller.dart';
export 'locale_endonyms.dart';
export 'material_locale_fallback.dart';
export 'localize_error.dart';
export 'localize_skip_reason.dart';
export 'localized_error_mixin.dart';
export 'supported_locales.dart';
export 'system_name_localizer.dart';

/// Resolves [AppLocalizations] from [context], falling back to English when
/// the widget is not under a `MaterialApp` with gen-l10n delegates (widget
/// tests that have not yet been migrated).
AppLocalizations l10nOf(BuildContext context) {
  return AppLocalizations.of(context) ??
      lookupAppLocalizations(const Locale('en'));
}

/// Locales this build of the app can switch into. Foundation starts with
/// English; locale-pack changes append their tags to [kSupportedLocaleTags].
List<Locale> get supportedAppLocales => [
  for (final tag in kSupportedLocaleTags) localeFromTag(tag),
];

AppLocalizations get englishAppLocalizations =>
    lookupAppLocalizations(const Locale('en'));

/// Maps a repository or validation failure to English ARB copy.
/// ViewModels keep this for unit tests; views that need the active locale
/// should call [localizeCaughtError] with [l10nOf].
String localizeVmError(Object error) =>
    localizeCaughtError(englishAppLocalizations, error);
