import 'package:flutter/widgets.dart';

/// The 3-color rule (smara-design-system.md). Exactly these 3 colors are
/// used anywhere in the app - no ad hoc colors. Money in/out is
/// distinguished by label, icon, and sign, never by color.
abstract final class AppColors {
  /// Headers, buttons, active states, overlays, bottom nav active, the
  /// financial account's own accent.
  static const primary = Color(0xFF1A3A6B);

  /// Negative/overdrawn balance, destructive actions, validation errors,
  /// mandatory field indicators. Never used for "money in" vs "money out".
  static const signal = Color(0xFFE24B4A);

  // Neutral scale - not a color, a range.
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF444444);
  static const textMuted = Color(0xFF6B7280);
  static const textDisabled = Color(0xFF9B9B9B);
  static const borderInput = Color(0xFFD0D0D0);
  static const borderCard = Color(0xFFE0E0E0);
  static const pageBackground = Color(0xFFF4F5F7);
  static const cardBackground = Color(0xFFFFFFFF);
}
