import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/models/account.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
import '../view_models/record_transaction_view_model.dart';

/// Amount/direction/category/date form. The category picker excludes
/// archived categories (Archived category is not offered scenario).
class RecordTransactionView extends StatefulWidget {
  const RecordTransactionView({
    super.key,
    required this.viewModel,
    this.onSaved,
  });

  final RecordTransactionViewModel viewModel;
  final VoidCallback? onSaved;

  @override
  State<RecordTransactionView> createState() => _RecordTransactionViewState();
}

class _RecordTransactionViewState extends State<RecordTransactionView> {
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController();
  final _accountCurrencyAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _accountCurrencyAmountController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record transaction', style: AppTypography.headerTitle),
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
                SegmentedButton<TransactionDirection>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionDirection.moneyIn,
                      label: Text('Money in'),
                    ),
                    ButtonSegment(
                      value: TransactionDirection.moneyOut,
                      label: Text('Money out'),
                    ),
                  ],
                  selected: {widget.viewModel.direction},
                  onSelectionChanged: (selection) {
                    widget.viewModel.setDirection(selection.first);
                    widget.viewModel.setCategoryId(null);
                  },
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
                  suffixText:
                      widget.viewModel.nativeCurrency ??
                      widget.viewModel.accountCurrency,
                  onChangedMinor: widget.viewModel.setAmountMinor,
                ),
                const SizedBox(height: AppSpacing.large),
                TextField(
                  controller: _currencyController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 3,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) =>
                          newValue.copyWith(text: newValue.text.toUpperCase()),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Transaction currency (optional)',
                    helperText: widget.viewModel.accountCurrency == null
                        ? null
                        : 'Leave blank if this was in '
                              '${widget.viewModel.accountCurrency}, the '
                              "account's own currency.",
                    helperMaxLines: 2,
                    counterText: '',
                  ),
                  onChanged: widget.viewModel.setNativeCurrency,
                ),
                if (widget.viewModel.isForeignCurrency) ...[
                  const SizedBox(height: AppSpacing.large),
                  MoneyAmountField(
                    controller: _accountCurrencyAmountController,
                    labelText: 'Account-currency amount (optional)',
                    helperText:
                        'Leave blank if the exchange rate isn\'t known '
                        'yet - it will post provisional until settled.',
                    helperMaxLines: 2,
                    suffixText: widget.viewModel.accountCurrency,
                    onChangedMinor:
                        widget.viewModel.setAccountCurrencyAmountMinor,
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                EntityPickerField<Account>(
                  labelText: 'Category',
                  items: widget.viewModel.categories,
                  idOf: (category) => category.id,
                  labelOf: (category) => category.name,
                  value: widget.viewModel.categoryId,
                  onChanged: widget.viewModel.setCategoryId,
                ),
                const SizedBox(height: AppSpacing.large),
                OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(
                    'Date: '
                    '${widget.viewModel.transactionDate.year}-'
                    '${widget.viewModel.transactionDate.month.toString().padLeft(2, '0')}-'
                    '${widget.viewModel.transactionDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  onChanged: widget.viewModel.setDescription,
                ),
                if (widget.viewModel.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    widget.viewModel.errorMessage!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.xLarge),
                ElevatedButton(
                  onPressed: widget.viewModel.isSubmitting
                      ? null
                      : () async {
                          final success = await widget.viewModel.submit();
                          if (success) widget.onSaved?.call();
                        },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
