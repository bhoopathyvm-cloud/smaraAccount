import 'package:flutter/material.dart';

import '../../../../domain/models/account.dart';
import '../../../../l10n/l10n.dart';
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
    final l10n = l10nOf(context);
    final summary = widget.viewModel.summary;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.whatArrivedTitle, style: AppTypography.headerTitle),
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
                      ? l10n.youSentFrom(
                          formatAmountMinor(
                            summary.amountMinor,
                            summary.currency,
                          ),
                          summary.currency,
                          localizeStoredName(l10n, summary.sourceAccountName),
                        )
                      : l10n.youSentTo(
                          formatAmountMinor(
                            summary.amountMinor,
                            summary.currency,
                          ),
                          summary.currency,
                          localizeStoredName(l10n, summary.destinationLabel!),
                        ),
                  style: AppTypography.cardTitle,
                ),
                Text(l10n.whatArrivedBlurb, style: AppTypography.metadata),
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
                                ? l10n.deliveredToDestination
                                : l10n.deliveredToName(
                                    localizeStoredName(
                                      l10n,
                                      summary.destinationLabel!,
                                    ),
                                  ),
                          ),
                          value: summary.pendingTransfer.destinationAccountId,
                        ),
                        RadioListTile<String?>(
                          title: Text(
                            l10n.homeReturnedTo(
                              localizeStoredName(
                                l10n,
                                summary.sourceAccountName,
                              ),
                            ),
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
                  labelText: l10n.amountThatArrived,
                  currency: viewModel.settledAmountCurrency ?? summary.currency,
                  suffixText: viewModel.settledAmountCurrency,
                  onChangedMinor: viewModel.setSettledAmountMinor,
                ),
                if (viewModel.isShortfallComparable &&
                    viewModel.shortfallMinor > 0) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    l10n.youReceivedLessThanExpected(
                      formatAmountMinor(
                        viewModel.shortfallMinor,
                        summary.currency,
                      ),
                      summary.currency,
                    ),
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  EntityPickerField<Account>(
                    labelText: l10n.feeLossCategory,
                    items: viewModel.expenseCategories,
                    idOf: (category) => category.id,
                    labelOf: (category) =>
                        localizeStoredName(l10n, category.name),
                    value: viewModel.feeCategoryId,
                    onChanged: viewModel.setFeeCategoryId,
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
                  onPressed: viewModel.isSubmitting
                      ? null
                      : () async {
                          if (await viewModel.submit()) {
                            widget.onSaved?.call();
                          }
                        },
                  child: Text(l10n.actionSettle),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
