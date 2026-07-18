import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Typography scale per smara-design-system.md. Platform-default sans
/// (no custom font).
abstract final class AppTypography {
  static const _base = TextStyle(color: AppColors.textPrimary);

  static final sectionLabel = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
    color: AppColors.textMuted,
  );
  static final metadata = _base.copyWith(
    fontSize: 11,
    color: AppColors.textMuted,
  );
  static final tableData = _base.copyWith(fontSize: 12);
  static final body = _base.copyWith(fontSize: 13, fontWeight: FontWeight.w400);
  static final buttonLabel = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static final cardTitle = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  static final screenTitle = _base.copyWith(fontSize: 16);
  static final pageHeading = _base.copyWith(fontSize: 17);
  static final headerTitle = _base.copyWith(fontSize: 18);
  static final balance = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );
}
