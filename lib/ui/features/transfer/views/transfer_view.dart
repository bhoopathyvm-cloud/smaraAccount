import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
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
        title: Text('Transfer', style: AppTypography.headerTitle),
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
                DropdownButtonFormField<String>(
                  initialValue: viewModel.fromAccountId,
                  decoration: const InputDecoration(labelText: 'From account'),
                  items: [
                    for (final account in viewModel.accounts)
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                  ],
                  onChanged: viewModel.setFromAccountId,
                ),
                const SizedBox(height: AppSpacing.large),
                DropdownButtonFormField<String>(
                  key: ValueKey(viewModel.fromAccountId),
                  initialValue: viewModel.toAccountId,
                  decoration: const InputDecoration(labelText: 'To account'),
                  items: [
                    for (final account in viewModel.accounts)
                      if (account.id != viewModel.fromAccountId)
                        DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        ),
                  ],
                  onChanged: viewModel.setToAccountId,
                ),
                const SizedBox(height: AppSpacing.large),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    suffixText: viewModel.currencyFor(viewModel.fromAccountId),
                  ),
                  onChanged: (text) {
                    final amount = double.tryParse(text);
                    viewModel.setAmountMinor(
                      amount == null ? null : (amount * 100).round(),
                    );
                  },
                ),
                if (viewModel.isCrossCurrency) ...[
                  const SizedBox(height: AppSpacing.large),
                  TextField(
                    controller: _destinationAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Destination amount (optional)',
                      helperText:
                          'Leave blank if the exchange rate isn\'t known '
                          'yet - the transfer will be provisional until '
                          'settled.',
                      helperMaxLines: 2,
                      suffixText: viewModel.currencyFor(viewModel.toAccountId),
                    ),
                    onChanged: (text) {
                      final amount = double.tryParse(text);
                      viewModel.setDestinationAmountMinor(
                        amount == null ? null : (amount * 100).round(),
                      );
                    },
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
                TextField(
                  controller: _feeAmountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Fee amount',
                    suffixText: viewModel.currencyFor(viewModel.fromAccountId),
                  ),
                  onChanged: (text) {
                    final amount = double.tryParse(text);
                    viewModel.setFeeAmountMinor(
                      amount == null ? null : (amount * 100).round(),
                    );
                  },
                ),
                if (viewModel.feeAmountMinor != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  DropdownButtonFormField<String>(
                    initialValue: viewModel.feeCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Fee category',
                    ),
                    items: [
                      for (final category in viewModel.expenseCategories)
                        DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                    ],
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
                  child: const Text('Transfer'),
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
