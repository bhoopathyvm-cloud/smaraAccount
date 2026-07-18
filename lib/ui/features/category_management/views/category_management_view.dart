import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/category_management_view_model.dart';

/// Rename/add/archive categories. The destructive "Archive" action uses
/// the design system's destructive-button pattern: red outlined, red
/// text, transparent background.
class CategoryManagementView extends StatelessWidget {
  const CategoryManagementView({super.key, required this.viewModel});

  final CategoryManagementViewModel viewModel;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      floatingActionButton: FloatingActionButton(
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
                  subtitle: Text(
                    category.type.name,
                    style: AppTypography.metadata,
                  ),
                  trailing: category.archived
                      ? Icon(TablerIcons.archive, color: AppColors.textMuted)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(TablerIcons.pencil),
                              color: AppColors.textSecondary,
                              onPressed: () =>
                                  _showRenameDialog(context, category),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.signal,
                                side: const BorderSide(
                                  color: AppColors.signal,
                                  width: 1.5,
                                ),
                              ),
                              onPressed: () =>
                                  viewModel.archiveCategory(category.id),
                              child: const Text('Archive'),
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
