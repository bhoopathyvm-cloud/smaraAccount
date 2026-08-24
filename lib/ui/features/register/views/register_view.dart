import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_text_field.dart';
import '../../../core/app_typography.dart';
import '../../../core/capture_action_sheet.dart';
import '../../../core/date_formatter.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
import '../../../core/money_formatter.dart';
import '../../../core/status_banner.dart';
import '../view_models/register_row.dart';
import '../view_models/register_view_model.dart';
import 'register_row_tile.dart';

/// Views are lean. No business logic, no Repository calls. Listen to the
/// ViewModel; render what it exposes (smara-tech-guidelines.md).
class RegisterView extends StatelessWidget {
  const RegisterView({
    super.key,
    required this.viewModel,
    this.onSpent,
    this.onReceived,
    this.onTransfer,
    this.onImport,
    this.onFixEntry,
    this.onPayCard,
  });

  final RegisterViewModel viewModel;

  /// home-hub-capture: the register's three former separate FABs
  /// (import/transfer/add) consolidate into one Add action opening the
  /// same Spent/Received/Moved money/Import choice Home's Add offers,
  /// with the currently-viewed account pre-selected by the caller.
  final VoidCallback? onSpent;
  final VoidCallback? onReceived;
  final VoidCallback? onTransfer;
  final VoidCallback? onImport;

  /// fix-this-correction-wizard: called with a fixable row when the user
  /// taps it. Rows [RegisterViewModel.isRowFixable] rejects render with no
  /// tap target at all.
  final ValueChanged<RegisterRow>? onFixEntry;

  /// credit-card-household-flow: shown only when
  /// [RegisterViewModel.isSelectedAccountCreditCard] - a labeled shortcut
  /// into the existing transfer flow, bank source, this card as
  /// destination.
  final VoidCallback? onPayCard;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            tooltip: l10n.actionExportCsv,
            icon: const Icon(TablerIcons.fileExport),
            onPressed: () => _exportCsv(context, viewModel),
          ),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => FloatingActionButton.extended(
          heroTag: 'register-add-fab',
          onPressed: viewModel.isSelectedAccountArchived
              ? null
              : () => showCaptureActionSheet(
                  context: context,
                  onSpent: onSpent ?? () {},
                  onReceived: onReceived ?? () {},
                  onTransfer: onTransfer ?? () {},
                  onImport: onImport ?? () {},
                ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.cardBackground,
          icon: const Icon(TablerIcons.plus),
          label: Text(l10n.actionAdd),
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final l10n = l10nOf(context);
          return Column(
            children: [
              if (viewModel.errorMessageFor(l10n) != null)
                StatusBanner(
                  message: viewModel.errorMessageFor(l10n)!,
                  isError: true,
                  onDismiss: viewModel.clearError,
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: EntityPickerField<Account>(
                  labelText: l10n.account,
                  items: viewModel.accounts,
                  idOf: (account) => account.id,
                  labelOf: (account) => account.archived
                      ? l10n.nameHidden(localizeStoredName(l10n, account.name))
                      : localizeStoredName(l10n, account.name),
                  value: viewModel.selectedAccountId,
                  onChanged: (accountId) {
                    if (accountId != null) viewModel.selectAccount(accountId);
                  },
                ),
              ),
              _RegisterSearchBar(viewModel: viewModel),
              if (viewModel.canCloseoutSelectedAccount)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                  ),
                  child: OutlinedButton(
                    onPressed: () => _showCloseoutDialog(context, viewModel),
                    child: Text(l10n.transferRemainingBalance),
                  ),
                ),
              if (viewModel.isSelectedAccountCreditCard &&
                  !viewModel.isSelectedAccountArchived)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                  ),
                  child: OutlinedButton(
                    onPressed: onPayCard,
                    child: Text(l10n.actionPayCard),
                  ),
                ),
              Expanded(
                child: viewModel.rows.isEmpty
                    ? Center(
                        child: Text(
                          l10n.registerNoTransactions,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: viewModel.rows.length,
                        itemBuilder: (context, index) {
                          final row = viewModel.rows[index];
                          final isFixable = viewModel.isRowFixable(row);
                          return RegisterRowTile(
                            row: row,
                            onTap: isFixable
                                ? () => onFixEntry?.call(row)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ledger-data-export: picks a date range, exports the selected
  /// account's transactions to CSV, then lets the user choose where to
  /// save the file. Never touches signing-key material - the exported
  /// data is exactly the same date/description/category/amount data the
  /// Register itself already shows.
  Future<void> _exportCsv(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    final l10n = l10nOf(context);
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
    );
    if (range == null) return;

    final csv = await viewModel.exportCsv(start: range.start, end: range.end);
    if (csv == null) return;

    String? accountName;
    for (final account in viewModel.accounts) {
      if (account.id == viewModel.selectedAccountId) {
        accountName = account.name;
        break;
      }
    }
    final fileName =
        '${accountName ?? 'register'}-'
        '${_isoDate(range.start)}-to-${_isoDate(range.end)}.csv';
    await FilePicker.saveFile(
      dialogTitle: l10n.saveCsvExport,
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(csv)),
    );
  }

  String _isoDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Controllers are intentionally not disposed after [showDialog] returns:
  /// the dialog route's exit animation still rebuilds its TextFields.
  Future<void> _showCloseoutDialog(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    final descriptionController = TextEditingController();
    final destinationAmountController = TextEditingController();
    String? toAccountId = viewModel.closeoutDestinationCandidates.isEmpty
        ? null
        : viewModel.closeoutDestinationCandidates.first.id;
    var transactionDate = DateTime.now();
    int? destinationAmountMinor;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isCrossCurrency = viewModel.isCloseoutCrossCurrency(
            toAccountId,
          );
          final sourceCurrency = viewModel.currencyFor(
            viewModel.selectedAccountId,
          );
          final destCurrency = viewModel.currencyFor(toAccountId);
          return AlertDialog(
            title: Text(l10nOf(context).transferRemainingBalance),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EntityPickerField<Account>(
                    labelText: l10nOf(context).toAccount,
                    items: viewModel.closeoutDestinationCandidates,
                    idOf: (account) => account.id,
                    labelOf: (account) =>
                        localizeStoredName(l10nOf(context), account.name),
                    value: toAccountId,
                    onChanged: (accountId) {
                      setDialogState(() {
                        toAccountId = accountId;
                        destinationAmountMinor = null;
                        destinationAmountController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    '${l10nOf(context).amount}: ${formatAmountMinor(viewModel.selectedAccountBalanceMinor, sourceCurrency ?? 'USD')}'
                    '${sourceCurrency == null ? '' : ' $sourceCurrency'}',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (isCrossCurrency)
                    MoneyAmountField(
                      controller: destinationAmountController,
                      labelText: l10nOf(context).destinationAmount,
                      currency: destCurrency!,
                      suffixText: destCurrency,
                      onChangedMinor: (value) {
                        setDialogState(() => destinationAmountMinor = value);
                      },
                    ),
                  if (isCrossCurrency)
                    const SizedBox(height: AppSpacing.medium),
                  AppTextField(
                    controller: descriptionController,
                    labelText: l10nOf(context).descriptionOptional,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextButton(
                    onPressed: () async {
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
                    child: Text(
                      '${l10nOf(context).dateLabel}: '
                      '${formatLocalDate(context, transactionDate)}',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10nOf(context).actionCancel),
              ),
              ElevatedButton(
                onPressed: toAccountId == null
                    ? null
                    : () async {
                        final description = descriptionController.text.trim();
                        final ok = await viewModel.closeoutSelectedAccount(
                          toAccountId: toAccountId!,
                          transactionDate: transactionDate,
                          description: description.isEmpty ? null : description,
                          destinationAmountMinor: isCrossCurrency
                              ? destinationAmountMinor
                              : null,
                        );
                        if (ok && dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                child: Text(l10nOf(context).actionTransfer),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// register-search: text search plus optional, combinable date-range and
/// direction filters over the register's already-loaded rows (design.md
/// Decision 1 - client-side, no new repository query). A small
/// StatefulWidget only to own the search field's [TextEditingController]
/// so the cursor position survives rebuilds triggered by the view model's
/// own `notifyListeners` (mirrors [MoneyAmountField]'s precedent).
class _RegisterSearchBar extends StatefulWidget {
  const _RegisterSearchBar({required this.viewModel});

  final RegisterViewModel viewModel;

  @override
  State<_RegisterSearchBar> createState() => _RegisterSearchBarState();
}

class _RegisterSearchBarState extends State<_RegisterSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.viewModel.searchText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange:
          widget.viewModel.filterStartDate != null &&
              widget.viewModel.filterEndDate != null
          ? DateTimeRange(
              start: widget.viewModel.filterStartDate!,
              end: widget.viewModel.filterEndDate!,
            )
          : DateTimeRange(start: now, end: now),
    );
    if (picked != null) {
      widget.viewModel.setDateRangeFilter(start: picked.start, end: picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final viewModel = widget.viewModel;
        final l10n = l10nOf(context);
        final hasDateRange =
            viewModel.filterStartDate != null &&
            viewModel.filterEndDate != null;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.large,
          ).copyWith(bottom: AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: l10n.searchLabel,
                  hintText: l10n.registerSearchHint,
                  prefixIcon: const Icon(TablerIcons.search),
                  suffixIcon: viewModel.hasActiveSearchOrFilters
                      ? IconButton(
                          icon: const Icon(TablerIcons.x),
                          tooltip: l10n.actionClearSearch,
                          onPressed: () {
                            _controller.clear();
                            viewModel.clearSearchAndFilters();
                          },
                        )
                      : null,
                ),
                onChanged: viewModel.setSearchText,
              ),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                children: [
                  ChoiceChip(
                    label: Text(l10n.registerAll),
                    selected: viewModel.filterDirection == null,
                    onSelected: (_) => viewModel.setDirectionFilter(null),
                  ),
                  ChoiceChip(
                    label: Text(l10n.registerSpentOnly),
                    selected:
                        viewModel.filterDirection ==
                        TransactionDirection.moneyOut,
                    onSelected: (_) => viewModel.setDirectionFilter(
                      TransactionDirection.moneyOut,
                    ),
                  ),
                  ChoiceChip(
                    label: Text(l10n.registerReceivedOnly),
                    selected:
                        viewModel.filterDirection ==
                        TransactionDirection.moneyIn,
                    onSelected: (_) => viewModel.setDirectionFilter(
                      TransactionDirection.moneyIn,
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(TablerIcons.calendar, size: 16),
                    label: Text(
                      hasDateRange
                          ? '${formatLocalDate(context, viewModel.filterStartDate!)} – '
                                '${formatLocalDate(context, viewModel.filterEndDate!)}'
                          : l10n.dateRangeLabel,
                    ),
                    onPressed: () => _pickDateRange(context),
                  ),
                  if (hasDateRange)
                    ActionChip(
                      avatar: const Icon(TablerIcons.x, size: 16),
                      label: Text(l10n.actionClearDates),
                      onPressed: () => viewModel.setDateRangeFilter(),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
