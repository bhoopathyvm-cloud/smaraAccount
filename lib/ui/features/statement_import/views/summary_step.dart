import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
import '../../../../domain/statement_import/category_rule.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_text_field.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/show_managed_dialog.dart';
import '../view_models/statement_import_view_model.dart';

class SummaryStep extends StatelessWidget {
  const SummaryStep({super.key, required this.viewModel, this.onFinished});

  final StatementImportViewModel viewModel;
  final VoidCallback? onFinished;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final result = viewModel.batchResult;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.postedFailedCount(
              '${result?.postedCount ?? 0}',
              '${result?.failedCount ?? 0}',
            ),
            style: AppTypography.body,
          ),
          if (viewModel.skippedOrExcludedRowCount > 0)
            Text(
              l10n.skippedOrExcludedCount(
                '${viewModel.skippedOrExcludedRowCount}',
              ),
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
          const SizedBox(height: AppSpacing.large),
          Expanded(
            child: ListView(
              children: [
                for (final row in result?.results ?? const [])
                  if (!row.succeeded)
                    ListTile(
                      leading: const Icon(
                        TablerIcons.alertCircle,
                        color: AppColors.signal,
                      ),
                      title: Text(
                        localizeStoredName(l10n, row.transaction.description),
                      ),
                      subtitle: Text(row.error ?? ''),
                    ),
              ],
            ),
          ),
          ElevatedButton(onPressed: onFinished, child: Text(l10n.actionDone)),
        ],
      ),
    );
  }
}

/// Lists every saved category rule with edit/delete actions (spec:
/// "Manage Saved Category Rules"). Reachable from the import flow's app
/// bar - the same place a user is already thinking about categorization -
/// rather than a separate settings screen, since rules are created from,
/// and most relevant during, an import in progress.
class CategoryRuleManagementView extends StatelessWidget {
  const CategoryRuleManagementView({super.key, required this.viewModel});

  final StatementImportViewModel viewModel;

  String _categoryName(AppLocalizations l10n, String categoryId) {
    final category = viewModel.categories
        .where((c) => c.id == categoryId)
        .cast<Account?>()
        .firstWhere((c) => c != null, orElse: () => null);
    return category == null
        ? l10n.unknownCategory
        : localizeStoredName(l10n, category.name);
  }

  Future<void> _showEditDialog(BuildContext context, CategoryRule rule) async {
    var categoryId = rule.categoryId;
    final expenseCategories = viewModel.categories
        .where(
          (c) => c.type == AccountType.expense || c.type == AccountType.income,
        )
        .toList();

    await showManagedDialog<void>(
      context: context,
      controllerCount: 1,
      initialTexts: [rule.keyword],
      builder: (dialogContext, controllers) {
        final keywordController = controllers[0];
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final l10n = l10nOf(context);
            return AlertDialog(
              title: Text(l10n.editRule),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: keywordController,
                    autofocus: true,
                    labelText: l10n.keyword,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  EntityPickerField<Account>(
                    labelText: l10n.category,
                    items: expenseCategories,
                    idOf: (category) => category.id,
                    labelOf: (category) =>
                        localizeStoredName(l10n, category.name),
                    value: categoryId,
                    onChanged: (value) =>
                        setDialogState(() => categoryId = value ?? categoryId),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.actionCancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final keyword = keywordController.text.trim();
                    if (keyword.isEmpty) return;
                    await viewModel.updateCategoryRule(
                      id: rule.id,
                      keyword: keyword,
                      categoryId: categoryId,
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: Text(l10n.actionSave),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, CategoryRule rule) async {
    final l10n = l10nOf(context);
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.deleteRuleTitle,
      message: l10n.deleteRuleBody(rule.keyword),
      confirmLabel: l10n.actionDelete,
    );
    if (confirmed) await viewModel.deleteCategoryRule(rule.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoryRulesTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final rules = viewModel.categoryRules;
          if (rules.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Text(
                  l10n.noSavedRules,
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final rule = rules[index];
              return ListTile(
                title: Text(rule.keyword),
                subtitle: Text(_categoryName(l10n, rule.categoryId)),
                trailing: PopupMenuButton<_CategoryRuleAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _CategoryRuleAction.edit:
                        _showEditDialog(context, rule);
                      case _CategoryRuleAction.delete:
                        _confirmDelete(context, rule);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _CategoryRuleAction.edit,
                      child: Text(l10n.actionEdit),
                    ),
                    PopupMenuItem(
                      value: _CategoryRuleAction.delete,
                      child: Text(l10n.actionDelete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

enum _CategoryRuleAction { edit, delete }
