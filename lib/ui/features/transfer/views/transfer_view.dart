import 'package:flutter/material.dart';

import '../../../../domain/models/account.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Moved money', style: AppTypography.headerTitle),
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
                  labelText: 'From account',
                  items: viewModel.accounts,
                  idOf: (account) => account.id,
                  labelOf: (account) => account.name,
                  value: viewModel.fromAccountId,
                  onChanged: viewModel.setFromAccountId,
                ),
                const SizedBox(height: AppSpacing.large),
                EntityPickerField<Account>(
                  key: ValueKey(viewModel.fromAccountId),
                  labelText: 'To account',
                  items: [
                    for (final account in viewModel.accounts)
                      if (account.id != viewModel.fromAccountId) account,
                  ],
                  idOf: (account) => account.id,
                  labelOf: (account) => account.name,
                  value: viewModel.toAccountId,
                  onChanged: viewModel.setToAccountId,
                ),
                const SizedBox(height: AppSpacing.large),
                MoneyAmountField(
                  controller: _amountController,
                  labelText: 'Amount',
                  currency:
                      viewModel.currencyFor(viewModel.fromAccountId) ?? 'USD',
                  suffixText: viewModel.currencyFor(viewModel.fromAccountId),
                  onChangedMinor: viewModel.setAmountMinor,
                ),
                if (viewModel.isCrossCurrency) ...[
                  const SizedBox(height: AppSpacing.large),
                  MoneyAmountField(
                    controller: _destinationAmountController,
                    labelText: 'Destination amount (optional)',
                    currency:
                        viewModel.currencyFor(viewModel.toAccountId) ?? 'USD',
                    helperText:
                        'Leave blank if the exchange rate isn\'t known '
                        'yet - the transfer will be provisional until '
                        'settled.',
                    helperMaxLines: 2,
                    suffixText: viewModel.currencyFor(viewModel.toAccountId),
                    onChangedMinor: viewModel.setDestinationAmountMinor,
                  ),
                  if (viewModel.referenceRate != null) ...[
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      _formatRate(
                        'Reference rate',
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
                        'Your rate',
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
                    'Date: ${_formatDate(viewModel.transactionDate)}',
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  onChanged: viewModel.setDescription,
                ),
                const SizedBox(height: AppSpacing.xLarge),
                Text('Fee (optional)', style: AppTypography.sectionLabel),
                const SizedBox(height: AppSpacing.small),
                Text(
                  'An upfront commission charged by your bank or an '
                  'intermediary for this transfer, posted as its own '
                  'expense - separate from any shortfall fee you might '
                  'later record when settling a pending cross-currency '
                  'transfer.',
                  style: AppTypography.metadata,
                ),
                const SizedBox(height: AppSpacing.medium),
                MoneyAmountField(
                  controller: _feeAmountController,
                  labelText: 'Fee amount',
                  currency:
                      viewModel.currencyFor(viewModel.fromAccountId) ?? 'USD',
                  suffixText: viewModel.currencyFor(viewModel.fromAccountId),
                  onChangedMinor: viewModel.setFeeAmountMinor,
                ),
                if (viewModel.feeAmountMinor != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  EntityPickerField<Account>(
                    labelText: 'Fee category',
                    items: viewModel.expenseCategories,
                    idOf: (category) => category.id,
                    labelOf: (category) => category.name,
                    value: viewModel.feeCategoryId,
                    onChanged: viewModel.setFeeCategoryId,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  TextField(
                    controller: _feeDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Fee description (optional)',
                    ),
                    onChanged: viewModel.setFeeDescription,
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: viewModel.feeDeductedFromAmount,
                    onChanged: (value) =>
                        viewModel.setFeeDeductedFromAmount(value ?? false),
                    title: const Text('Fee is deducted from the amount above'),
                    subtitle: const Text(
                      'On: the amount above is the total taken from this '
                      'account, and the fee is carved out of it before '
                      'conversion (e.g. a remittance service). Off: the fee '
                      'is charged in addition to the full amount (e.g. a '
                      'bank wire fee).',
                    ),
                  ),
                ],
                if (viewModel.accounts.length < 2) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    'Create at least two active accounts to make a transfer.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    viewModel.errorMessage!,
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
                  child: const Text('Moved money'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// e.g. "Reference rate: 1 USD ≈ 0.92 EUR" - display-only, never fed back
/// into any field.
String _formatRate(String label, String? from, String? to, double rate) {
  final fromLabel = from ?? '?';
  final toLabel = to ?? '?';
  return '$label: 1 $fromLabel ≈ ${rate.toStringAsFixed(4)} $toLabel';
}
