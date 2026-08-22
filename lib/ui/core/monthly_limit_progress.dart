import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/l10n.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'money_formatter.dart';

/// monthly-category-limits: categories aren't currency-scoped
/// (multi-currency-support), so a limit is entered/shown per this
/// fallback - the same 'USD'-formatting convention home-hub-capture's
/// category totals already use for the same reason.
const monthlyLimitDisplayCurrency = 'USD';

/// Month-to-date spent against a category's monthly limit, with a calm
/// (never the design system's red "signal" color) over-limit indication
/// (spec: "Over limit is informational only"). Shared by the category
/// management screen (the always-available home for this) and Home's
/// "this month" section, when that section exists (design.md Decision 2 -
/// additive, not a hard dependency).
class MonthlyLimitProgress extends StatelessWidget {
  const MonthlyLimitProgress({
    super.key,
    required this.spentMinor,
    required this.limitMinor,
  });

  final int spentMinor;
  final int limitMinor;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final isOverLimit = spentMinor > limitMinor;
    final fraction = limitMinor <= 0
        ? 1.0
        : (spentMinor / limitMinor).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: AppColors.borderCard,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            children: [
              Text(
                l10n.homeSpentOfLimitThisMonth(
                  formatAmountMinor(spentMinor, monthlyLimitDisplayCurrency),
                  formatAmountMinor(limitMinor, monthlyLimitDisplayCurrency),
                ),
                style: AppTypography.metadata,
              ),
              if (isOverLimit) ...[
                const SizedBox(width: AppSpacing.small),
                Icon(
                  TablerIcons.alertTriangle,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.homeOverLimit,
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
