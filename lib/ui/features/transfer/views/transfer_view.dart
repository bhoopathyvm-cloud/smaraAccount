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
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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
                  decoration: const InputDecoration(labelText: 'Amount'),
                  onChanged: (text) {
                    final amount = double.tryParse(text);
                    viewModel.setAmountMinor(
                      amount == null ? null : (amount * 100).round(),
                    );
                  },
                ),
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
