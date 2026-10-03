import 'package:flutter/material.dart';

import '../../../../domain/claims/claim_receipt_picker.dart';
import '../../../../domain/models/claim_item.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_spacing.dart';
import '../../../core/money_formatter.dart';
import '../view_models/claim_editor_view_model.dart';
import '../view_models/claims_list_view_model.dart';

/// Claimant draft editor: items, receipts, submit with receipt-required and
/// spending-limit hints (show only, never block).
class ClaimEditorView extends StatelessWidget {
  const ClaimEditorView({super.key, required this.viewModel, this.onSubmitted});

  final ClaimEditorViewModel viewModel;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.loading) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.claimsEditorTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (viewModel.showingReceiptPermissionExplanation) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.claimsEditorTitle)),
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.claimsReceiptPermissionSentence),
                  const SizedBox(height: AppSpacing.large),
                  ElevatedButton(
                    onPressed:
                        viewModel.continueAfterReceiptPermissionExplanation,
                    child: Text(l10n.actionContinue),
                  ),
                  TextButton(
                    onPressed: viewModel.cancelReceiptPermissionExplanation,
                    child: Text(l10n.actionCancel),
                  ),
                ],
              ),
            ),
          );
        }
        final claim = viewModel.claim;
        final status = claim == null
            ? ''
            : ClaimsListViewModel.statusLabel(claim.status, l10n);
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.claimsEditorTitle),
            actions: [
              if (viewModel.isDraft)
                TextButton(
                  onPressed: viewModel.busy
                      ? null
                      : () async {
                          final ok = await viewModel.submit();
                          if (ok && context.mounted) {
                            onSubmitted?.call();
                          }
                        },
                  child: Text(l10n.claimsSubmit),
                ),
            ],
          ),
          floatingActionButton: viewModel.isDraft
              ? FloatingActionButton(
                  onPressed: viewModel.busy
                      ? null
                      : () => _openItemSheet(context),
                  child: const Icon(Icons.add),
                )
              : null,
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              Text(status, style: Theme.of(context).textTheme.titleMedium),
              if (viewModel.error != null) ...[
                const SizedBox(height: AppSpacing.base),
                Text(
                  viewModel.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: AppSpacing.medium),
              if (claim == null || claim.items.isEmpty)
                Text(l10n.claimsNoItemsYet)
              else
                ...claim.items.map(
                  (item) => _ItemTile(
                    item: item,
                    viewModel: viewModel,
                    onEdit: viewModel.isDraft
                        ? () => _openItemSheet(context, existing: item)
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openItemSheet(
    BuildContext context, {
    ClaimItem? existing,
  }) async {
    final l10n = l10nOf(context);
    final categories = viewModel.allowlistedCategories;
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.claimsNoAllowlistedCategories)),
      );
      return;
    }
    // Controllers live on [_ClaimItemSheet] State so they survive the
    // bottom-sheet exit animation (disposing when showModalBottomSheet's
    // future completes races the still-mounted route).
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ClaimItemSheet(
        viewModel: viewModel,
        categories: categories,
        existing: existing,
      ),
    );
  }
}

/// Owns TextEditingControllers for the add/edit-item sheet.
class _ClaimItemSheet extends StatefulWidget {
  const _ClaimItemSheet({
    required this.viewModel,
    required this.categories,
    this.existing,
  });

  final ClaimEditorViewModel viewModel;
  final List<({String id, String name})> categories;
  final ClaimItem? existing;

  @override
  State<_ClaimItemSheet> createState() => _ClaimItemSheetState();
}

class _ClaimItemSheetState extends State<_ClaimItemSheet> {
  late String _categoryId;
  late DateTime _expenseDate;
  late final TextEditingController _amountController;
  late final TextEditingController _companyAmountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _rateController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final vm = widget.viewModel;
    _categoryId = existing?.categoryId ?? widget.categories.first.id;
    _expenseDate = existing?.expenseDate ?? DateTime.now();
    _amountController = TextEditingController(
      text: existing == null
          ? ''
          : formatAmountMinor(existing.paidAmountMinor, existing.paidCurrency),
    );
    _companyAmountController = TextEditingController(
      text: existing == null
          ? ''
          : formatAmountMinor(
              existing.companyCurrencyAmountMinor,
              vm.companyCurrency,
            ),
    );
    _currencyController = TextEditingController(
      text: existing?.paidCurrency ?? vm.companyCurrency,
    );
    _rateController = TextEditingController(
      text: existing?.employeeStatedRate?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _companyAmountController.dispose();
    _currencyController.dispose();
    _rateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final vm = widget.viewModel;
    final existing = widget.existing;
    final paidCurrency = _currencyController.text.trim();
    final paid = parseAmountToMinor(
      _amountController.text,
      paidCurrency.isEmpty ? vm.companyCurrency : paidCurrency,
    );
    final company = parseAmountToMinor(
      _companyAmountController.text,
      vm.companyCurrency,
    );
    if (paid == null || company == null || paid <= 0 || company <= 0) {
      return;
    }
    final rateText = _rateController.text.trim();
    final rate = rateText.isEmpty ? null : double.tryParse(rateText);
    final desc = _descriptionController.text.trim();
    Navigator.pop(context);
    if (existing == null) {
      vm.addItem(
        categoryId: _categoryId,
        expenseDate: _expenseDate,
        paidCurrency: paidCurrency.isEmpty ? vm.companyCurrency : paidCurrency,
        paidAmountMinor: paid,
        companyCurrencyAmountMinor: company,
        description: desc.isEmpty ? null : desc,
        employeeStatedRate: rate,
      );
    } else {
      vm.updateItem(
        claimItemId: existing.id,
        categoryId: _categoryId,
        expenseDate: _expenseDate,
        paidCurrency: paidCurrency.isEmpty ? vm.companyCurrency : paidCurrency,
        paidAmountMinor: paid,
        companyCurrencyAmountMinor: company,
        description: desc.isEmpty ? null : desc,
        clearDescription: desc.isEmpty,
        employeeStatedRate: rate,
        clearEmployeeStatedRate: rate == null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final vm = widget.viewModel;
    final existing = widget.existing;
    final hint = vm.spendingHintFor(_categoryId);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.large,
          right: AppSpacing.large,
          top: AppSpacing.large,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.large,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                existing == null ? l10n.claimsAddItem : l10n.claimsEditItem,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: InputDecoration(
                  labelText: l10n.claimsCategoryLabel,
                ),
                items: [
                  for (final c in widget.categories)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _categoryId = v);
                },
              ),
              if (hint != null) ...[
                const SizedBox(height: AppSpacing.base),
                Text(
                  l10n.claimsSpendingHint(
                    formatAmountMinor(hint.maxAmountMinor, vm.companyCurrency),
                    hint.unitLabel,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.claimsExpenseDateLabel),
                subtitle: Text(
                  '${_expenseDate.year}-'
                  '${_expenseDate.month.toString().padLeft(2, '0')}-'
                  '${_expenseDate.day.toString().padLeft(2, '0')}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _expenseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _expenseDate = picked);
                  }
                },
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.claimsPaidAmountLabel,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: _currencyController,
                decoration: InputDecoration(
                  labelText: l10n.claimsPaidCurrencyLabel,
                ),
              ),
              TextField(
                controller: _rateController,
                decoration: InputDecoration(
                  labelText: l10n.claimsRateOptionalLabel,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: _companyAmountController,
                decoration: InputDecoration(
                  labelText: l10n.claimsCompanyAmountLabel(vm.companyCurrency),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.claimsDescriptionLabel,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              ElevatedButton(
                onPressed: () => _save(context),
                child: Text(l10n.actionSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.viewModel, this.onEdit});

  final ClaimItem item;
  final ClaimEditorViewModel viewModel;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final categoryName =
        viewModel.allowlistedCategories
            .where((c) => c.id == item.categoryId)
            .map((c) => c.name)
            .firstOrNull ??
        item.categoryId;
    final hint = viewModel.spendingHintFor(item.categoryId);
    final missingReceipt = viewModel.receiptMissingFor(item);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(categoryName),
              subtitle: Text(
                '${formatAmountMinor(item.paidAmountMinor, item.paidCurrency)}'
                ' ${item.paidCurrency}'
                ' → ${formatAmountMinor(item.companyCurrencyAmountMinor, viewModel.companyCurrency)}'
                ' ${viewModel.companyCurrency}',
              ),
              trailing: onEdit == null
                  ? null
                  : IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            ),
            if (item.description != null && item.description!.isNotEmpty)
              Text(item.description!),
            if (hint != null)
              Text(
                l10n.claimsSpendingHint(
                  formatAmountMinor(
                    hint.maxAmountMinor,
                    viewModel.companyCurrency,
                  ),
                  hint.unitLabel,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (missingReceipt)
              Text(
                l10n.claimsReceiptRequiredHint,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (item.receipt != null)
              Text(l10n.claimsReceiptAttached(item.receipt!.fileName)),
            if (viewModel.isDraft) ...[
              const SizedBox(height: AppSpacing.base),
              Wrap(
                spacing: AppSpacing.base,
                children: [
                  TextButton(
                    onPressed: () => viewModel.requestAttachReceipt(
                      claimItemId: item.id,
                      source: ClaimReceiptSource.camera,
                    ),
                    child: Text(l10n.claimsAttachCamera),
                  ),
                  TextButton(
                    onPressed: () => viewModel.requestAttachReceipt(
                      claimItemId: item.id,
                      source: ClaimReceiptSource.gallery,
                    ),
                    child: Text(l10n.claimsAttachGallery),
                  ),
                  TextButton(
                    onPressed: () => viewModel.requestAttachReceipt(
                      claimItemId: item.id,
                      source: ClaimReceiptSource.pdf,
                    ),
                    child: Text(l10n.claimsAttachPdf),
                  ),
                  TextButton(
                    onPressed: () => viewModel.removeItem(item.id),
                    child: Text(l10n.actionDelete),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
