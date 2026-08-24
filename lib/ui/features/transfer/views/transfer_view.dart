import 'package:flutter/material.dart';

import '../../../../domain/models/account.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_text_field.dart';
import '../../../core/app_typography.dart';
import '../../../core/date_formatter.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
import '../view_models/transfer_view_model.dart';

class TransferView extends StatefulWidget {
  const TransferView({super.key, required this.viewModel, this.onSaved});

  final TransferViewModel viewModel;
  final VoidCallback? onSaved;

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  final _amountController = TextEditingController();
  final _destinationAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feeAmountController = TextEditingController();
  final _feeDescriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _destinationAmountController.dispose();
    _descriptionController.dispose();
    _feeAmountController.dispose();
    _feeDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.viewModel.transactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) widget.viewModel.setTransactionDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.captureMovedMoney, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final viewModel = widget.viewModel;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EntityPickerField<Account>(
                  labelText: l10n.fromAccount,
                  items: viewModel.accounts,
                  idOf: (account) => account.id,
                  labelOf: (account) => localizeStoredName(l10n, account.name),
                  value: viewModel.fromAccountId,
                  onChanged: viewModel.setFromAccountId,
                ),
                const SizedBox(height: AppSpacing.large),
                EntityPickerField<Account>(
                  key: ValueKey(viewModel.fromAccountId),
                  labelText: l10n.toAccount,
                  items: [
                    for (final account in viewModel.accounts)
                      if (account.id != viewModel.fromAccountId) account,
                  ],
                  idOf: (account) => account.id,
                  labelOf: (account) => localizeStoredName(l10n, account.name),
                  value: viewModel.toAccountId,
                  onChanged: viewModel.setToAccountId,
                ),
                const SizedBox(height: AppSpacing.large),
                MoneyAmountField(
                  controller: _amountController,
                  labelText: l10n.amount,
                  currency:
                      viewModel.currencyFor(viewModel.fromAccountId) ?? 'USD',
                  suffixText: viewModel.currencyFor(viewModel.fromAccountId),
                  onChangedMinor: viewModel.setAmountMinor,
                ),
                if (viewModel.isCrossCurrency) ...[
                  const SizedBox(height: AppSpacing.large),
                  MoneyAmountField(
                    controller: _destinationAmountController,
                    labelText: l10n.destinationAmountOptional,
                    currency:
                        viewModel.currencyFor(viewModel.toAccountId) ?? 'USD',
                    helperText: l10n.leaveBlankIfRateUnknown,
                    helperMaxLines: 2,
                    suffixText: viewModel.currencyFor(viewModel.toAccountId),
                    onChangedMinor: viewModel.setDestinationAmountMinor,
                  ),
                  if (viewModel.referenceRate != null) ...[
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      _formatRate(
                        l10n.referenceRate,
                        viewModel.currencyFor(viewModel.fromAccountId),
                        viewModel.currencyFor(viewModel.toAccountId),
                        viewModel.referenceRate!,
                      ),
                      style: AppTypography.metadata,
                    ),
                  ],
                  if (viewModel.impliedRate != null) ...[
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      _formatRate(
                        l10n.yourRate,
                        viewModel.currencyFor(viewModel.fromAccountId),
                        viewModel.currencyFor(viewModel.toAccountId),
                        viewModel.impliedRate!,
                      ),
                      style: AppTypography.metadata,
                    ),
                  ],
                ],
                const SizedBox(height: AppSpacing.large),
                OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(
                    '${l10n.dateLabel}: ${formatLocalDate(context, viewModel.transactionDate)}',
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                AppTextField(
                  controller: _descriptionController,
                  labelText: l10n.descriptionOptional,
                  onChanged: viewModel.setDescription,
                ),
                const SizedBox(height: AppSpacing.xLarge),
                Text(l10n.feeOptional, style: AppTypography.sectionLabel),
                const SizedBox(height: AppSpacing.small),
                Text(l10n.feeBankBlurb, style: AppTypography.metadata),
                const SizedBox(height: AppSpacing.medium),
                MoneyAmountField(
                  controller: _feeAmountController,
                  labelText: l10n.feeAmount,
                  currency:
                      viewModel.currencyFor(viewModel.fromAccountId) ?? 'USD',
                  suffixText: viewModel.currencyFor(viewModel.fromAccountId),
                  onChangedMinor: viewModel.setFeeAmountMinor,
                ),
                if (viewModel.feeAmountMinor != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  EntityPickerField<Account>(
                    labelText: l10n.feeCategory,
                    items: viewModel.expenseCategories,
                    idOf: (category) => category.id,
                    labelOf: (category) =>
                        localizeStoredName(l10n, category.name),
                    value: viewModel.feeCategoryId,
                    onChanged: viewModel.setFeeCategoryId,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  AppTextField(
                    controller: _feeDescriptionController,
                    labelText: l10n.feeDescriptionOptional,
                    onChanged: viewModel.setFeeDescription,
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: viewModel.feeDeductedFromAmount,
                    onChanged: (value) =>
                        viewModel.setFeeDeductedFromAmount(value ?? false),
                    title: Text(l10n.feeDeducted),
                    subtitle: Text(l10n.feeOnTopBlurb),
                  ),
                ],
                if (viewModel.accounts.length < 2) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    l10n.needTwoAccountsToTransfer,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                if (viewModel.errorMessageFor(l10n) != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    viewModel.errorMessageFor(l10n)!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.xLarge),
                ElevatedButton(
                  onPressed:
                      viewModel.isSubmitting || viewModel.accounts.length < 2
                      ? null
                      : () async {
                          if (await viewModel.submit()) {
                            widget.onSaved?.call();
                          }
                        },
                  child: Text(l10n.captureMovedMoney),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// e.g. "Reference rate: 1 USD ≈ 0.92 EUR" - display-only, never fed back
/// into any field.
String _formatRate(String label, String? from, String? to, double rate) {
  final fromLabel = from ?? '?';
  final toLabel = to ?? '?';
  return '$label: 1 $fromLabel ≈ ${rate.toStringAsFixed(4)} $toLabel';
}
