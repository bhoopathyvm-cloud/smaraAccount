import 'package:flutter/material.dart';

import '../../../../domain/models/account.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
import '../view_models/correction_view_model.dart';

/// Fix a posted transaction (fix-this-correction-wizard): a form prefilled
/// with the original entry's fields, that on confirm posts a reversal and
/// a corrected replacement in one action - the household-voice
/// counterpart to the ledger's "reverse".
class CorrectionView extends StatefulWidget {
  const CorrectionView({super.key, required this.viewModel, this.onFixed});

  final CorrectionViewModel viewModel;
  final VoidCallback? onFixed;

  @override
  State<CorrectionView> createState() => _CorrectionViewState();
}

class _CorrectionViewState extends State<CorrectionView> {
  late final _amountController = TextEditingController(
    text: (widget.viewModel.amountMinor / 100).toStringAsFixed(2),
  );
  late final _descriptionController = TextEditingController(
    text: widget.viewModel.description ?? '',
  );

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
    if (picked != null) {
      widget.viewModel.setTransactionDate(picked);
    }
  }

  Future<void> _submit() async {
    final ok = await widget.viewModel.fix();
    if (ok) widget.onFixed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fix this entry', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  decoration: BoxDecoration(
                    color: AppColors.pageBackground,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMedium,
                    ),
                  ),
                  child: Text(
                    'The old line stays exactly as it was. Confirming adds '
                    'a correction next to it, so your history always shows '
                    'what happened and when you fixed it.',
                    style: AppTypography.body,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                SegmentedButton<TransactionDirection>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionDirection.moneyIn,
                      label: Text('Received'),
                    ),
                    ButtonSegment(
                      value: TransactionDirection.moneyOut,
                      label: Text('Spent'),
                    ),
                  ],
                  selected: {widget.viewModel.direction},
                  onSelectionChanged: (selection) =>
                      widget.viewModel.setDirection(selection.first),
                ),
                const SizedBox(height: AppSpacing.large),
                EntityPickerField<Account>(
                  labelText: 'Account',
                  items: widget.viewModel.financialAccounts,
                  idOf: (account) => account.id,
                  labelOf: (account) => account.name,
                  value: widget.viewModel.financialAccountId,
                  onChanged: widget.viewModel.setFinancialAccountId,
                ),
                const SizedBox(height: AppSpacing.large),
                MoneyAmountField(
                  controller: _amountController,
                  labelText: 'Amount',
                  currency: widget.viewModel.currency ?? 'USD',
                  onChangedMinor: widget.viewModel.setAmountMinor,
                ),
                const SizedBox(height: AppSpacing.large),
                EntityPickerField<Account>(
                  labelText: 'Category',
                  items: widget.viewModel.categories,
                  idOf: (account) => account.id,
                  labelOf: (account) => account.name,
                  value: widget.viewModel.categoryId,
                  onChanged: widget.viewModel.setCategoryId,
                ),
                const SizedBox(height: AppSpacing.large),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(
                    'Date: ${widget.viewModel.transactionDate.year}-'
                    '${widget.viewModel.transactionDate.month.toString().padLeft(2, '0')}-'
                    '${widget.viewModel.transactionDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  onChanged: widget.viewModel.setDescription,
                ),
                if (widget.viewModel.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    widget.viewModel.errorMessage!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                ElevatedButton(
                  onPressed: widget.viewModel.isSubmitting ? null : _submit,
                  child: const Text('Confirm fix'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
