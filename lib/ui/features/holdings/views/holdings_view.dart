import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../data/instrument_quote_service.dart';
import '../../../../domain/investment/exchange_registry.dart';
import '../../../../domain/investment/instrument_currency_inference.dart';
import '../../../../domain/investment/investment_holdings.dart';
import '../../../../domain/investment/isin.dart';
import '../../../../domain/investment/trade_order_draft.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/instrument.dart';
import '../../../../domain/models/instrument_holding.dart';
import '../../../../domain/models/instrument_quote.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_text_field.dart';
import '../../../core/app_typography.dart';
import '../../../core/date_formatter.dart';
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
    final result = await viewModel.researchInstrument(
      l10nOf(context),
      instrument,
    );
    if (!context.mounted) return;
    final l10n = l10nOf(context);
    final message = result == ResearchLaunchResult.copied
        ? l10n.copiedResearchPrompt
        : l10n.openedFavouriteResearchTool;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _lookUpIdentifiers(BuildContext context, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final l10n = l10nOf(context);
    final result = await viewModel.lookUpIdentifiers(l10n, trimmed);
    if (!context.mounted) return;
    final message = result == ResearchLaunchResult.copied
        ? l10n.instrumentLookUpCopied
        : l10n.instrumentLookUpOpened;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// The currency-mismatch warning to show under the ISIN field, or null
  /// when nothing is typed yet or the inferred currency matches the account
  /// (instrument-identifier-assist Decision 2). Points at the account
  /// currency's listing suffix when one exists.
  String? _currencyMismatchWarning(
    AppLocalizations l10n, {
    required String ticker,
    required String isin,
    required String accountCurrency,
    required Exchange defaultExchange,
  }) {
    if (ticker.trim().isEmpty && isin.trim().isEmpty) return null;
    final inferred = inferTradingCurrency(
      isin: isin,
      ticker: ticker,
      defaultExchange: defaultExchange,
    );
    if (inferred == accountCurrency) return null;
    final suffix = suffixHintForCurrency(accountCurrency);
    if (suffix != null) {
      return l10n.instrumentCurrencyMismatchWithHint(
        inferred,
        accountCurrency,
        suffix,
      );
    }
    return l10n.instrumentCurrencyMismatch(inferred, accountCurrency);
  }

  /// Searches for the typed identifier and, when it resolves, has the user
  /// confirm a listing before storing the canonical symbol. Offline / no
  /// result / skip saves with the typed values and defers resolution to the
  /// next refresh (Decision 4). Returns the created instrument, or null when
  /// creation failed.
  Future<Instrument?> _createResolvedInstrument(
    BuildContext dialogContext,
    BuyOrderDraft draft,
  ) async {
    final l10n = l10nOf(dialogContext);
    final name = draft.newInstrumentName.trim();
    final ticker = draft.tickerOrNull;
    final isin = draft.isinOrNull;
    final query = (isin != null && isin.isNotEmpty) ? isin : ticker;

    InstrumentCandidate? chosen;
    if (query != null && query.isNotEmpty) {
      final candidates = await viewModel.searchListings(query);
      if (!dialogContext.mounted) return null;
      if (candidates.isNotEmpty) {
        chosen = await _confirmListing(
          dialogContext,
          candidates,
          viewModel.defaultExchange,
        );
        if (!dialogContext.mounted) return null;
      }
    }

    final created = await viewModel.createInstrument(
      name: name,
      kind: draft.newKind,
      ticker: ticker,
      isin: isin,
      resolvedSymbol: chosen?.symbol,
      exchange: chosen?.exchangeCode,
    );
    if (created != null &&
        chosen == null &&
        query != null &&
        query.isNotEmpty &&
        dialogContext.mounted) {
      ScaffoldMessenger.of(
        dialogContext,
      ).showSnackBar(SnackBar(content: Text(l10n.resolveDeferredSaved)));
    }
    return created;
  }

  /// A bottom sheet of candidate listings (name · exchange · currency),
  /// pre-selecting the default-exchange match. Returns the confirmed
  /// candidate, or null when the user skips / dismisses (save as typed).
  Future<InstrumentCandidate?> _confirmListing(
    BuildContext context,
    List<InstrumentCandidate> candidates,
    Exchange defaultExchange,
  ) {
    var selected = candidates.firstWhere(
      (c) => c.exchangeCode == defaultExchange.code,
      orElse: () => candidates.first,
    );
    return showModalBottomSheet<InstrumentCandidate?>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final l10n = l10nOf(sheetContext);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.confirmListingTitle,
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      l10n.confirmListingBlurb,
                      style: AppTypography.metadata,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Flexible(
                      child: SingleChildScrollView(
                        child: RadioGroup<InstrumentCandidate>(
                          groupValue: selected,
                          onChanged: (value) {
                            if (value != null) {
                              setSheetState(() => selected = value);
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final candidate in candidates)
                                RadioListTile<InstrumentCandidate>(
                                  value: candidate,
                                  title: Text(
                                    '${candidate.name} · ${candidate.symbol}',
                                  ),
                                  subtitle: Text(
                                    l10n.confirmListingCurrencyLine(
                                      candidate.exchangeDisplay,
                                      candidate.currency,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    ElevatedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(selected),
                      child: Text(l10n.actionConfirm),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(l10n.confirmListingSkip),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        content: AppTextField(controller: controller, autofocus: true),
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
    final draft = viewModel.newBuyDraft();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final brokerageController = TextEditingController();
    final descriptionController = TextEditingController();
    final newNameController = TextEditingController();
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
                      selected: {draft.funding},
                      onSelectionChanged: (selection) =>
                          setDialogState(() => draft.funding = selection.first),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    if (!draft.creatingNew) ...[
                      EntityPickerField<Instrument>(
                        labelText: l10n.instrument,
                        items: viewModel.instruments
                            .where((i) => !i.archived)
                            .toList(),
                        idOf: (i) => i.id,
                        labelOf: (i) => i.name,
                        value: draft.instrumentId,
                        onChanged: (value) => draft.instrumentId = value,
                      ),
                      TextButton(
                        onPressed: () =>
                            setDialogState(() => draft.creatingNew = true),
                        child: Text(l10n.newInstrument),
                      ),
                    ] else ...[
                      AppTextField(
                        controller: newNameController,
                        labelText: l10n.name,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(TablerIcons.search, size: 18),
                          label: Text(l10n.instrumentLookUp),
                          onPressed: () => _lookUpIdentifiers(
                            context,
                            newNameController.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      DropdownButtonFormField<InstrumentKind>(
                        initialValue: draft.newKind,
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
                            setDialogState(() => draft.newKind = kind);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextField(
                        controller: tickerController,
                        decoration: InputDecoration(
                          labelText: l10n.tickerOptional,
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextField(
                        controller: isinController,
                        decoration: InputDecoration(
                          labelText: l10n.isinOptional,
                          errorText:
                              validateIsin(isinController.text) ==
                                  IsinCheck.malformed
                              ? l10n.isinInvalid
                              : null,
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      if (validateIsin(isinController.text) ==
                          IsinCheck.badCheckDigit)
                        _DialogWarning(message: l10n.isinCheckDigitWarning),
                      Builder(
                        builder: (context) {
                          final warning = _currencyMismatchWarning(
                            l10n,
                            ticker: tickerController.text,
                            isin: isinController.text,
                            accountCurrency: currency,
                            defaultExchange: viewModel.defaultExchange,
                          );
                          if (warning == null) return const SizedBox.shrink();
                          return _DialogWarning(message: warning);
                        },
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
                          draft.quantityScaled = parseQuantityScaled(text),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    MoneyAmountField(
                      controller: priceController,
                      labelText: l10n.unitPrice,
                      currency: currency,
                      onChangedMinor: (value) => draft.unitPriceMinor = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${l10n.dateLabel} ${formatLocalDate(context, draft.transactionDate)}',
                      ),
                      trailing: const Icon(TablerIcons.calendar),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: draft.transactionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => draft.transactionDate = picked);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        draft.lockedUntil == null
                            ? l10n.lockUntilOptional
                            : l10n.lockedUntilDate(
                                formatLocalDate(context, draft.lockedUntil!),
                              ),
                      ),
                      subtitle: Text(l10n.lockUntilHint),
                      trailing: const Icon(TablerIcons.lock),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              draft.lockedUntil ?? draft.transactionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => draft.lockedUntil = picked);
                        }
                      },
                    ),
                    if (draft.requiresIncomeCategory)
                      EntityPickerField<Account>(
                        labelText: l10n.incomeCategory,
                        items: viewModel.incomeCategories,
                        idOf: (c) => c.id,
                        labelOf: (c) => localizeStoredName(l10n, c.name),
                        value: draft.incomeCategoryId,
                        onChanged: (value) => draft.incomeCategoryId = value,
                      ),
                    if (draft.requiresBrokerageCategory) ...[
                      MoneyAmountField(
                        controller: brokerageController,
                        labelText: l10n.brokerageOptional,
                        currency: currency,
                        onChangedMinor: (value) => draft.brokerageMinor = value,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      EntityPickerField<Account>(
                        labelText: l10n.brokerageExpenseCategory,
                        items: viewModel.expenseCategories,
                        idOf: (c) => c.id,
                        labelOf: (c) => localizeStoredName(l10n, c.name),
                        value: draft.brokerageCategoryId,
                        onChanged: (value) => draft.brokerageCategoryId = value,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.medium),
                    AppTextField(
                      controller: descriptionController,
                      labelText: l10n.descriptionOptional,
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
                  draft.newInstrumentName = newNameController.text;
                  draft.ticker = tickerController.text;
                  draft.isin = isinController.text;
                  draft.description = descriptionController.text;
                  if (draft.creatingNew) {
                    if (!draft.canSubmit) return;
                    // A provably-malformed ISIN blocks save (a bad check
                    // digit only warns, above) — Decision 2.
                    if (validateIsin(draft.isinOrNull) == IsinCheck.malformed) {
                      return;
                    }
                    final created = await _createResolvedInstrument(
                      dialogContext,
                      draft,
                    );
                    if (created == null) return;
                    draft.instrumentId = created.id;
                  }
                  if (!draft.canSubmit) return;
                  final ok = await viewModel.submitBuy(draft);
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
    final draft = viewModel.newSellDraft();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final brokerageController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final currency = viewModel.currency;
          final gainLoss = draft.gainLossMinor;
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
                      value: draft.holding.instrument.id,
                      onChanged: (id) {
                        final next = viewModel.holdings
                            .where((h) => h.instrument.id == id)
                            .firstOrNull;
                        if (next != null) {
                          setDialogState(() => draft.holding = next);
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
                        () => draft.quantityScaled = parseQuantityScaled(text),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    MoneyAmountField(
                      controller: priceController,
                      labelText: l10n.unitPrice,
                      currency: currency,
                      onChangedMinor: (value) =>
                          setDialogState(() => draft.unitPriceMinor = value),
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
                      if (draft.requiresIncomeCategory)
                        EntityPickerField<Account>(
                          labelText: l10n.gainIncomeCategory,
                          items: viewModel.incomeCategories,
                          idOf: (c) => c.id,
                          labelOf: (c) => localizeStoredName(l10n, c.name),
                          value: draft.gainIncomeCategoryId,
                          onChanged: (value) =>
                              draft.gainIncomeCategoryId = value,
                        ),
                      if (draft.requiresExpenseCategory)
                        EntityPickerField<Account>(
                          labelText: l10n.lossExpenseCategory,
                          items: viewModel.expenseCategories,
                          idOf: (c) => c.id,
                          labelOf: (c) => localizeStoredName(l10n, c.name),
                          value: draft.lossExpenseCategoryId,
                          onChanged: (value) =>
                              draft.lossExpenseCategoryId = value,
                        ),
                    ],
                    const SizedBox(height: AppSpacing.medium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${l10n.dateLabel} ${formatLocalDate(context, draft.transactionDate)}',
                      ),
                      trailing: const Icon(TablerIcons.calendar),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: draft.transactionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => draft.transactionDate = picked);
                        }
                      },
                    ),
                    MoneyAmountField(
                      controller: brokerageController,
                      labelText: l10n.brokerageOptional,
                      currency: currency,
                      onChangedMinor: (value) => draft.brokerageMinor = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    EntityPickerField<Account>(
                      labelText: l10n.brokerageExpenseCategory,
                      items: viewModel.expenseCategories,
                      idOf: (c) => c.id,
                      labelOf: (c) => localizeStoredName(l10n, c.name),
                      value: draft.brokerageCategoryId,
                      onChanged: (value) => draft.brokerageCategoryId = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    AppTextField(
                      controller: descriptionController,
                      labelText: l10n.descriptionOptional,
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
                  draft.description = descriptionController.text;
                  if (!draft.canSubmit) return;
                  final ok = await viewModel.submitSell(draft);
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
    if (viewModel.heldInstruments.isEmpty) return;
    final draft = viewModel.newDividendDraft();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

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
                      items: draft.eligibleInstruments,
                      idOf: (i) => i.id,
                      labelOf: (i) => i.name,
                      value: draft.instrumentId,
                      onChanged: (value) => draft.instrumentId = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    MoneyAmountField(
                      controller: amountController,
                      labelText: l10n.amount,
                      currency: viewModel.currency,
                      onChangedMinor: (value) => draft.amountMinor = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    EntityPickerField<Account>(
                      labelText: l10n.incomeCategory,
                      items: viewModel.incomeCategories,
                      idOf: (c) => c.id,
                      labelOf: (c) => localizeStoredName(l10n, c.name),
                      value: draft.incomeCategoryId,
                      onChanged: (value) => draft.incomeCategoryId = value,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${l10n.dateLabel} ${formatLocalDate(context, draft.transactionDate)}',
                      ),
                      trailing: const Icon(TablerIcons.calendar),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: draft.transactionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => draft.transactionDate = picked);
                        }
                      },
                    ),
                    AppTextField(
                      controller: descriptionController,
                      labelText: l10n.descriptionOptional,
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
                  draft.description = descriptionController.text;
                  if (!draft.canSubmit) return;
                  final ok = await viewModel.submitDividend(draft);
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

/// An inline, non-blocking caution line under the identifier fields (ISIN
/// check-digit / currency-mismatch warnings).
class _DialogWarning extends StatelessWidget {
  const _DialogWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            TablerIcons.alertTriangle,
            size: 16,
            color: AppColors.signal,
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              message,
              style: AppTypography.metadata.copyWith(color: AppColors.signal),
            ),
          ),
        ],
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
