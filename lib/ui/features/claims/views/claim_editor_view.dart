import 'package:flutter/material.dart';

import '../../../../domain/claims/claim_receipt_picker.dart';
import '../../../../domain/models/claim_item.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_spacing.dart';
import '../../../core/money_formatter.dart';
import '../../../core/system_inset_padding.dart';
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
            padding: scrollPaddingAvoidingSystemInsets(context),
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
    var categoryId = existing?.categoryId ?? categories.first.id;
    final amountController = TextEditingController(
      text: existing == null
          ? ''
          : formatAmountMinor(existing.paidAmountMinor, existing.paidCurrency),
    );
    final companyAmountController = TextEditingController(
      text: existing == null
          ? ''
          : formatAmountMinor(
              existing.companyCurrencyAmountMinor,
              viewModel.companyCurrency,
            ),
    );
    final currencyController = TextEditingController(
      text: existing?.paidCurrency ?? viewModel.companyCurrency,
    );
    final rateController = TextEditingController(
      text: existing?.employeeStatedRate?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    var expenseDate = existing?.expenseDate ?? DateTime.now();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final hint = viewModel.spendingHintFor(categoryId);
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.large,
                  right: AppSpacing.large,
                  top: AppSpacing.large,
                  bottom:
                      MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.large,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        existing == null
                            ? l10n.claimsAddItem
                            : l10n.claimsEditItem,
                        style: Theme.of(ctx).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      DropdownButtonFormField<String>(
                        initialValue: categoryId,
                        decoration: InputDecoration(
                          labelText: l10n.claimsCategoryLabel,
                        ),
                        items: [
                          for (final c in categories)
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setLocal(() => categoryId = v);
                        },
                      ),
                      if (hint != null) ...[
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          l10n.claimsSpendingHint(
                            formatAmountMinor(
                              hint.maxAmountMinor,
                              viewModel.companyCurrency,
                            ),
                            hint.unitLabel,
                          ),
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                      ],
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.claimsExpenseDateLabel),
                        subtitle: Text(
                          '${expenseDate.year}-'
                          '${expenseDate.month.toString().padLeft(2, '0')}-'
                          '${expenseDate.day.toString().padLeft(2, '0')}',
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: expenseDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setLocal(() => expenseDate = picked);
                          }
                        },
                      ),
                      TextField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: l10n.claimsPaidAmountLabel,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      TextField(
                        controller: currencyController,
                        decoration: InputDecoration(
                          labelText: l10n.claimsPaidCurrencyLabel,
                        ),
                      ),
                      TextField(
                        controller: rateController,
                        decoration: InputDecoration(
                          labelText: l10n.claimsRateOptionalLabel,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      TextField(
                        controller: companyAmountController,
                        decoration: InputDecoration(
                          labelText: l10n.claimsCompanyAmountLabel(
                            viewModel.companyCurrency,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.claimsDescriptionLabel,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      ElevatedButton(
                        onPressed: () {
                          final paidCurrency = currencyController.text.trim();
                          final paid = parseAmountToMinor(
                            amountController.text,
                            paidCurrency.isEmpty
                                ? viewModel.companyCurrency
                                : paidCurrency,
                          );
                          final company = parseAmountToMinor(
                            companyAmountController.text,
                            viewModel.companyCurrency,
                          );
                          if (paid == null ||
                              company == null ||
                              paid <= 0 ||
                              company <= 0) {
                            return;
                          }
                          final rateText = rateController.text.trim();
                          final rate = rateText.isEmpty
                              ? null
                              : double.tryParse(rateText);
                          final desc = descriptionController.text.trim();
                          Navigator.pop(ctx, true);
                          if (existing == null) {
                            viewModel.addItem(
                              categoryId: categoryId,
                              expenseDate: expenseDate,
                              paidCurrency: paidCurrency.isEmpty
                                  ? viewModel.companyCurrency
                                  : paidCurrency,
                              paidAmountMinor: paid,
                              companyCurrencyAmountMinor: company,
                              description: desc.isEmpty ? null : desc,
                              employeeStatedRate: rate,
                            );
                          } else {
                            viewModel.updateItem(
                              claimItemId: existing.id,
                              categoryId: categoryId,
                              expenseDate: expenseDate,
                              paidCurrency: paidCurrency.isEmpty
                                  ? viewModel.companyCurrency
                                  : paidCurrency,
                              paidAmountMinor: paid,
                              companyCurrencyAmountMinor: company,
                              description: desc.isEmpty ? null : desc,
                              clearDescription: desc.isEmpty,
                              employeeStatedRate: rate,
                              clearEmployeeStatedRate: rate == null,
                            );
                          }
                        },
                        child: Text(l10n.actionSave),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    amountController.dispose();
    companyAmountController.dispose();
    currencyController.dispose();
    rateController.dispose();
    descriptionController.dispose();
    // ignore unused; sheet returns whether save was pressed
    saved;
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
