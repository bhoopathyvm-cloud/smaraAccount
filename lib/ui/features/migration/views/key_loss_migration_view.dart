import 'package:flutter/material.dart';

import '../../../../domain/models/transaction_direction.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/money_formatter.dart';
import '../view_models/key_loss_migration_view_model.dart';

/// Disaster-recovery screen for true key loss - no recovery phrase or
/// keystore file available (spec: "True Key-Loss Migration"). Requires
/// the user to review the current ledger and explicitly confirm it as
/// valid before anything irreversible happens; the confirmation wording
/// states plainly that this does not retroactively prove pre-migration
/// entries were untampered.
class KeyLossMigrationView extends StatelessWidget {
  const KeyLossMigrationView({
    super.key,
    required this.viewModel,
    required this.onMigrated,
  });

  final KeyLossMigrationViewModel viewModel;
  final VoidCallback onMigrated;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.migrationTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.signal),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMedium,
                    ),
                  ),
                  child: Text(
                    l10n.migrationBlurb,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                Text(
                  l10n.reviewEntriesBeforeContinuing(
                    '${viewModel.entries.length}',
                  ),
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.medium),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: viewModel.entries.isEmpty
                      ? Center(child: Text(l10n.registerNoEntries))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: viewModel.entries.length,
                          itemBuilder: (context, index) {
                            final entry = viewModel.entries[index];
                            final assetPosting = entry.postings.isEmpty
                                ? null
                                : entry.postings.reduce(
                                    (a, b) =>
                                        a.amountMinor.abs() >=
                                            b.amountMinor.abs()
                                        ? a
                                        : b,
                                  );
                            final direction =
                                (assetPosting?.amountMinor ?? 0) >= 0
                                ? TransactionDirection.moneyIn
                                : TransactionDirection.moneyOut;
                            // This review list spans every account (any
                            // currency) with no join back to account data
                            // in scope here - a neutral 2-decimal format
                            // is the same fallback used elsewhere in this
                            // app for a currency-unknown context, and this
                            // recovery-flow review list was never meant to
                            // read like a per-account balance display.
                            final amountText =
                                '${direction == TransactionDirection.moneyIn ? '+' : '-'}'
                                '${formatAmountMinor((assetPosting?.amountMinor ?? 0).abs(), 'USD')}';
                            return ListTile(
                              dense: true,
                              title: Text(
                                '${entry.transactionDate.year}-'
                                '${entry.transactionDate.month.toString().padLeft(2, '0')}-'
                                '${entry.transactionDate.day.toString().padLeft(2, '0')}'
                                '${entry.description != null ? ' - ${entry.description}' : ''}',
                                style: AppTypography.tableData,
                              ),
                              trailing: Text(
                                amountText,
                                style: AppTypography.tableData,
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: AppSpacing.large),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: viewModel.hasConfirmed,
                  onChanged: (value) => viewModel.setConfirmed(value ?? false),
                  title: Text(
                    l10n.iConfirmBooksValid,
                    style: AppTypography.body,
                  ),
                ),
                if (viewModel.errorMessageFor(l10n) != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    viewModel.errorMessageFor(l10n)!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                ElevatedButton(
                  onPressed: (!viewModel.hasConfirmed || viewModel.isMigrating)
                      ? null
                      : () async {
                          final success = await viewModel.confirmAndMigrate();
                          if (success) onMigrated();
                        },
                  child: Text(l10n.migrationTitle),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
