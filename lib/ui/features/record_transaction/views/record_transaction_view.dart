import 'package:flutter/material.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/record_transaction_view_model.dart';

/// Amount/direction/category/date form. The category picker excludes
/// archived categories (Archived category is not offered scenario).
class RecordTransactionView extends StatefulWidget {
  const RecordTransactionView({
    super.key,
    required this.viewModel,
    required this.ledgerRepository,
    this.onSaved,
  });

  final RecordTransactionViewModel viewModel;
  final LedgerRepository ledgerRepository;
  final VoidCallback? onSaved;

  @override
  State<RecordTransactionView> createState() => _RecordTransactionViewState();
}

class _RecordTransactionViewState extends State<RecordTransactionView> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncAmount(String text) {
    final parsed = double.tryParse(text);
    widget.viewModel.setAmountMinor(
      parsed == null ? null : (parsed * 100).round(),
    );
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
                DropdownButtonFormField<String>(
                  initialValue: widget.viewModel.financialAccountId,
                  decoration: const InputDecoration(labelText: 'Account'),
                  items: [
                    for (final account in widget.viewModel.financialAccounts)
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                  ],
                  onChanged: widget.viewModel.setFinancialAccountId,
                ),
                const SizedBox(height: AppSpacing.large),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Amount'),
                  onChanged: _syncAmount,
                ),
                const SizedBox(height: AppSpacing.large),
                StreamBuilder<List<Account>>(
                  stream: widget.ledgerRepository.watchCategories(),
                  builder: (context, snapshot) {
                    final categoryType =
                        widget.viewModel.direction ==
                            TransactionDirection.moneyIn
                        ? AccountType.income
                        : AccountType.expense;
                    final categories = (snapshot.data ?? const [])
                        .where((a) => a.type == categoryType)
                        .toList();
                    return DropdownButtonFormField<String>(
                      initialValue: widget.viewModel.categoryId,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: widget.viewModel.setCategoryId,
                    );
                  },
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
