import 'package:flutter/material.dart';

import '../../../../domain/models/account.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
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
        title: Text('What arrived?', style: AppTypography.headerTitle),
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
                // pending-transfers-plain-language: same human-sentence
                // voice as Home's pending line, hiding FX-settlement
                // jargon from the copy (design.md Decisions).
                Text(
                  summary.destinationLabel == null
                      ? 'You sent '
                            '${formatAmountMinor(summary.amountMinor, summary.currency)} '
                            '${summary.currency} from '
                            '${summary.sourceAccountName}'
                      : 'You sent '
                            '${formatAmountMinor(summary.amountMinor, summary.currency)} '
                            '${summary.currency} to ${summary.destinationLabel}',
                  style: AppTypography.cardTitle,
                ),
                Text(
                  'Tell us what actually arrived so we can settle it.',
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
                MoneyAmountField(
                  controller: _amountController,
                  labelText: 'Settled amount',
                  currency: viewModel.settledAmountCurrency ?? summary.currency,
                  suffixText: viewModel.settledAmountCurrency,
                  onChangedMinor: viewModel.setSettledAmountMinor,
                ),
                if (viewModel.isShortfallComparable &&
                    viewModel.shortfallMinor > 0) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    'You received '
                    '${formatAmountMinor(viewModel.shortfallMinor, summary.currency)} '
                    '${summary.currency} less than expected - choose a '
                    'category to cover the difference.',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  EntityPickerField<Account>(
                    labelText: 'Fee / loss category',
                    items: viewModel.expenseCategories,
                    idOf: (category) => category.id,
                    labelOf: (category) => category.name,
                    value: viewModel.feeCategoryId,
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
