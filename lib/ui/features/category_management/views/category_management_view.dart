import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../../../core/money_formatter.dart';
import '../../../core/monthly_limit_progress.dart';
import '../view_models/category_management_view_model.dart';

/// Rename/add/hide categories. The destructive "Hide" action uses
/// the design system's destructive-button pattern: red outlined, red
/// text, transparent background.
class CategoryManagementView extends StatelessWidget {
  const CategoryManagementView({super.key, required this.viewModel});

  final CategoryManagementViewModel viewModel;

  Future<void> _confirmArchive(BuildContext context, Account category) async {
    final l10n = l10nOf(context);
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.hideCategoryTitle,
      message: l10n.hideCategoryBody(localizeStoredName(l10n, category.name)),
      confirmLabel: l10n.actionHide,
    );
    if (confirmed) await viewModel.archiveCategory(category.id);
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final l10n = l10nOf(context);
    final nameController = TextEditingController();
    var type = AccountType.expense;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addCategory),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.name),
              ),
              const SizedBox(height: AppSpacing.medium),
              SegmentedButton<AccountType>(
                segments: [
                  ButtonSegment(
                    value: AccountType.income,
                    label: Text(l10n.income),
                  ),
                  ButtonSegment(
                    value: AccountType.expense,
                    label: Text(l10n.expense),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (selection) =>
                    setDialogState(() => type = selection.first),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                viewModel.addCategory(
                  name: nameController.text.trim(),
                  type: type,
                );
                Navigator.of(context).pop();
              },
              child: Text(l10n.actionAdd),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, Account category) async {
    final l10n = l10nOf(context);
    final controller = TextEditingController(text: category.name);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameCategory),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              viewModel.renameCategory(
                id: category.id,
                newName: controller.text.trim(),
              );
              Navigator.of(context).pop();
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  Future<void> _showLimitDialog(BuildContext context, Account category) async {
    final l10n = l10nOf(context);
    final controller = TextEditingController(
      text: category.monthlyLimitMinor == null
          ? ''
          : formatAmountMinor(
              category.monthlyLimitMinor!,
              monthlyLimitDisplayCurrency,
            ),
    );
    String? errorMessage;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.monthlyLimit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.monthlyLimitBlurb, style: AppTypography.metadata),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.monthlyLimitHint),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.medium),
                Text(
                  errorMessage!,
                  style: AppTypography.body.copyWith(color: AppColors.signal),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();
                int? limitMinor;
                if (text.isNotEmpty) {
                  limitMinor = parseAmountToMinor(
                    text,
                    monthlyLimitDisplayCurrency,
                  );
                  if (limitMinor == null) {
                    setDialogState(
                      () => errorMessage = l10n.validationEnterValidAmount,
                    );
                    return;
                  }
                }
                final ok = await viewModel.setCategoryMonthlyLimit(
                  id: category.id,
                  monthlyLimitMinor: limitMinor,
                );
                if (ok && dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                } else {
                  setDialogState(
                    () => errorMessage = viewModel.errorMessageFor(l10n),
                  );
                }
              },
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10nOf(context).categoriesTitle,
          style: AppTypography.headerTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'categories-fab',
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(TablerIcons.plus, color: AppColors.cardBackground),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return ListView.builder(
            itemCount: viewModel.categories.length,
            itemBuilder: (context, index) {
              final l10n = l10nOf(context);
              final category = viewModel.categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                  vertical: AppSpacing.small,
                ),
                child: ListTile(
                  leading: Icon(TablerIcons.tag, color: AppColors.textPrimary),
                  title: Text(
                    localizeStoredName(l10n, category.name),
                    style: AppTypography.cardTitle,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.type == AccountType.income
                            ? l10n.income
                            : l10n.expense,
                        style: AppTypography.metadata,
                      ),
                      if (category.type == AccountType.expense &&
                          category.monthlyLimitMinor != null)
                        MonthlyLimitProgress(
                          spentMinor: viewModel.monthToDateSpentFor(
                            category.id,
                          ),
                          limitMinor: category.monthlyLimitMinor!,
                        ),
                    ],
                  ),
                  trailing: category.archived
                      ? TextButton(
                          onPressed: () =>
                              viewModel.unarchiveCategory(category.id),
                          child: Text(l10n.actionRestore),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (category.type == AccountType.expense)
                              IconButton(
                                icon: const Icon(TablerIcons.target),
                                tooltip: l10n.monthlyLimit,
                                color: AppColors.textSecondary,
                                onPressed: () =>
                                    _showLimitDialog(context, category),
                              ),
                            IconButton(
                              icon: const Icon(TablerIcons.pencil),
                              color: AppColors.textSecondary,
                              onPressed: () =>
                                  _showRenameDialog(context, category),
                            ),
                            IntrinsicWidth(
                              child: OutlinedButton(
                                style: destructiveButtonStyle,
                                onPressed: () =>
                                    _confirmArchive(context, category),
                                child: Text(l10n.actionHide),
                              ),
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
}
