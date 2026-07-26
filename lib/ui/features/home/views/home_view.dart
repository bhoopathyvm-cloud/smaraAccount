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
    this.onSettlePendingTransfer,
    this.onOpenSettings,
  });

  final HomeViewModel viewModel;
  final ValueChanged<String> onAccountTap;
  final ValueChanged<String>? onSettlePendingTransfer;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: onOpenSettings,
            icon: const Icon(TablerIcons.settings),
          ),
        ],
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
              _NetPositions(overview: overview),
              if (overview.pendingTransfers.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xLarge),
                _PendingTransfers(
                  pendingTransfers: overview.pendingTransfers,
                  onTap: onSettlePendingTransfer,
                ),
              ],
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

class _NetPositions extends StatelessWidget {
  const _NetPositions({required this.overview});

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
          if (overview.netPositionsByCurrency.isEmpty)
            Text('0.00', style: AppTypography.balance)
          else
            for (final position in overview.netPositionsByCurrency)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${formatAmountMinor(position.netPositionMinor)} '
                      '${position.currency}',
                      style: AppTypography.balance.copyWith(
                        color: position.netPositionMinor < 0
                            ? AppColors.signal
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Assets ${formatAmountMinor(position.totalAssetsMinor)} '
                      '${position.currency}  •  Liabilities '
                      '${formatAmountMinor(position.totalLiabilitiesMinor)} '
                      '${position.currency}',
                      style: AppTypography.metadata,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _PendingTransfers extends StatelessWidget {
  const _PendingTransfers({required this.pendingTransfers, this.onTap});

  final List<PendingTransferSummary> pendingTransfers;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.large,
            vertical: AppSpacing.base,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('PENDING TRANSFERS', style: AppTypography.sectionLabel),
          ),
        ),
        const Divider(height: 1),
        for (final pending in pendingTransfers)
          ListTile(
            leading: const Icon(
              TablerIcons.clockHour4,
              color: AppColors.textSecondary,
            ),
            title: Text(
              pending.destinationLabel == null
                  ? pending.sourceAccountName
                  : '${pending.sourceAccountName} → ${pending.destinationLabel}',
              style: AppTypography.cardTitle,
            ),
            subtitle: Text(
              'Awaiting settlement',
              style: AppTypography.metadata,
            ),
            trailing: Text(
              '${formatAmountMinor(pending.amountMinor)} ${pending.currency}',
              style: AppTypography.body,
            ),
            onTap: onTap == null
                ? null
                : () => onTap!(pending.pendingTransfer.id),
          ),
      ],
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.section, required this.onAccountTap});

  final AccountGroupSection section;
  final ValueChanged<String> onAccountTap;

  @override
  Widget build(BuildContext context) {
    final currency = section.group.currency;
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
                  '${formatAmountMinor(section.totalDisplayBalanceMinor)} '
                  '${currency ?? '?'}',
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
                '${formatAmountMinor(balance.displayBalanceMinor)} '
                '${currency ?? '?'}',
                style: AppTypography.body,
              ),
              onTap: () => onAccountTap(balance.account.id),
            ),
        ],
      ),
    );
  }
}
