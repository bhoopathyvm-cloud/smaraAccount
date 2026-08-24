import 'package:flutter/material.dart';

/// Formats [date] for display (register row, register date-range chip,
/// summary, transfer, holdings) using the active UI locale's date
/// convention, never a hand-rolled ISO `yyyy-MM-dd` string - switching the
/// app's language changes how dates read here too
/// (i18n-full-ui-and-input-language design.md Decision 4). Amounts stay on
/// currency convention, not UI locale - see money_formatter.dart.
String formatLocalDate(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(context).formatShortDate(date);
