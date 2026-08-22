import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../data/repositories/investment_holdings_logic.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/instrument.dart';
import '../../../../domain/models/instrument_holding.dart';
import '../../../../domain/models/instrument_quote.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
import '../../../core/money_formatter.dart';
import '../../../core/status_banner.dart';
import '../view_models/holdings_view_model.dart';

String instrumentKindLabel(AppLocalizations l10n, InstrumentKind kind) =>
    switch (kind) {
      InstrumentKind.stock => l10n.instrumentKindStock,
      InstrumentKind.etf => l10n.instrumentKindEtf,
      InstrumentKind.mutualFund => l10n.instrumentKindMutualFund,
      InstrumentKind.bond => l10n.instrumentKindBond,
      InstrumentKind.other => l10n.instrumentKindOther,
    };

String quoteUseLabel(AppLocalizations l10n, QuoteUse use) => switch (use) {
  QuoteUse.live => l10n.quoteUseLive,
  QuoteUse.cached => l10n.quoteUseCached,
  QuoteUse.stale => l10n.quoteUseStale,
  QuoteUse.missing => l10n.quoteUseMissing,
  QuoteUse.disabled => l10n.quoteUseDisabled,
  QuoteUse.currencyMismatch => l10n.quoteUseCurrencyMismatch,
};

class HoldingsView extends StatelessWidget {
  const HoldingsView({super.key, required this.viewModel, this.onOpenRegister});

  final HoldingsViewModel viewModel;
  final VoidCallback? onOpenRegister;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final l10n = l10nOf(context);
            final name = viewModel.account?.name;
            return Text(
              name == null
                  ? l10n.holdingsTitle
                  : localizeStoredName(l10n, name),
              style: AppTypography.headerTitle,
            );
          },
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            tooltip: l10nOf(context).homeCashRegister,
            onPressed: onOpenRegister,
            icon: const Icon(TablerIcons.receipt),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final l10n = l10nOf(context);
          final currency = viewModel.currency;
          return Column(
            children: [
              if (viewModel.errorMessageFor(l10n) != null)
                StatusBanner(
                  message: viewModel.errorMessageFor(l10n)!,
                  isError: true,
                  onDismiss: viewModel.clearError,
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  children: [
                    Text(l10n.holdingsCash, style: AppTypography.sectionLabel),
                    Text(
                      '${formatAmountMinor(viewModel.cashMinor, currency)} $currency',
                      style: AppTypography.balance,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      l10n.holdingsBook(
                        formatAmountMinor(viewModel.bookMinor, currency),
                        currency,
                      ),
                      style: AppTypography.body,
                    ),
                    Text(
                      l10n.holdingsMarketEstimate(
                        formatAmountMinor(viewModel.portfolioMinor, currency),
                        currency,
                      ),
                      style: AppTypography.cardTitle,
                    ),
                    Text(
                      l10n.holdingsQuotesBlurb,
                      style: AppTypography.metadata,
                    ),
                    const SizedBox(height: AppSpacing.xLarge),
                    Wrap(
                      spacing: AppSpacing.small,
                      runSpacing: AppSpacing.small,
                      children: [
                        ElevatedButton(
                          onPressed: viewModel.isArchived
                              ? null
                              : () => _showBuyDialog(context),
                          child: Text(l10n.actionBuy),
                        ),
                        OutlinedButton(
                          onPressed: () => _showSellDialog(context),
                          child: Text(l10n.actionSell),
                        ),
                        OutlinedButton(
                          onPressed: () => _showDividendDialog(context),
                          child: Text(l10n.actionDividend),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xLarge),
                    Text(
                      l10n.holdingsInventory,
                      style: AppTypography.sectionLabel,
                    ),
                    const SizedBox(height: AppSpacing.base),
                    if (viewModel.holdings.isEmpty)
                      Text(
                        l10n.holdingsNoHoldings,
                        style: AppTypography.metadata,
                      )
                    else
                      for (final holding in viewModel.holdings)
                        _HoldingRow(
                          holding: holding,
                          currency: currency,
                          quoteUse: viewModel.displayQuoteUse(holding),
                          onNameTap: () =>
                              _research(context, holding.instrument),
                          onRename: () =>
                              _showRenameInstrumentDialog(context, holding),
                          onArchive: () => _archiveInstrument(context, holding),
                        ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _research(BuildContext context, Instrument instrument) async {
    final result = await viewModel.researchInstrument(instrument);
    if (!context.mounted) return;
    final l10n = l10nOf(context);
    final message = result == ResearchLaunchResult.copied
        ? l10n.copiedResearchPrompt
        : l10n.openedFavouriteResearchTool;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _archiveInstrument(
    BuildContext context,
    InstrumentHolding holding,
  ) async {
    final l10n = l10nOf(context);
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.hideInstrumentTitle(holding.instrument.name),
      message: l10n.hideInstrumentBody,
      confirmLabel: l10n.actionHide,
    );
    if (confirmed) {
      await viewModel.archiveInstrument(holding.instrument.id);
    }
  }

  Future<void> _showRenameInstrumentDialog(
    BuildContext context,
    InstrumentHolding holding,
  ) async {
    final l10n = l10nOf(context);
    final controller = TextEditingController(text: holding.instrument.name);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renameInstrument),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final ok = await viewModel.renameInstrument(
                id: holding.instrument.id,
                newName: name,
              );
              if (ok && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  Future<void> _showBuyDialog(BuildContext context) async {
    final l10n = l10nOf(context);
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final brokerageController = TextEditingController();
    final descriptionController = TextEditingController();
    var funding = BuyFundingSource.cash;
    String? instrumentId;
    String? incomeCategoryId;
    String? brokerageCategoryId;
    int? quantityScaled;
    int? unitPriceMinor;
    int? brokerageMinor;
    DateTime transactionDate = DateTime.now();
    DateTime? lockedUntil;
    var creatingNew = false;
    final newNameController = TextEditingController();
    var newKind = InstrumentKind.stock;
    final tickerController = TextEditingController();
    final isinController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final currency = viewModel.currency;
          return AlertDialog(
            title: Text(l10n.actionBuy),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.recordTradeBlurb, style: AppTypography.metadata),
                    const SizedBox(height: AppSpacing.medium),
                    SegmentedButton<BuyFundingSource>(
                      segments: [
                        ButtonSegment(
                          value: BuyFundingSource.cash,
                          label: Text(l10n.cash),
                        ),
                        ButtonSegment(
                          value: BuyFundingSource.nonCash,
                          label: Text(l10n.nonCash),
                        ),
                      ],
                      selected: {funding},
                      onSelectionChanged: (selection) =>
                          setDialogState(() => funding = selection.first),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    if (!creatingNew) ...[
                      EntityPickerField<Instrument>(
                        labelText: l10n.instrument,
                        items: viewModel.instruments
                            .where((i) => !i.archived)
                            .toList(),
                        idOf: (i) => i.id,
                        labelOf: (i) => i.name,
                        value: instrumentId,
                        onChanged: (value) => instrumentId = value,
                      ),
                      TextButton(
                        onPressed: () =>
                            setDialogState(() => creatingNew = true),
                        child: Text(l10n.newInstrument),
                      ),
                    ] else ...[
                      TextField(
                        controller: newNameController,
                        decoration: InputDecoration(labelText: l10n.name),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      DropdownButtonFormField<InstrumentKind>(
                        initialValue: newKind,
                        decoration: InputDecoration(labelText: l10n.kindLabel),
                        items: [
                          for (final kind in InstrumentKind.values)
                            DropdownMenuItem(
                              value: kind,
                              child: Text(instrumentKindLabel(l10n, kind)),
                            ),
                        ],
                        onChanged: (kind) {
                          if (kind != null) {
                            setDialogState(() => newKind = kind);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextField(
                        controller: tickerController,
                        decoration: InputDecoration(
                          labelText: l10n.tickerOptional,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextField(
                        controller: isinController,
                        decoration: InputDecoration(
                          labelText: l10n.isinOptional,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.medium),
                    TextField(
                      controller: quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(labelText: l10n.quantity),
                      onChanged: (text) =>
                          quantityScaled = parseQuantityScaled(text),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    MoneyAmountField(
                      controller: priceController,
                      labelText: l10n.unitPrice,
                      currency: currency,
                      onChangedMinor: (value) => unitPriceMinor = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${l10n.dateLabel} ${transactionDate.toIso8601String().substring(0, 10)}',
                      ),
                      trailing: const Icon(TablerIcons.calendar),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: transactionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => transactionDate = picked);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        lockedUntil == null
                            ? l10n.lockUntilOptional
                            : l10n.lockedUntilDate(
                                lockedUntil!.toIso8601String().substring(0, 10),
                              ),
                      ),
                      subtitle: Text(l10n.lockUntilHint),
                      trailing: const Icon(TablerIcons.lock),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: lockedUntil ?? transactionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => lockedUntil = picked);
                        }
                      },
                    ),
                    if (funding == BuyFundingSource.nonCash)
                      EntityPickerField<Account>(
                        labelText: l10n.incomeCategory,
                        items: viewModel.incomeCategories,
                        idOf: (c) => c.id,
                        labelOf: (c) => localizeStoredName(l10n, c.name),
                        value: incomeCategoryId,
                        onChanged: (value) => incomeCategoryId = value,
                      ),
                    if (funding == BuyFundingSource.cash) ...[
                      MoneyAmountField(
                        controller: brokerageController,
                        labelText: l10n.brokerageOptional,
                        currency: currency,
                        onChangedMinor: (value) => brokerageMinor = value,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      EntityPickerField<Account>(
                        labelText: l10n.brokerageExpenseCategory,
                        items: viewModel.expenseCategories,
                        idOf: (c) => c.id,
                        labelOf: (c) => localizeStoredName(l10n, c.name),
                        value: brokerageCategoryId,
                        onChanged: (value) => brokerageCategoryId = value,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.medium),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.descriptionOptional,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.actionCancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  var id = instrumentId;
                  if (creatingNew) {
                    final name = newNameController.text.trim();
                    if (name.isEmpty) return;
                    final created = await viewModel.createInstrument(
                      name: name,
                      kind: newKind,
                      ticker: tickerController.text.trim().isEmpty
                          ? null
                          : tickerController.text.trim(),
                      isin: isinController.text.trim().isEmpty
                          ? null
                          : isinController.text.trim(),
                    );
                    if (created == null) return;
                    id = created.id;
                  }
                  if (id == null ||
                      quantityScaled == null ||
                      unitPriceMinor == null) {
                    return;
                  }
                  final ok = await viewModel.recordBuy(
                    instrumentId: id,
                    quantityScaled: quantityScaled!,
                    unitPriceMinor: unitPriceMinor!,
                    transactionDate: transactionDate,
                    fundingSource: funding,
                    incomeCategoryId: incomeCategoryId,
                    lockedUntil: lockedUntil,
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    brokerageMinor: brokerageMinor,
                    brokerageExpenseCategoryId: brokerageCategoryId,
                  );
                  if (ok && dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Text(l10n.actionRecordBuy),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showSellDialog(BuildContext context) async {
    final l10n = l10nOf(context);
    if (viewModel.holdings.isEmpty) return;
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final brokerageController = TextEditingController();
    final descriptionController = TextEditingController();
    var holding = viewModel.holdings.first;
    String? gainIncomeCategoryId;
    String? lossExpenseCategoryId;
    String? brokerageCategoryId;
    int? quantityScaled;
    int? unitPriceMinor;
    int? brokerageMinor;
    DateTime transactionDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final currency = viewModel.currency;
          final gainLoss = quantityScaled != null && unitPriceMinor != null
              ? viewModel.sellGainLossMinor(
                  holding: holding,
                  quantityScaled: quantityScaled!,
                  unitPriceMinor: unitPriceMinor!,
                )
              : null;
          return AlertDialog(
            title: Text(l10n.actionSell),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.recordTradeBlurb, style: AppTypography.metadata),
                    const SizedBox(height: AppSpacing.medium),
                    EntityPickerField<InstrumentHolding>(
                      labelText: l10n.instrument,
                      items: viewModel.holdings,
                      idOf: (h) => h.instrument.id,
                      labelOf: (h) => l10n.sellableQuantity(
                        h.instrument.name,
                        formatQuantityScaled(h.sellableQuantityScaled),
                      ),
                      value: holding.instrument.id,
                      onChanged: (id) {
                        final next = viewModel.holdings
                            .where((h) => h.instrument.id == id)
                            .firstOrNull;
                        if (next != null) {
                          setDialogState(() => holding = next);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    TextField(
                      controller: quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(labelText: l10n.quantity),
                      onChanged: (text) => setDialogState(
                        () => quantityScaled = parseQuantityScaled(text),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    MoneyAmountField(
                      controller: priceController,
                      labelText: l10n.unitPrice,
                      currency: currency,
                      onChangedMinor: (value) =>
                          setDialogState(() => unitPriceMinor = value),
                    ),
                    if (gainLoss != null) ...[
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        gainLoss > 0
                            ? l10n.looksLikeGain
                            : gainLoss < 0
                            ? l10n.looksLikeLoss
                            : l10n.looksLikeBreakEven,
                        style: AppTypography.body,
                      ),
                      if (gainLoss > 0)
                        EntityPickerField<Account>(
                          labelText: l10n.gainIncomeCategory,
                          items: viewModel.incomeCategories,
                          idOf: (c) => c.id,
                          labelOf: (c) => localizeStoredName(l10n, c.name),
                          value: gainIncomeCategoryId,
                          onChanged: (value) => gainIncomeCategoryId = value,
                        ),
                      if (gainLoss < 0)
                        EntityPickerField<Account>(
                          labelText: l10n.lossExpenseCategory,
                          items: viewModel.expenseCategories,
                          idOf: (c) => c.id,
                          labelOf: (c) => localizeStoredName(l10n, c.name),
                          value: lossExpenseCategoryId,
                          onChanged: (value) => lossExpenseCategoryId = value,
                        ),
                    ],
                    const SizedBox(height: AppSpacing.medium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${l10n.dateLabel} ${transactionDate.toIso8601String().substring(0, 10)}',
                      ),
                      trailing: const Icon(TablerIcons.calendar),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: transactionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => transactionDate = picked);
                        }
                      },
                    ),
                    MoneyAmountField(
                      controller: brokerageController,
                      labelText: l10n.brokerageOptional,
                      currency: currency,
                      onChangedMinor: (value) => brokerageMinor = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    EntityPickerField<Account>(
                      labelText: l10n.brokerageExpenseCategory,
                      items: viewModel.expenseCategories,
                      idOf: (c) => c.id,
                      labelOf: (c) => localizeStoredName(l10n, c.name),
                      value: brokerageCategoryId,
                      onChanged: (value) => brokerageCategoryId = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.descriptionOptional,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.actionCancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (quantityScaled == null || unitPriceMinor == null) {
                    return;
                  }
                  final ok = await viewModel.recordSell(
                    instrumentId: holding.instrument.id,
                    quantityScaled: quantityScaled!,
                    unitPriceMinor: unitPriceMinor!,
                    transactionDate: transactionDate,
                    gainIncomeCategoryId: gainIncomeCategoryId,
                    lossExpenseCategoryId: lossExpenseCategoryId,
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    brokerageMinor: brokerageMinor,
                    brokerageExpenseCategoryId: brokerageCategoryId,
                  );
                  if (ok && dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Text(l10n.actionRecordSell),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDividendDialog(BuildContext context) async {
    final l10n = l10nOf(context);
    // Only instruments this account has ever held (including fully sold
    // ones - `heldInstruments` is lot-derived, not filtered by remaining
    // quantity) are dividend-eligible here; `viewModel.instruments` is the
    // *global* instrument list and would let a dividend post against an
    // instrument this account never bought.
    final instruments = viewModel.heldInstruments;
    if (instruments.isEmpty) return;
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String? instrumentId = instruments.first.id;
    String? incomeCategoryId;
    int? amountMinor;
    DateTime transactionDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(l10n.actionDividend),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EntityPickerField<Instrument>(
                      labelText: l10n.instrument,
                      items: instruments,
                      idOf: (i) => i.id,
                      labelOf: (i) => i.name,
                      value: instrumentId,
                      onChanged: (value) => instrumentId = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    MoneyAmountField(
                      controller: amountController,
                      labelText: l10n.amount,
                      currency: viewModel.currency,
                      onChangedMinor: (value) => amountMinor = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    EntityPickerField<Account>(
                      labelText: l10n.incomeCategory,
                      items: viewModel.incomeCategories,
                      idOf: (c) => c.id,
                      labelOf: (c) => localizeStoredName(l10n, c.name),
                      value: incomeCategoryId,
                      onChanged: (value) => incomeCategoryId = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${l10n.dateLabel} ${transactionDate.toIso8601String().substring(0, 10)}',
                      ),
                      trailing: const Icon(TablerIcons.calendar),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: transactionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => transactionDate = picked);
                        }
                      },
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.descriptionOptional,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.actionCancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (instrumentId == null ||
                      amountMinor == null ||
                      incomeCategoryId == null) {
                    return;
                  }
                  final ok = await viewModel.recordDividend(
                    instrumentId: instrumentId!,
                    amountMinor: amountMinor!,
                    transactionDate: transactionDate,
                    incomeCategoryId: incomeCategoryId!,
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  );
                  if (ok && dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Text(l10n.actionRecordDividend),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HoldingRow extends StatelessWidget {
  const _HoldingRow({
    required this.holding,
    required this.currency,
    required this.quoteUse,
    required this.onNameTap,
    required this.onRename,
    required this.onArchive,
  });

  final InstrumentHolding holding;
  final String currency;
  final QuoteUse quoteUse;
  final VoidCallback onNameTap;
  final VoidCallback onRename;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final unrealized = holding.displayUnrealizedMinor;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onNameTap,
                    child: Text(
                      holding.instrument.name,
                      style: AppTypography.cardTitle.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(TablerIcons.dotsVertical),
                  tooltip: l10n.instrumentActions,
                  onSelected: (value) {
                    if (value == 'rename') onRename();
                    if (value == 'archive') onArchive();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text(l10n.actionRename),
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(l10n.actionHide),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              '${l10n.holdingsUnitsCost(formatQuantityScaled(holding.quantityScaled))}'
              '${formatAmountMinor(holding.averageCostMinor, currency)} $currency',
              style: AppTypography.body,
            ),
            Text(
              '${l10n.unrealizedLabel(formatAmountMinor(unrealized, currency), currency)}'
              ' · ${quoteUseLabel(l10n, quoteUse)}',
              style: AppTypography.metadata,
            ),
            Text(l10n.holdingsTapNameToResearch, style: AppTypography.metadata),
          ],
        ),
      ),
    );
  }
}
