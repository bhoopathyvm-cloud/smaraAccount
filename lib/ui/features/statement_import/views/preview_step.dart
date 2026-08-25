import 'package:flutter/material.dart';

import '../../../../domain/models/account.dart';
import '../../../../domain/statement_import/parsed_statement_transaction.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_text_field.dart';
import '../../../core/app_typography.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_formatter.dart';
import '../../../core/show_managed_dialog.dart';
import '../../../core/status_banner.dart';
import '../view_models/statement_import_view_model.dart';

class PreviewStep extends StatelessWidget {
  const PreviewStep({super.key, required this.viewModel});

  final StatementImportViewModel viewModel;

  /// The group's shared category, or null when its rows currently carry
  /// different categories (e.g. right after per-row overrides) - shown as
  /// the group picker's blank/unset state rather than guessing one.
  String? _groupCategoryId(StatementImportRowGroup group) {
    String? shared;
    var isFirst = true;
    for (final index in group.rowIndexes) {
      final categoryId = viewModel.rows[index].categoryId;
      if (isFirst) {
        shared = categoryId;
        isFirst = false;
      } else if (categoryId != shared) {
        return null;
      }
    }
    return shared;
  }

  Future<void> _assignGroupCategory(
    BuildContext context,
    StatementImportRowGroup group,
    String? categoryId,
  ) async {
    viewModel.setCategoryForGroup(group.key, categoryId);
    if (categoryId == null) return;
    await _promptSaveAsRule(context, group, categoryId);
  }

  /// Offers to save the just-made group assignment as a reusable rule
  /// (spec: "Save a Category Rule From a Group Assignment"). Declining -
  /// including simply dismissing the dialog - leaves the assignment
  /// applied to this import only; no rule is created.
  Future<void> _promptSaveAsRule(
    BuildContext context,
    StatementImportRowGroup group,
    String categoryId,
  ) async {
    var linkPayee = true;
    final l10n = l10nOf(context);
    await showManagedDialog<void>(
      context: context,
      controllerCount: 1,
      initialTexts: [group.isSingleRow ? '' : group.key],
      builder: (dialogContext, controllers) {
        final keywordController = controllers[0];
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(l10n.saveAsRule),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.saveAsRuleBlurb, style: AppTypography.metadata),
                const SizedBox(height: AppSpacing.medium),
                AppTextField(
                  controller: keywordController,
                  autofocus: group.isSingleRow,
                  labelText: l10n.keyword,
                ),
                // payees-and-spending-memory: "Saving a rule offers to link a
                // payee too" - opt-in, pre-checked; declining still saves the
                // rule exactly as it would without this option.
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l10n.alsoRememberPayee),
                  value: linkPayee,
                  onChanged: (value) =>
                      setDialogState(() => linkPayee = value ?? false),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.actionSkip),
              ),
              ElevatedButton(
                onPressed: () async {
                  final keyword = keywordController.text.trim();
                  if (keyword.isEmpty) return;
                  await viewModel.saveCategoryRule(
                    keyword: keyword,
                    categoryId: categoryId,
                  );
                  if (linkPayee) {
                    await viewModel.linkPayeeToRule(
                      keyword: keyword,
                      categoryId: categoryId,
                    );
                  }
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
                child: Text(l10n.actionSaveRule),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final expenseCategories = viewModel.categories
        .where(
          (c) => c.type == AccountType.expense || c.type == AccountType.income,
        )
        .toList();
    final groups = viewModel.rowGroups;

    // Preview is the first step that always has skip reasons for both
    // OFX (including register-launched auto-select) and CSV (parsed after
    // mapping). Listing them here satisfies "before posting" without
    // blocking Continue / Confirm import.
    final skippedRows = viewModel.skippedRows;

    return Column(
      children: [
        if (viewModel.currencyMismatch)
          StatusBanner(
            message: l10n.statementCurrencyMismatch(
              viewModel.statementCurrency ?? '',
            ),
            isError: true,
          ),
        if (skippedRows.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              AppSpacing.medium,
              AppSpacing.medium,
              0,
            ),
            child: SkippedRowsSection(skippedRows: skippedRows),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: groups.length,
            itemBuilder: (context, groupIndex) {
              final group = groups[groupIndex];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!group.isSingleRow) ...[
                        Text(
                          l10n.rowsGrouped('${group.rowIndexes.length}'),
                          style: AppTypography.sectionLabel,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        EntityPickerField<Account>(
                          labelText: l10n.categoryForAll,
                          items: expenseCategories,
                          idOf: (category) => category.id,
                          labelOf: (category) =>
                              localizeStoredName(l10n, category.name),
                          value: _groupCategoryId(group),
                          onChanged: (categoryId) =>
                              _assignGroupCategory(context, group, categoryId),
                        ),
                        const Divider(height: AppSpacing.xLarge),
                      ],
                      for (final index in group.rowIndexes)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: index == group.rowIndexes.last
                                ? 0
                                : AppSpacing.medium,
                          ),
                          child: PreviewRow(
                            row: viewModel.rows[index],
                            categories: expenseCategories,
                            selected: viewModel.rows[index].selected,
                            onToggleSelected: () =>
                                viewModel.toggleRowSelected(index),
                            onCategoryChanged: (categoryId) => group.isSingleRow
                                ? _assignGroupCategory(
                                    context,
                                    group,
                                    categoryId,
                                  )
                                : viewModel.setRowCategory(index, categoryId),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: ElevatedButton(
            onPressed: viewModel.isSubmitting
                ? null
                : () => viewModel.confirmImport(),
            child: Text(
              viewModel.isSubmitting ? l10n.importingLabel : l10n.confirmImport,
            ),
          ),
        ),
      ],
    );
  }
}

/// Scrollable list of parser skip reasons. Shown on account-select (OFX)
/// and preview (OFX + CSV) so every import path surfaces them before
/// posting without blocking the good rows.
class SkippedRowsSection extends StatelessWidget {
  const SkippedRowsSection({super.key, required this.skippedRows});

  final List<StatementSkippedRow> skippedRows;

  @override
  Widget build(BuildContext context) {
    if (skippedRows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.large),
        Text(l10nOf(context).skippedRows, style: AppTypography.cardTitle),
        const SizedBox(height: AppSpacing.small),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 160),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: skippedRows.length,
            itemBuilder: (context, index) {
              final skipped = skippedRows[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeSkipReason(
                        l10nOf(context),
                        skipped.code,
                        skipped.params,
                      ),
                      style: AppTypography.body,
                    ),
                    Text(
                      skipped.rawFragment,
                      style: AppTypography.metadata,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PreviewRow extends StatelessWidget {
  const PreviewRow({
    super.key,
    required this.row,
    required this.categories,
    required this.selected,
    required this.onToggleSelected,
    required this.onCategoryChanged,
  });

  final StatementImportPreviewRow row;
  final List<Account> categories;
  final bool selected;
  final VoidCallback onToggleSelected;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Row(
      children: [
        Checkbox(value: selected, onChanged: (_) => onToggleSelected()),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      localizeStoredName(l10n, row.transaction.description),
                      style: AppTypography.cardTitle,
                    ),
                  ),
                  Text(
                    formatAmountMinor(
                      row.transaction.amountMinor,
                      row.transaction.currency,
                    ),
                    style: AppTypography.cardTitle,
                  ),
                ],
              ),
              Text(
                '${row.transaction.transactionDate.year}-'
                '${row.transaction.transactionDate.month.toString().padLeft(2, '0')}-'
                '${row.transaction.transactionDate.day.toString().padLeft(2, '0')}'
                '${row.isDuplicate ? ' - ${l10n.possibleDuplicate}' : ''}',
                style: AppTypography.metadata.copyWith(
                  color: row.isDuplicate
                      ? AppColors.signal
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              EntityPickerField<Account>(
                labelText: l10n.category,
                items: categories,
                idOf: (category) => category.id,
                labelOf: (category) => localizeStoredName(l10n, category.name),
                value: row.categoryId,
                onChanged: onCategoryChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
