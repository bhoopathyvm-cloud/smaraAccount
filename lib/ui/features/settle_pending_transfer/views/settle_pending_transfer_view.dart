import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/money_formatter.dart';
import '../view_models/settle_pending_transfer_view_model.dart';

class SettlePendingTransferView extends StatefulWidget {
  const SettlePendingTransferView({
    super.key,
    required this.viewModel,
    this.onSaved,
  });

  final SettlePendingTransferViewModel viewModel;
  final VoidCallback? onSaved;

  @override
  State<SettlePendingTransferView> createState() =>
      _SettlePendingTransferViewState();
}

class _SettlePendingTransferViewState extends State<SettlePendingTransferView> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.viewModel.summary;
    return Scaffold(
      appBar: AppBar(
        title: Text('Settle transfer', style: AppTypography.headerTitle),
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
                Text(
                  summary.destinationLabel == null
                      ? summary.sourceAccountName
                      : '${summary.sourceAccountName} → '
                            '${summary.destinationLabel}',
                  style: AppTypography.cardTitle,
                ),
                Text(
                  'Provisional: ${formatAmountMinor(summary.amountMinor)} '
                  '${summary.currency}',
                  style: AppTypography.metadata,
                ),
                const SizedBox(height: AppSpacing.large),
                if (viewModel.isTransfer) ...[
                  RadioGroup<String?>(
                    groupValue: viewModel.settledToAccountId,
                    onChanged: viewModel.setSettledToAccountId,
                    child: Column(
                      children: [
                        RadioListTile<String?>(
                          title: Text(
                            summary.destinationLabel == null
                                ? 'Delivered to destination'
                                : 'Delivered to ${summary.destinationLabel}',
                          ),
                          value: summary.pendingTransfer.destinationAccountId,
                        ),
                        RadioListTile<String?>(
                          title: Text(
                            'Returned to ${summary.sourceAccountName}',
                          ),
                          value: summary.pendingTransfer.sourceAccountId,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                ],
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Settled amount',
                    suffixText: viewModel.settledAmountCurrency,
                  ),
                  onChanged: (text) {
                    final amount = double.tryParse(text);
                    viewModel.setSettledAmountMinor(
                      amount == null ? null : (amount * 100).round(),
                    );
                  },
                ),
                if (viewModel.isShortfallComparable &&
                    viewModel.shortfallMinor > 0) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    'Shortfall: '
                    '${formatAmountMinor(viewModel.shortfallMinor)} '
                    '${summary.currency} - choose a category to cover it.',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  DropdownButtonFormField<String>(
                    initialValue: viewModel.feeCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Fee / loss category',
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
                  onPressed: viewModel.isSubmitting
                      ? null
                      : () async {
                          if (await viewModel.submit()) {
                            widget.onSaved?.call();
                          }
                        },
                  child: const Text('Settle'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
