import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/home_overview.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/money_formatter.dart';
import '../view_models/home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.viewModel,
    required this.onAccountTap,
  });

  final HomeViewModel viewModel;
  final ValueChanged<String> onAccountTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final overview = viewModel.overview;
          if (overview == null) {
            return const SizedBox.shrink();
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
            children: [
              _NetPosition(overview: overview),
              const SizedBox(height: AppSpacing.xLarge),
              for (final section in overview.sections)
                _GroupSection(section: section, onAccountTap: onAccountTap),
            ],
          );
        },
      ),
    );
  }
}

class _NetPosition extends StatelessWidget {
  const _NetPosition({required this.overview});

  final HomeOverview overview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NET POSITION', style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.base),
          Text(
            formatAmountMinor(overview.netPositionMinor),
            style: AppTypography.balance.copyWith(
              color: overview.netPositionMinor < 0
                  ? AppColors.signal
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Assets ${formatAmountMinor(overview.totalAssetsMinor)}  •  '
            'Liabilities ${formatAmountMinor(overview.totalLiabilitiesMinor)}',
            style: AppTypography.metadata,
          ),
        ],
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.section, required this.onAccountTap});

  final AccountGroupSection section;
  final ValueChanged<String> onAccountTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xLarge),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.large,
              vertical: AppSpacing.base,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    section.group.name.toUpperCase(),
                    style: AppTypography.sectionLabel,
                  ),
                ),
                Text(
                  formatAmountMinor(section.totalDisplayBalanceMinor),
                  style: AppTypography.cardTitle,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final balance in section.accounts)
            ListTile(
              leading: const Icon(
                TablerIcons.wallet,
                color: AppColors.textSecondary,
              ),
              title: Text(
                balance.account.name,
                style: AppTypography.cardTitle.copyWith(
                  color: balance.account.archived
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
              subtitle: balance.account.archived
                  ? Text('Archived', style: AppTypography.metadata)
                  : null,
              trailing: Text(
                formatAmountMinor(balance.displayBalanceMinor),
                style: AppTypography.body,
              ),
              onTap: () => onAccountTap(balance.account.id),
            ),
        ],
      ),
    );
  }
}
