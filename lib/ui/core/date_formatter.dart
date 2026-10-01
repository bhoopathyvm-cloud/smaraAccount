import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/material_locale_fallback.dart';

/// Formats [date] for display (register row, register date-range chip,
/// summary, transfer, holdings) using the active UI locale's date
/// convention, never a hand-rolled ISO `yyyy-MM-dd` string - switching the
/// app's language changes how dates read here too
/// (i18n-full-ui-and-input-language design.md Decision 4). Amounts stay on
/// currency convention, not UI locale - see money_formatter.dart.
String formatLocalDate(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(context).formatShortDate(date);

/// A medium date format ("1 Oct 2026") for the active UI locale. The date
/// library has no data for some supported languages (Konkani, Bodo, Dogri,
/// Maithili, Sanskrit, Kashmiri, Sindhi, Meitei, Santali), and constructing
/// a format for them throws. Those fall back to the same sibling language
/// the Material chrome uses (`kMaterialLocaleFallback`), then to English.
DateFormat mediumDateFormatFor(BuildContext context) {
  final locale = Localizations.localeOf(context);
  for (final tag in [
    locale.toString(),
    locale.languageCode,
    ?kMaterialLocaleFallback[locale.languageCode],
    'en',
  ]) {
    if (DateFormat.localeExists(tag)) return DateFormat.yMMMd(tag);
  }
  return DateFormat.yMMMd('en');
}
