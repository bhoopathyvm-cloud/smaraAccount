import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/home_overview.dart';
import '../../../../domain/models/recurring_template.dart';
import '../../../../domain/models/summary.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/capture_action_sheet.dart';
import '../../../core/money_formatter.dart';
import '../../../core/monthly_limit_progress.dart';
import '../view_models/home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.viewModel,
    required this.onAccountTap,
    this.onSettlePendingTransfer,
    this.onOpenSettings,
    this.onSpent,
    this.onReceived,
    this.onTransfer,
    this.onImport,
  });

  final HomeViewModel viewModel;
  final ValueChanged<String> onAccountTap;
  final ValueChanged<String>? onSettlePendingTransfer;
  final VoidCallback? onOpenSettings;

  /// home-hub-capture: Home's primary Add action opens the same
  /// Spent/Received/Moved money/Import choice as Register's consolidated
  /// Add, with no account pre-selected (the user picks one in the form).
  final VoidCallback? onSpent;
  final VoidCallback? onReceived;
  final VoidCallback? onTransfer;
  final VoidCallback? onImport;

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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home-add-fab',
        onPressed: () => showCaptureActionSheet(
          context: context,
          onSpent: onSpent ?? () {},
          onReceived: onReceived ?? () {},
          onTransfer: onTransfer ?? () {},
          onImport: onImport ?? () {},
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        icon: const Icon(TablerIcons.plus),
        label: const Text('Add'),
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
              if (viewModel.dueTemplates.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xLarge),
                _DueTemplates(
                  dueTemplates: viewModel.dueTemplates,
                  onTap: viewModel.recordDueTemplate,
                ),
              ],
              if (overview.pendingTransfers.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xLarge),
                _PendingTransfers(
                  pendingTransfers: overview.pendingTransfers,
                  onTap: onSettlePendingTransfer,
                ),
              ],
              if (viewModel.thisMonthExpenseTotals.isNotEmpty ||
                  viewModel.thisMonthIncomeTotals.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xLarge),
                _ThisMonth(
                  expenseTotals: viewModel.thisMonthExpenseTotals,
                  incomeTotals: viewModel.thisMonthIncomeTotals,
                  limitFor: viewModel.monthlyLimitFor,
                ),
              ],
              const SizedBox(height: AppSpacing.xLarge),
              for (final section in overview.sections)
                _GroupSection(section: section, onAccountTap: onAccountTap),
              // Room for the FAB not to cover the last row.
              const SizedBox(height: AppSpacing.xLarge),
            ],
          );
        },
      ),
    );
  }
}

class _ThisMonth extends StatelessWidget {
  const _ThisMonth({
    required this.expenseTotals,
    required this.incomeTotals,
    required this.limitFor,
  });

  final List<CategoryTotal> expenseTotals;
  final List<CategoryTotal> incomeTotals;

  /// monthly-category-limits: additive surfacing here when this section
  /// exists (design.md Decision 2) - null for a category with no limit set.
  final int? Function(String categoryId) limitFor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THIS MONTH', style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.base),
          if (expenseTotals.isNotEmpty) ...[
            Text('Spent', style: AppTypography.cardTitle),
            for (final total in expenseTotals)
              _CategoryTotalRow(
                total: total,
                limitMinor: limitFor(total.categoryId),
              ),
            const SizedBox(height: AppSpacing.medium),
          ],
          if (incomeTotals.isNotEmpty) ...[
            Text('Received', style: AppTypography.cardTitle),
            for (final total in incomeTotals) _CategoryTotalRow(total: total),
          ],
        ],
      ),
    );
  }
}

class _CategoryTotalRow extends StatelessWidget {
  const _CategoryTotalRow({required this.total, this.limitMinor});

  final CategoryTotal total;
  final int? limitMinor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(total.categoryName, style: AppTypography.body),
              ),
              // Categories aren't scoped to one currency (they're shared
              // across accounts of potentially different currencies) - same
              // neutral-currency fallback Summary's own totals already use.
              Text(
                formatAmountMinor(total.totalMinor, 'USD'),
                style: AppTypography.body,
              ),
            ],
          ),
          if (limitMinor != null)
            MonthlyLimitProgress(
              spentMinor: total.totalMinor,
              limitMinor: limitMinor!,
            ),
        ],
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
          Text(
            'WHAT YOU HAVE MINUS WHAT YOU OWE',
            style: AppTypography.sectionLabel,
          ),
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
                      '${formatAmountMinor(position.netPositionMinor, position.currency)} '
                      '${position.currency}',
                      style: AppTypography.balance.copyWith(
                        color: position.netPositionMinor < 0
                            ? AppColors.signal
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Assets ${formatAmountMinor(position.totalAssetsMinor, position.currency)} '
                      '${position.currency}  •  Liabilities '
                      '${formatAmountMinor(position.totalLiabilitiesMinor, position.currency)} '
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
            // pending-transfers-plain-language: a human sentence stating
            // what was sent, not FX-settlement vocabulary (spec:
            // "Plain-Language Pending Money").
            title: Text(
              pending.destinationLabel == null
                  ? 'You sent '
                        '${formatAmountMinor(pending.amountMinor, pending.currency)} '
                        '${pending.currency} from ${pending.sourceAccountName}'
                  : 'You sent '
                        '${formatAmountMinor(pending.amountMinor, pending.currency)} '
                        '${pending.currency} to ${pending.destinationLabel}',
              style: AppTypography.cardTitle,
            ),
            subtitle: Text(
              'Tap when you know what arrived',
              style: AppTypography.metadata,
            ),
            onTap: onTap == null
                ? null
                : () => onTap!(pending.pendingTransfer.id),
          ),
      ],
    );
  }
}

/// recurring-templates: "DUE TODAY" - one tap records the transaction,
/// never automatic (spec: "Recurring Transaction Templates").
class _DueTemplates extends StatelessWidget {
  const _DueTemplates({required this.dueTemplates, this.onTap});

  final List<DueRecurringTemplate> dueTemplates;
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
            child: Text('DUE TODAY', style: AppTypography.sectionLabel),
          ),
        ),
        const Divider(height: 1),
        for (final due in dueTemplates)
          ListTile(
            leading: Icon(
              due.template.direction == TransactionDirection.moneyIn
                  ? TablerIcons.arrowDown
                  : TablerIcons.arrowUp,
              color: AppColors.textSecondary,
            ),
            title: Text(due.template.name, style: AppTypography.cardTitle),
            subtitle: Text(
              '${due.categoryName} · ${due.financialAccountName} · tap to record',
              style: AppTypography.metadata,
            ),
            trailing: Text(
              formatAmountMinor(due.template.amountMinor, due.currency),
              style: AppTypography.body,
            ),
            onTap: onTap == null ? null : () => onTap!(due.template.id),
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
    // Only null for a group mid-migration that hasn't had its currency
    // backfilled yet (multi-currency-support) - the router already
    // forces the backfill prompt before this screen is reachable in that
    // state, so USD here is just a harmless formatting default for a
    // window that's never actually visible to a user.
    final formattingCurrency = currency ?? 'USD';
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
                  '${formatAmountMinor(section.totalDisplayBalanceMinor, formattingCurrency)} '
                  '${currency ?? '?'}',
                  style: AppTypography.cardTitle,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final balance in section.accounts)
            ListTile(
              // credit-card-household-flow: a distinct icon is the only
              // Home styling this flag needs - the balance figure itself
              // already renders identically to any other liability's
              // (design.md Context).
              leading: Icon(
                balance.account.isCreditCard
                    ? TablerIcons.creditCard
                    : TablerIcons.wallet,
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
                  ? Text('Hidden', style: AppTypography.metadata)
                  : null,
              trailing: Text(
                '${formatAmountMinor(balance.displayBalanceMinor, formattingCurrency)} '
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
