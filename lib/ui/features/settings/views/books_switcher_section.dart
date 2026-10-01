import 'package:flutter/material.dart';

import '../../../../data/repositories/books_set_repository.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../../../../l10n/l10n.dart';
import '../view_models/books_switcher_view_model.dart';

/// Minimal books-set list with switch / create / remove (books-switcher).
class BooksSwitcherSection extends StatelessWidget {
  const BooksSwitcherSection({super.key, required this.viewModel});

  final BooksSwitcherViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.settingsBooksSwitcher, style: AppTypography.sectionLabel),
            const SizedBox(height: AppSpacing.base),
            Text(
              l10n.settingsBooksSwitcherBlurb,
              style: AppTypography.metadata,
            ),
            const SizedBox(height: AppSpacing.medium),
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.large),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              for (final set in viewModel.sets)
                _BooksSetTile(
                  set: set,
                  enabled: !viewModel.isBusy,
                  onSwitch: set.isActive
                      ? null
                      : () => viewModel.switchTo(set.id),
                  onRemove: set.isActive || viewModel.sets.length <= 1
                      ? null
                      : () => _confirmRemove(context, set),
                ),
              const SizedBox(height: AppSpacing.medium),
              OutlinedButton(
                onPressed: viewModel.isBusy
                    ? null
                    : () => _showCreateDialog(context),
                child: Text(l10n.settingsBooksSwitcherCreate),
              ),
            ],
            if (viewModel.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                viewModel.errorMessage!,
                style: AppTypography.metadata.copyWith(color: AppColors.signal),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _confirmRemove(BuildContext context, BooksSetInfo set) async {
    final l10n = l10nOf(context);
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.settingsBooksSwitcherRemoveTitle,
      message: l10n.settingsBooksSwitcherRemoveBody(set.displayName),
      confirmLabel: l10n.settingsBooksSwitcherRemoveConfirm,
    );
    if (confirmed && context.mounted) {
      await viewModel.removeSet(set.id);
    }
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final l10n = l10nOf(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsBooksSwitcherCreateTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.settingsBooksSwitcherNameLabel,
            ),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: Text(l10n.settingsBooksSwitcherCreate),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (name != null && context.mounted) {
      await viewModel.createSet(name);
    }
  }
}

class _BooksSetTile extends StatelessWidget {
  const _BooksSetTile({
    required this.set,
    required this.enabled,
    required this.onSwitch,
    required this.onRemove,
  });

  final BooksSetInfo set;
  final bool enabled;
  final VoidCallback? onSwitch;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(set.displayName, style: AppTypography.body),
      subtitle: set.isActive
          ? Text(
              l10n.settingsBooksSwitcherActive,
              style: AppTypography.metadata,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onSwitch != null)
            TextButton(
              onPressed: enabled ? onSwitch : null,
              child: Text(l10n.settingsBooksSwitcherSwitch),
            ),
          if (onRemove != null)
            IconButton(
              tooltip: l10n.settingsBooksSwitcherRemoveConfirm,
              onPressed: enabled ? onRemove : null,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }
}
