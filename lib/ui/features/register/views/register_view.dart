import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/entity_picker_field.dart';
import '../view_models/register_view_model.dart';
import 'register_row_tile.dart';

/// Views are lean. No business logic, no Repository calls. Listen to the
/// ViewModel; render what it exposes (smara-tech-guidelines.md).
class RegisterView extends StatelessWidget {
  const RegisterView({
    super.key,
    required this.viewModel,
    this.onAddTransaction,
    this.onTransfer,
    this.onImport,
  });

  final RegisterViewModel viewModel;
  final VoidCallback? onAddTransaction;
  final VoidCallback? onTransfer;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      floatingActionButton: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'register-import-fab',
              onPressed: viewModel.isSelectedAccountArchived ? null : onImport,
              backgroundColor: AppColors.primary,
              child: const Icon(
                TablerIcons.fileImport,
                color: AppColors.cardBackground,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            FloatingActionButton(
              heroTag: 'register-transfer-fab',
              onPressed: viewModel.isSelectedAccountArchived
                  ? null
                  : onTransfer,
              backgroundColor: AppColors.primary,
              child: const Icon(
                TablerIcons.arrowsExchange,
                color: AppColors.cardBackground,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            FloatingActionButton(
              heroTag: 'register-fab',
              onPressed: onAddTransaction,
              backgroundColor: AppColors.primary,
              child: const Icon(
                TablerIcons.plus,
                color: AppColors.cardBackground,
              ),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: EntityPickerField<Account>(
                  labelText: 'Account',
                  items: viewModel.accounts,
                  idOf: (account) => account.id,
                  labelOf: (account) => account.archived
                      ? '${account.name} (archived)'
                      : account.name,
                  value: viewModel.selectedAccountId,
                  onChanged: (accountId) {
                    if (accountId != null) viewModel.selectAccount(accountId);
                  },
                ),
              ),
              Expanded(
                child: viewModel.rows.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions yet',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: viewModel.rows.length,
                        itemBuilder: (context, index) {
                          final row = viewModel.rows[index];
                          return RegisterRowTile(
                            row: row,
                            onReverse: () =>
                                viewModel.reverseEntry(row.entryId),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
