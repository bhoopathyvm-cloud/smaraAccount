import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
import '../../../../domain/models/payee.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
import '../../../core/money_formatter.dart';
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

  /// One amount-field controller per split line, keyed by [SplitLine.id]
  /// (stable across reorders/edits, not the line's index) - split-transactions.
  final Map<int, TextEditingController> _splitAmountControllers = {};

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _accountCurrencyAmountController.dispose();
    for (final controller in _splitAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _splitAmountController(int lineId) {
    return _splitAmountControllers.putIfAbsent(
      lineId,
      () => TextEditingController(),
    );
  }

  /// Drops controllers for lines that no longer exist (removed, or the
  /// split collapsed back to a single category) - called each build since
  /// [SplitLine.id] identities only change via add/remove.
  void _pruneSplitAmountControllers(List<SplitLine> currentLines) {
    final currentIds = currentLines.map((l) => l.id).toSet();
    final staleIds = _splitAmountControllers.keys
        .where((id) => !currentIds.contains(id))
        .toList();
    for (final id in staleIds) {
      _splitAmountControllers.remove(id)?.dispose();
    }
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
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.actionRecordTransaction,
          style: AppTypography.headerTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          _pruneSplitAmountControllers(widget.viewModel.splitLines);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  onSelectionChanged: (selection) {
                    widget.viewModel.setDirection(selection.first);
                    widget.viewModel.setCategoryId(null);
                  },
                ),
                // credit-card-household-flow: "Paid from card"/"Paid from
                // bank" shortcuts, offered only for Spent when at least
                // one account is flagged as a credit card (spec: "No
                // cards means no shortcut"). Both just narrow/preselect
                // the same Account picker below, which is never removed.
                if (widget.viewModel.direction ==
                        TransactionDirection.moneyOut &&
                    widget.viewModel.hasCardAccounts) ...[
                  Wrap(
                    spacing: AppSpacing.small,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.paidFromCard),
                        selected: widget.viewModel.isPaidFromCard,
                        onSelected: (_) =>
                            widget.viewModel.selectPaidFromCard(),
                      ),
                      ChoiceChip(
                        label: Text(l10n.paidFromBank),
                        selected: widget.viewModel.isPaidFromBank,
                        onSelected: (_) =>
                            widget.viewModel.selectPaidFromBank(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                ],
                EntityPickerField<Account>(
                  labelText: l10n.account,
                  items: widget.viewModel.financialAccountOptions,
                  idOf: (account) => account.id,
                  labelOf: (account) => localizeStoredName(l10n, account.name),
                  value: widget.viewModel.financialAccountId,
                  onChanged: widget.viewModel.setFinancialAccountId,
                ),
                const SizedBox(height: AppSpacing.large),
                MoneyAmountField(
                  controller: _amountController,
                  labelText: l10n.amount,
                  currency:
                      widget.viewModel.nativeCurrency ??
                      widget.viewModel.accountCurrency ??
                      'USD',
                  suffixText:
                      widget.viewModel.nativeCurrency ??
                      widget.viewModel.accountCurrency,
                  onChangedMinor: widget.viewModel.setAmountMinor,
                ),
                // split-transactions: no foreign-currency support for a
                // split (recordSplitTransaction always posts in the
                // account's own currency) - hidden while splitting rather
                // than left visible but ignored at submit time.
                if (!widget.viewModel.isSplitting) ...[
                  const SizedBox(height: AppSpacing.large),
                  TextField(
                    controller: _currencyController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 3,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                      TextInputFormatter.withFunction(
                        (oldValue, newValue) => newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                        ),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.transactionCurrencyOptional,
                      helperText: widget.viewModel.accountCurrency == null
                          ? null
                          : l10n.leaveBlankIfThisWasAccountCurrency(
                              widget.viewModel.accountCurrency!,
                            ),
                      helperMaxLines: 2,
                      counterText: '',
                    ),
                    onChanged: widget.viewModel.setNativeCurrency,
                  ),
                  if (widget.viewModel.isForeignCurrency) ...[
                    const SizedBox(height: AppSpacing.large),
                    MoneyAmountField(
                      controller: _accountCurrencyAmountController,
                      labelText: l10n.accountCurrencyAmountOptional,
                      currency: widget.viewModel.accountCurrency ?? 'USD',
                      helperText: l10n.leaveBlankIfRateUnknown,
                      helperMaxLines: 2,
                      suffixText: widget.viewModel.accountCurrency,
                      onChangedMinor:
                          widget.viewModel.setAccountCurrencyAmountMinor,
                    ),
                  ],
                ],
                const SizedBox(height: AppSpacing.large),
                if (!widget.viewModel.isSplitting) ...[
                  EntityPickerField<Account>(
                    labelText: l10n.category,
                    items: widget.viewModel.categories,
                    idOf: (category) => category.id,
                    labelOf: (category) =>
                        localizeStoredName(l10n, category.name),
                    value: widget.viewModel.categoryId,
                    onChanged: widget.viewModel.setCategoryId,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: widget.viewModel.startSplitting,
                      child: Text(l10n.splitIntoCategories),
                    ),
                  ),
                ] else
                  _SplitLines(
                    viewModel: widget.viewModel,
                    amountControllerFor: _splitAmountController,
                  ),
                const SizedBox(height: AppSpacing.large),
                OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(
                    '${l10n.dateLabel}: '
                    '${widget.viewModel.transactionDate.year}-'
                    '${widget.viewModel.transactionDate.month.toString().padLeft(2, '0')}-'
                    '${widget.viewModel.transactionDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                // payees-and-spending-memory: autocomplete suggests saved
                // payees only (design.md Non-Goals - not mined from
                // historical transaction descriptions). Selecting one
                // applies its remembered defaults via
                // RecordTransactionViewModel.selectPayee, always
                // overridable afterward.
                Autocomplete<Payee>(
                  optionsBuilder: (value) =>
                      widget.viewModel.payeeSuggestions(value.text),
                  displayStringForOption: (payee) => payee.name,
                  onSelected: widget.viewModel.selectPayee,
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: l10n.descriptionOptional,
                          ),
                          onChanged: widget.viewModel.setDescription,
                        );
                      },
                ),
                if (widget.viewModel.errorMessageFor(l10n) != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    widget.viewModel.errorMessageFor(l10n)!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.xLarge),
                ElevatedButton(
                  onPressed:
                      widget.viewModel.isSubmitting ||
                          (widget.viewModel.isSplitting &&
                              widget.viewModel.splitRemainderMinor != 0)
                      ? null
                      : () async {
                          final success = await widget.viewModel.submit();
                          if (success) widget.onSaved?.call();
                        },
                  child: Text(l10n.actionSave),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// split-transactions: an editable list of (category, amount) lines plus
/// the running remainder, shown once [RecordTransactionViewModel.startSplitting]
/// has been called (spec: "Split Entry Form Shows a Running Remainder").
class _SplitLines extends StatelessWidget {
  const _SplitLines({
    required this.viewModel,
    required this.amountControllerFor,
  });

  final RecordTransactionViewModel viewModel;
  final TextEditingController Function(int lineId) amountControllerFor;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final currency = viewModel.accountCurrency ?? 'USD';
    final lines = viewModel.splitLines;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: EntityPickerField<Account>(
                  labelText: l10n.categoryN('${i + 1}'),
                  items: viewModel.categories,
                  idOf: (category) => category.id,
                  labelOf: (category) =>
                      localizeStoredName(l10n, category.name),
                  value: lines[i].categoryId,
                  onChanged: (value) =>
                      viewModel.setSplitLineCategory(i, value),
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: MoneyAmountField(
                  controller: amountControllerFor(lines[i].id),
                  labelText: l10n.amount,
                  currency: currency,
                  suffixText: currency,
                  onChangedMinor: (value) =>
                      viewModel.setSplitLineAmount(i, value),
                ),
              ),
              IconButton(
                icon: const Icon(TablerIcons.trash),
                color: AppColors.signal,
                onPressed: () => viewModel.removeSplitLine(i),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: viewModel.addSplitLine,
            child: Text(l10n.addCategory),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          l10n.homeRemaining(
            '${formatAmountMinor(viewModel.splitRemainderMinor, currency)} $currency',
          ),
          style: AppTypography.body.copyWith(
            color: viewModel.splitRemainderMinor == 0
                ? AppColors.textSecondary
                : AppColors.signal,
          ),
        ),
      ],
    );
  }
}
