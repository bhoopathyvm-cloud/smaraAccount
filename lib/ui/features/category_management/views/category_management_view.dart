import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
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
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: 'Hide category from new entries?',
      message:
          '${category.name} will no longer be offered when recording new '
          'transactions.',
      confirmLabel: 'Hide',
    );
    if (confirmed) await viewModel.archiveCategory(category.id);
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final nameController = TextEditingController();
    var type = AccountType.expense;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: AppSpacing.medium),
              SegmentedButton<AccountType>(
                segments: const [
                  ButtonSegment(
                    value: AccountType.income,
                    label: Text('Income'),
                  ),
                  ButtonSegment(
                    value: AccountType.expense,
                    label: Text('Expense'),
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
              child: const Text('Cancel'),
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, Account category) async {
    final controller = TextEditingController(text: category.name);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename category'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLimitDialog(BuildContext context, Account category) async {
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
          title: const Text('Monthly limit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'An optional month-to-date spending guide for '
                '${category.name} - informational only, it never blocks '
                'recording a transaction.',
                style: AppTypography.metadata,
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Limit (leave blank to clear)',
                ),
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
              child: const Text('Cancel'),
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
                      () => errorMessage = 'Enter a valid amount.',
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
                  setDialogState(() => errorMessage = viewModel.errorMessage);
                }
              },
              child: const Text('Save'),
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
        title: Text('Categories', style: AppTypography.headerTitle),
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
              final category = viewModel.categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                  vertical: AppSpacing.small,
                ),
                child: ListTile(
                  leading: Icon(TablerIcons.tag, color: AppColors.textPrimary),
                  title: Text(category.name, style: AppTypography.cardTitle),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.type.name, style: AppTypography.metadata),
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
                          child: const Text('Restore'),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (category.type == AccountType.expense)
                              IconButton(
                                icon: const Icon(TablerIcons.target),
                                tooltip: 'Monthly limit',
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
                                child: const Text('Hide'),
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
