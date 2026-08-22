import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Known limitation (i18n-foundation, found during a later review): these
/// families are declared for `ThemeData.fontFamilyFallback` but no font
/// assets are bundled with the app (no `flutter: fonts:` entry in
/// pubspec.yaml). This only renders correctly where the OS already has a
/// system font installed under this exact family name - reliably true on
/// Android (which ships Noto-named system fonts for most of these
/// scripts), NOT guaranteed on iOS/desktop, which use different family
/// names for their own built-in Indic/CJK/Arabic rendering. Non-Latin
/// scripts may render as tofu or substitute an unintended font on those
/// platforms until real font assets are bundled - unresolved follow-up
/// work, not fixed by this declaration alone.
const kFontFamilyFallback = [
  'Noto Sans',
  'Noto Sans Devanagari',
  'Noto Sans Tamil',
  'Noto Sans Telugu',
  'Noto Sans Kannada',
  'Noto Sans Malayalam',
  'Noto Sans Gujarati',
  'Noto Sans Gurmukhi',
  'Noto Sans Bengali',
  'Noto Sans Oriya',
  'Noto Naskh Arabic',
  'Noto Sans CJK SC',
  'Noto Sans CJK JP',
  'Noto Sans CJK KR',
  'Noto Sans Thai',
  'Noto Sans Meetei Mayek',
  'Noto Sans Ol Chiki',
];

/// Assembles a [ThemeData] from the 3-color rule and component patterns in
/// smara-design-system.md. No color outside [AppColors] is introduced here.
ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: AppColors.cardBackground,
    error: AppColors.signal,
    onError: AppColors.cardBackground,
    surface: AppColors.cardBackground,
    onSurface: AppColors.textPrimary,
  );

  return ThemeData(
    fontFamilyFallback: kFontFamilyFallback,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.pageBackground,
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        side: const BorderSide(color: AppColors.borderCard, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.borderInput, width: 0.5),
        minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: const BorderSide(color: AppColors.borderInput),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.cardBackground,
      unselectedItemColor: AppColors.borderCard,
    ),
  );
}
