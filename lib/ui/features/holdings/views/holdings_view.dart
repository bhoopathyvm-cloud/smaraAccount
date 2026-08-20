import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../data/repositories/investment_holdings_logic.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/instrument.dart';
import '../../../../domain/models/instrument_holding.dart';
import '../../../../domain/models/instrument_quote.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
import '../../../core/money_formatter.dart';
import '../../../core/status_banner.dart';
import '../view_models/holdings_view_model.dart';

String instrumentKindLabel(InstrumentKind kind) => switch (kind) {
  InstrumentKind.stock => 'Stock',
  InstrumentKind.etf => 'ETF',
  InstrumentKind.mutualFund => 'Mutual fund',
  InstrumentKind.bond => 'Bond',
  InstrumentKind.other => 'Other',
};

String quoteUseLabel(QuoteUse use) => switch (use) {
  QuoteUse.live => 'Live price',
  QuoteUse.cached => 'Cached price',
  QuoteUse.stale => 'Stale price',
  QuoteUse.missing => 'Using cost (no price)',
  QuoteUse.disabled => 'Quotes off — using cost/cache',
  QuoteUse.currencyMismatch => 'Using cost (price currency differs)',
};

class HoldingsView extends StatelessWidget {
  const HoldingsView({
    super.key,
    required this.viewModel,
    this.onOpenRegister,
  });

  final HoldingsViewModel viewModel;
  final VoidCallback? onOpenRegister;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => Text(
            viewModel.account?.name ?? 'Holdings',
            style: AppTypography.headerTitle,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            tooltip: 'Cash register',
            onPressed: onOpenRegister,
            icon: const Icon(TablerIcons.receipt),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final currency = viewModel.currency;
          return Column(
            children: [
              if (viewModel.errorMessage != null)
                StatusBanner(
                  message: viewModel.errorMessage!,
                  isError: true,
                  onDismiss: viewModel.clearError,
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  children: [
                    Text('CASH', style: AppTypography.sectionLabel),
                    Text(
                      '${formatAmountMinor(viewModel.cashMinor, currency)} $currency',
                      style: AppTypography.balance,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      'Book (cash + cost) ${formatAmountMinor(viewModel.bookMinor, currency)} $currency',
                      style: AppTypography.body,
                    ),
                    Text(
                      'Market estimate ${formatAmountMinor(viewModel.portfolioMinor, currency)} $currency',
                      style: AppTypography.cardTitle,
                    ),
                    Text(
                      'Quotes are estimates, not a broker price. This app '
                      'does not place orders.',
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
                          child: const Text('Buy'),
                        ),
                        OutlinedButton(
                          onPressed: () => _showSellDialog(context),
                          child: const Text('Sell'),
                        ),
                        OutlinedButton(
                          onPressed: () => _showDividendDialog(context),
                          child: const Text('Dividend'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xLarge),
                    Text('INVENTORY', style: AppTypography.sectionLabel),
                    const SizedBox(height: AppSpacing.base),
                    if (viewModel.holdings.isEmpty)
                      Text(
                        'No holdings yet. Record a buy to add an instrument.',
                        style: AppTypography.metadata,
                      )
                    else
                      for (final holding in viewModel.holdings)
                        _HoldingRow(
                          holding: holding,
                          currency: currency,
                          quoteUse: viewModel.displayQuoteUse(holding),
                          onNameTap: () => _research(context, holding.instrument),
                          onRename: () =>
                              _showRenameInstrumentDialog(context, holding),
                          onArchive: () =>
                              _archiveInstrument(context, holding),
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
    final message = result == ResearchLaunchResult.copied
        ? 'Copied a research prompt — no browser URL available, or you are offline.'
        : 'Opened your favourite research tool.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _archiveInstrument(
    BuildContext context,
    InstrumentHolding holding,
  ) async {
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: 'Hide ${holding.instrument.name}?',
      message:
          'Hidden instruments stay on past buys and sells. You can still '
          'record a dividend for them.',
      confirmLabel: 'Hide',
    );
    if (confirmed) {
      await viewModel.archiveInstrument(holding.instrument.id);
    }
  }

  Future<void> _showRenameInstrumentDialog(
    BuildContext context,
    InstrumentHolding holding,
  ) async {
    final controller = TextEditingController(text: holding.instrument.name);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename instrument'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBuyDialog(BuildContext context) async {
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
            title: const Text('Buy'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Record a trade that already happened. This app does '
                      'not send orders to a broker.',
                      style: AppTypography.metadata,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    SegmentedButton<BuyFundingSource>(
                      segments: const [
                        ButtonSegment(
                          value: BuyFundingSource.cash,
                          label: Text('Cash'),
                        ),
                        ButtonSegment(
                          value: BuyFundingSource.nonCash,
                          label: Text('Non-cash'),
                        ),
                      ],
                      selected: {funding},
                      onSelectionChanged: (selection) =>
                          setDialogState(() => funding = selection.first),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    if (!creatingNew) ...[
                      EntityPickerField<Instrument>(
                        labelText: 'Instrument',
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
                        child: const Text('New instrument'),
                      ),
                    ] else ...[
                      TextField(
                        controller: newNameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      DropdownButtonFormField<InstrumentKind>(
                        initialValue: newKind,
                        decoration: const InputDecoration(labelText: 'Kind'),
                        items: [
                          for (final kind in InstrumentKind.values)
                            DropdownMenuItem(
                              value: kind,
                              child: Text(instrumentKindLabel(kind)),
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
                        decoration: const InputDecoration(
                          labelText: 'Ticker (optional)',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextField(
                        controller: isinController,
                        decoration: const InputDecoration(
                          labelText: 'ISIN (optional)',
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.medium),
                    TextField(
                      controller: quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                      onChanged: (text) =>
                          quantityScaled = parseQuantityScaled(text),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    MoneyAmountField(
                      controller: priceController,
                      labelText: 'Unit price',
                      currency: currency,
                      onChangedMinor: (value) => unitPriceMinor = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Date ${transactionDate.toIso8601String().substring(0, 10)}',
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
                            ? 'Lock until (optional)'
                            : 'Locked until ${lockedUntil!.toIso8601String().substring(0, 10)}',
                      ),
                      subtitle: const Text(
                        'Your own note of a restriction, not a broker rule.',
                      ),
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
                        labelText: 'Income category',
                        items: viewModel.incomeCategories,
                        idOf: (c) => c.id,
                        labelOf: (c) => c.name,
                        value: incomeCategoryId,
                        onChanged: (value) => incomeCategoryId = value,
                      ),
                    if (funding == BuyFundingSource.cash) ...[
                      MoneyAmountField(
                        controller: brokerageController,
                        labelText: 'Brokerage (optional)',
                        currency: currency,
                        onChangedMinor: (value) => brokerageMinor = value,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      EntityPickerField<Account>(
                        labelText: 'Brokerage expense category',
                        items: viewModel.expenseCategories,
                        idOf: (c) => c.id,
                        labelOf: (c) => c.name,
                        value: brokerageCategoryId,
                        onChanged: (value) => brokerageCategoryId = value,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.medium),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
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
                child: const Text('Record buy'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showSellDialog(BuildContext context) async {
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
            title: const Text('Sell'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Record a trade that already happened. This app does '
                      'not send orders to a broker.',
                      style: AppTypography.metadata,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    EntityPickerField<InstrumentHolding>(
                      labelText: 'Instrument',
                      items: viewModel.holdings,
                      idOf: (h) => h.instrument.id,
                      labelOf: (h) =>
                          '${h.instrument.name} (${formatQuantityScaled(h.sellableQuantityScaled)} sellable)',
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
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      onChanged: (text) => setDialogState(
                        () => quantityScaled = parseQuantityScaled(text),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    MoneyAmountField(
                      controller: priceController,
                      labelText: 'Unit price',
                      currency: currency,
                      onChangedMinor: (value) => setDialogState(
                        () => unitPriceMinor = value,
                      ),
                    ),
                    if (gainLoss != null) ...[
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        gainLoss > 0
                            ? 'This looks like a gain'
                            : gainLoss < 0
                            ? 'This looks like a loss'
                            : 'This looks like break-even',
                        style: AppTypography.body,
                      ),
                      if (gainLoss > 0)
                        EntityPickerField<Account>(
                          labelText: 'Gain income category',
                          items: viewModel.incomeCategories,
                          idOf: (c) => c.id,
                          labelOf: (c) => c.name,
                          value: gainIncomeCategoryId,
                          onChanged: (value) => gainIncomeCategoryId = value,
                        ),
                      if (gainLoss < 0)
                        EntityPickerField<Account>(
                          labelText: 'Loss expense category',
                          items: viewModel.expenseCategories,
                          idOf: (c) => c.id,
                          labelOf: (c) => c.name,
                          value: lossExpenseCategoryId,
                          onChanged: (value) => lossExpenseCategoryId = value,
                        ),
                    ],
                    const SizedBox(height: AppSpacing.medium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Date ${transactionDate.toIso8601String().substring(0, 10)}',
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
                      labelText: 'Brokerage (optional)',
                      currency: currency,
                      onChangedMinor: (value) => brokerageMinor = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    EntityPickerField<Account>(
                      labelText: 'Brokerage expense category',
                      items: viewModel.expenseCategories,
                      idOf: (c) => c.id,
                      labelOf: (c) => c.name,
                      value: brokerageCategoryId,
                      onChanged: (value) => brokerageCategoryId = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
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
                child: const Text('Record sell'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDividendDialog(BuildContext context) async {
    final instruments = viewModel.heldInstruments.isNotEmpty
        ? viewModel.heldInstruments
        : viewModel.instruments;
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
            title: const Text('Dividend'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EntityPickerField<Instrument>(
                      labelText: 'Instrument',
                      items: instruments,
                      idOf: (i) => i.id,
                      labelOf: (i) => i.name,
                      value: instrumentId,
                      onChanged: (value) => instrumentId = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    MoneyAmountField(
                      controller: amountController,
                      labelText: 'Amount',
                      currency: viewModel.currency,
                      onChangedMinor: (value) => amountMinor = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    EntityPickerField<Account>(
                      labelText: 'Income category',
                      items: viewModel.incomeCategories,
                      idOf: (c) => c.id,
                      labelOf: (c) => c.name,
                      value: incomeCategoryId,
                      onChanged: (value) => incomeCategoryId = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Date ${transactionDate.toIso8601String().substring(0, 10)}',
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
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
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
                child: const Text('Record dividend'),
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
                  tooltip: 'Instrument actions',
                  onSelected: (value) {
                    if (value == 'rename') onRename();
                    if (value == 'archive') onArchive();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'archive', child: Text('Hide')),
                  ],
                ),
              ],
            ),
            Text(
              '${formatQuantityScaled(holding.quantityScaled)} units · '
              'avg ${formatAmountMinor(holding.averageCostMinor, currency)} $currency',
              style: AppTypography.body,
            ),
            Text(
              'Unrealized ${formatAmountMinor(unrealized, currency)} $currency'
              ' · ${quoteUseLabel(quoteUse)}',
              style: AppTypography.metadata,
            ),
            Text(
              'Tap the name to research. Quotes are estimates, not advice.',
              style: AppTypography.metadata,
            ),
          ],
        ),
      ),
    );
  }
}
