import 'package:flutter/material.dart';

import '../../../../domain/models/transaction_direction.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Migrate to a new key', style: AppTypography.headerTitle),
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
                    'Without your recovery phrase or keystore file, this device\'s '
                    'existing signing key cannot be recovered. Continuing generates '
                    'a brand new key and re-signs every entry below under it, so the '
                    'ledger can be trusted going forward.\n\n'
                    'This does NOT retroactively prove the entries below were never '
                    'tampered with - it only re-establishes trust from this point '
                    'on. The original entries are kept, unchanged, as a read-only '
                    'historical record.',
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                Text(
                  'Review the entries below (${viewModel.entries.length} total) before continuing.',
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.medium),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: viewModel.entries.isEmpty
                      ? const Center(child: Text('No entries recorded yet.'))
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
                            final amountText =
                                '${direction == TransactionDirection.moneyIn ? '+' : '-'}'
                                '${formatAmountMinor((assetPosting?.amountMinor ?? 0).abs())}';
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
                    'I confirm the current ledger is valid',
                    style: AppTypography.body,
                  ),
                ),
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    viewModel.errorMessage!,
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
                  child: const Text('Migrate to a new key'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
