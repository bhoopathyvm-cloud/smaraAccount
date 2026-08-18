import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
import '../../../core/money_formatter.dart';
import '../../../core/status_banner.dart';
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
              onPressed: viewModel.isSelectedAccountArchived
                  ? null
                  : onAddTransaction,
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
              if (viewModel.errorMessage != null)
                StatusBanner(
                  message: viewModel.errorMessage!,
                  isError: true,
                  onDismiss: viewModel.clearError,
                ),
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
              if (viewModel.canCloseoutSelectedAccount)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                  ),
                  child: OutlinedButton(
                    onPressed: () => _showCloseoutDialog(context, viewModel),
                    child: const Text('Transfer remaining balance'),
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

  /// Controllers are intentionally not disposed after [showDialog] returns:
  /// the dialog route's exit animation still rebuilds its TextFields.
  Future<void> _showCloseoutDialog(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    final descriptionController = TextEditingController();
    final destinationAmountController = TextEditingController();
    String? toAccountId = viewModel.closeoutDestinationCandidates.isEmpty
        ? null
        : viewModel.closeoutDestinationCandidates.first.id;
    var transactionDate = DateTime.now();
    int? destinationAmountMinor;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isCrossCurrency = viewModel.isCloseoutCrossCurrency(
            toAccountId,
          );
          final sourceCurrency = viewModel.currencyFor(
            viewModel.selectedAccountId,
          );
          final destCurrency = viewModel.currencyFor(toAccountId);
          return AlertDialog(
            title: const Text('Transfer remaining balance'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EntityPickerField<Account>(
                    labelText: 'To account',
                    items: viewModel.closeoutDestinationCandidates,
                    idOf: (account) => account.id,
                    labelOf: (account) => account.name,
                    value: toAccountId,
                    onChanged: (accountId) {
                      setDialogState(() {
                        toAccountId = accountId;
                        destinationAmountMinor = null;
                        destinationAmountController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    'Amount: ${formatAmountMinor(viewModel.selectedAccountBalanceMinor)}'
                    '${sourceCurrency == null ? '' : ' $sourceCurrency'}',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (isCrossCurrency)
                    MoneyAmountField(
                      controller: destinationAmountController,
                      labelText: 'Destination amount',
                      suffixText: destCurrency,
                      onChangedMinor: (value) {
                        setDialogState(() => destinationAmountMinor = value);
                      },
                    ),
                  if (isCrossCurrency)
                    const SizedBox(height: AppSpacing.medium),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: transactionDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() => transactionDate = picked);
                      }
                    },
                    child: Text(
                      'Date: ${transactionDate.year}-'
                      '${transactionDate.month.toString().padLeft(2, '0')}-'
                      '${transactionDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: toAccountId == null
                    ? null
                    : () async {
                        final description = descriptionController.text.trim();
                        final ok = await viewModel.closeoutSelectedAccount(
                          toAccountId: toAccountId!,
                          transactionDate: transactionDate,
                          description: description.isEmpty ? null : description,
                          destinationAmountMinor: isCrossCurrency
                              ? destinationAmountMinor
                              : null,
                        );
                        if (ok && dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                child: const Text('Transfer'),
              ),
            ],
          );
        },
      ),
    );
  }
}
