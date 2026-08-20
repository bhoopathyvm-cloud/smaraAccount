import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
import '../../../../domain/models/recurring_template.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
import '../../../core/money_formatter.dart';
import '../view_models/recurring_template_management_view_model.dart';

/// Add/edit/delete recurring templates (recurring-templates tasks.md
/// 11.2). Recording a *due* template happens from Home, not here - this
/// screen only manages the templates themselves.
class RecurringTemplateManagementView extends StatelessWidget {
  const RecurringTemplateManagementView({super.key, required this.viewModel});

  final RecurringTemplateManagementViewModel viewModel;

  Future<void> _confirmDelete(
    BuildContext context,
    RecurringTemplate template,
  ) async {
    final l10n = l10nOf(context);
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.deleteTemplateTitle,
      message: l10n.deleteTemplateBody(template.name),
      confirmLabel: l10n.actionDelete,
    );
    if (confirmed) await viewModel.deleteTemplate(template.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recurringTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'recurring-templates-fab',
        onPressed: () => _showTemplateDialog(context, viewModel),
        backgroundColor: AppColors.primary,
        child: const Icon(TablerIcons.plus, color: AppColors.cardBackground),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.templates.isEmpty) {
            return Center(
              child: Text(
                l10n.noRecurringYet,
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
            );
          }
          return ListView.builder(
            itemCount: viewModel.templates.length,
            itemBuilder: (context, index) {
              final template = viewModel.templates[index];
              final currency = viewModel.currencyFor(
                template.financialAccountId,
              );
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                  vertical: AppSpacing.small,
                ),
                child: ListTile(
                  leading: Icon(
                    template.direction == TransactionDirection.moneyIn
                        ? TablerIcons.arrowDown
                        : TablerIcons.arrowUp,
                    color: AppColors.textPrimary,
                  ),
                  title: Text(template.name, style: AppTypography.cardTitle),
                  subtitle: Text(
                    '${l10n.dayOfMonthLine('${template.dayOfMonth}')}'
                    '${formatAmountMinor(template.amountMinor, currency ?? 'USD')}'
                    '${currency == null ? '' : ' $currency'}',
                    style: AppTypography.metadata,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(TablerIcons.pencil),
                        color: AppColors.textSecondary,
                        onPressed: () =>
                            _showTemplateDialog(context, viewModel, template),
                      ),
                      IconButton(
                        icon: const Icon(TablerIcons.trash),
                        color: AppColors.signal,
                        onPressed: () => _confirmDelete(context, template),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Controllers are intentionally not disposed after [showDialog]
  /// returns: the dialog route's exit animation still rebuilds its
  /// TextFields (same reasoning as account_management_view.dart's dialogs).
  Future<void> _showTemplateDialog(
    BuildContext context,
    RecurringTemplateManagementViewModel viewModel, [
    RecurringTemplate? existing,
  ]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final amountController = TextEditingController();
    final dayController = TextEditingController(
      text: existing == null ? '' : existing.dayOfMonth.toString(),
    );
    var direction = existing?.direction ?? TransactionDirection.moneyOut;
    String? financialAccountId =
        existing?.financialAccountId ??
        (viewModel.financialAccounts.isEmpty
            ? null
            : viewModel.financialAccounts.first.id);
    String? categoryId = existing?.categoryId;
    var errorMessage = viewModel.errorMessage;
    var initialAmountSet = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = l10nOf(context);
          final currency = viewModel.currencyFor(financialAccountId) ?? 'USD';
          if (!initialAmountSet && existing != null) {
            initialAmountSet = true;
            amountController.text = formatAmountMinor(
              existing.amountMinor,
              currency,
            );
          }
          return AlertDialog(
            title: Text(
              existing == null ? l10n.addTemplate : l10n.editTemplate,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: l10n.name),
                  ),
                  const SizedBox(height: AppSpacing.medium),
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
                    selected: {direction},
                    onSelectionChanged: (selection) {
                      setDialogState(() {
                        direction = selection.first;
                        categoryId = null;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  EntityPickerField<Account>(
                    labelText: l10n.account,
                    items: viewModel.financialAccounts,
                    idOf: (account) => account.id,
                    labelOf: (account) =>
                        localizeStoredName(l10n, account.name),
                    value: financialAccountId,
                    onChanged: (value) =>
                        setDialogState(() => financialAccountId = value),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  EntityPickerField<Account>(
                    labelText: l10n.category,
                    items: viewModel.categoriesFor(direction),
                    idOf: (category) => category.id,
                    labelOf: (category) =>
                        localizeStoredName(l10n, category.name),
                    value: categoryId,
                    onChanged: (value) =>
                        setDialogState(() => categoryId = value),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  MoneyAmountField(
                    controller: amountController,
                    labelText: l10n.amount,
                    currency: currency,
                    suffixText: currency,
                    onChangedMinor: (_) {},
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextField(
                    controller: dayController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.dayOfMonth,
                      helperText: l10n.dayOfMonthNote,
                      helperMaxLines: 2,
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      errorMessage!,
                      style: AppTypography.body.copyWith(
                        color: AppColors.signal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.actionCancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final accountId = financialAccountId;
                  final category = categoryId;
                  final amountMinor = parseAmountToMinor(
                    amountController.text,
                    currency,
                  );
                  final dayOfMonth = int.tryParse(dayController.text.trim());
                  if (name.isEmpty ||
                      accountId == null ||
                      category == null ||
                      amountMinor == null ||
                      dayOfMonth == null) {
                    setDialogState(
                      () => errorMessage = l10n.validationFillTemplateFields,
                    );
                    return;
                  }
                  final ok = existing == null
                      ? await viewModel.createTemplate(
                          name: name,
                          direction: direction,
                          financialAccountId: accountId,
                          categoryId: category,
                          amountMinor: amountMinor,
                          dayOfMonth: dayOfMonth,
                        )
                      : await viewModel.updateTemplate(
                          id: existing.id,
                          name: name,
                          direction: direction,
                          financialAccountId: accountId,
                          categoryId: category,
                          amountMinor: amountMinor,
                          dayOfMonth: dayOfMonth,
                        );
                  if (ok && dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  } else {
                    setDialogState(() => errorMessage = viewModel.errorMessage);
                  }
                },
                child: Text(
                  existing == null ? l10n.actionAdd : l10n.actionSave,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
