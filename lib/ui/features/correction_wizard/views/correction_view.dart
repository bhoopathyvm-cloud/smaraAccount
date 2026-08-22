import 'package:flutter/material.dart';

import '../../../../domain/models/account.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
import '../../../core/money_formatter.dart';
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
  late final _amountController = TextEditingController();
  late final _descriptionController = TextEditingController(
    text: widget.viewModel.description ?? '',
  );
  var _didPrefillAmount = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_prefillAmountIfPossible);
    _prefillAmountIfPossible();
  }

  void _prefillAmountIfPossible() {
    if (_didPrefillAmount) return;
    final currency = widget.viewModel.currency;
    if (currency == null) return;
    _didPrefillAmount = true;
    _amountController.text = formatAmountMinor(
      widget.viewModel.amountMinor,
      currency,
    );
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_prefillAmountIfPossible);
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
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fixThisEntry, style: AppTypography.headerTitle),
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
                  child: Text(l10n.fixBlurb, style: AppTypography.body),
                ),
                const SizedBox(height: AppSpacing.large),
                SegmentedButton<TransactionDirection>(
                  segments: [
                    ButtonSegment(
                      value: TransactionDirection.moneyIn,
                      label: Text(l10n.captureReceived),
                    ),
                    ButtonSegment(
                      value: TransactionDirection.moneyOut,
                      label: Text(l10n.captureSpent),
                    ),
                  ],
                  selected: {widget.viewModel.direction},
                  onSelectionChanged: (selection) =>
                      widget.viewModel.setDirection(selection.first),
                ),
                const SizedBox(height: AppSpacing.large),
                EntityPickerField<Account>(
                  labelText: l10n.account,
                  items: widget.viewModel.financialAccounts,
                  idOf: (account) => account.id,
                  labelOf: (account) => localizeStoredName(l10n, account.name),
                  value: widget.viewModel.financialAccountId,
                  onChanged: widget.viewModel.setFinancialAccountId,
                ),
                const SizedBox(height: AppSpacing.large),
                MoneyAmountField(
                  controller: _amountController,
                  labelText: l10n.amount,
                  currency: widget.viewModel.currency ?? 'USD',
                  onChangedMinor: widget.viewModel.setAmountMinor,
                ),
                const SizedBox(height: AppSpacing.large),
                EntityPickerField<Account>(
                  labelText: l10n.category,
                  items: widget.viewModel.categories,
                  idOf: (account) => account.id,
                  labelOf: (account) => localizeStoredName(l10n, account.name),
                  value: widget.viewModel.categoryId,
                  onChanged: widget.viewModel.setCategoryId,
                ),
                const SizedBox(height: AppSpacing.large),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(
                    '${l10n.dateLabel}: ${widget.viewModel.transactionDate.year}-'
                    '${widget.viewModel.transactionDate.month.toString().padLeft(2, '0')}-'
                    '${widget.viewModel.transactionDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.descriptionOptional,
                  ),
                  onChanged: widget.viewModel.setDescription,
                ),
                if (widget.viewModel.errorMessageFor(l10n) != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    widget.viewModel.errorMessageFor(l10n)!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                ElevatedButton(
                  onPressed: widget.viewModel.isSubmitting ? null : _submit,
                  child: Text(l10n.actionConfirmFix),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
