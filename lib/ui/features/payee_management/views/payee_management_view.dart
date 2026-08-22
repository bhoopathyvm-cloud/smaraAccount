import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/payee.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../view_models/payee_management_view_model.dart';

/// Minimal add/rename/delete for payees (payees-and-spending-memory tasks.md
/// 1.2). Deleting is a real delete, not an archive - a payee is only a
/// memory aid, never referenced by a posted journal entry, so there's
/// nothing to keep a read-only record of.
class PayeeManagementView extends StatelessWidget {
  const PayeeManagementView({super.key, required this.viewModel});

  final PayeeManagementViewModel viewModel;

  Future<void> _confirmDelete(BuildContext context, Payee payee) async {
    final l10n = l10nOf(context);
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.deletePayeeTitle,
      message: l10n.deletePayeeBody(payee.name),
      confirmLabel: l10n.actionDelete,
    );
    if (confirmed) await viewModel.deletePayee(payee.id);
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final l10n = l10nOf(context);
    final nameController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addPayee),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              viewModel.addPayee(nameController.text.trim());
              Navigator.of(context).pop();
            },
            child: Text(l10n.actionAdd),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, Payee payee) async {
    final l10n = l10nOf(context);
    final controller = TextEditingController(text: payee.name);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renamePayee),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              viewModel.renamePayee(
                id: payee.id,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10nOf(context).payeesTitle,
          style: AppTypography.headerTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'payees-fab',
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(TablerIcons.plus, color: AppColors.cardBackground),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.payees.isEmpty) {
            return Center(
              child: Text(
                l10nOf(context).noPayeesYet,
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
            );
          }
          return ListView.builder(
            itemCount: viewModel.payees.length,
            itemBuilder: (context, index) {
              final payee = viewModel.payees[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                  vertical: AppSpacing.small,
                ),
                child: ListTile(
                  leading: Icon(
                    TablerIcons.userCircle,
                    color: AppColors.textPrimary,
                  ),
                  title: Text(payee.name, style: AppTypography.cardTitle),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(TablerIcons.pencil),
                        color: AppColors.textSecondary,
                        onPressed: () => _showRenameDialog(context, payee),
                      ),
                      IconButton(
                        icon: const Icon(TablerIcons.trash),
                        color: AppColors.signal,
                        onPressed: () => _confirmDelete(context, payee),
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
