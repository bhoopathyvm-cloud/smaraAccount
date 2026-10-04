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
              for (final entry in _labeledSets(viewModel.sets, l10n))
                _BooksSetTile(
                  set: entry.set,
                  label: entry.label,
                  enabled: !viewModel.isBusy,
                  onSwitch: entry.set.isActive
                      ? null
                      : () => viewModel.switchTo(entry.set.id),
                  onRemove: entry.set.isActive || viewModel.sets.length <= 1
                      ? null
                      : () => _confirmRemove(context, entry.set, entry.label),
                  onRename: () => _showRenameDialog(context, entry.set),
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

  Future<void> _confirmRemove(
    BuildContext context,
    BooksSetInfo set,
    String label,
  ) async {
    final l10n = l10nOf(context);
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.settingsBooksSwitcherRemoveTitle,
      message: l10n.settingsBooksSwitcherRemoveBody(label),
      confirmLabel: l10n.settingsBooksSwitcherRemoveConfirm,
    );
    if (confirmed && context.mounted) {
      await viewModel.removeSet(set.id);
    }
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final l10n = l10nOf(context);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _BooksNameDialog(
        title: l10n.settingsBooksSwitcherCreateTitle,
        confirmLabel: l10n.settingsBooksSwitcherCreate,
      ),
    );
    if (name != null && context.mounted) {
      await viewModel.createSet(name);
    }
  }

  Future<void> _showRenameDialog(BuildContext context, BooksSetInfo set) async {
    final l10n = l10nOf(context);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _BooksNameDialog(
        title: l10n.settingsBooksSwitcherRenameTitle,
        help: l10n.settingsBooksSwitcherRenameHelp,
        confirmLabel: l10n.actionRename,
        initial: set.displayName,
      ),
    );
    if (name != null && context.mounted) {
      await viewModel.renameSet(set.id, name);
    }
  }
}

/// Name entry for new or renamed books. Owns its text controller so it
/// outlives the dialog's closing animation.
class _BooksNameDialog extends StatefulWidget {
  const _BooksNameDialog({
    required this.title,
    required this.confirmLabel,
    this.help,
    this.initial = '',
  });

  final String title;
  final String confirmLabel;
  final String? help;
  final String initial;

  @override
  State<_BooksNameDialog> createState() => _BooksNameDialogState();
}

class _BooksNameDialogState extends State<_BooksNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.help != null) ...[
            Text(widget.help!, style: AppTypography.metadata),
            const SizedBox(height: AppSpacing.small),
          ],
          TextField(
            key: const Key('books-name-field'),
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.settingsBooksSwitcherNameLabel,
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          key: const Key('books-name-save'),
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// Resolves user-visible labels for [sets]: real names stay as-is; unnamed
/// sets get localized "Books 1", "Books 2", … and never the raw id.
@visibleForTesting
List<({BooksSetInfo set, String label})> labeledBooksSets(
  List<BooksSetInfo> sets,
  AppLocalizations l10n,
) => _labeledSets(sets, l10n);

List<({BooksSetInfo set, String label})> _labeledSets(
  List<BooksSetInfo> sets,
  AppLocalizations l10n,
) {
  var untitledOrdinal = 0;
  return [
    for (final set in sets)
      (
        set: set,
        label: set.hasUserVisibleName
            ? set.displayName
            : l10n.settingsBooksSwitcherFallbackName(++untitledOrdinal),
      ),
  ];
}

class _BooksSetTile extends StatelessWidget {
  const _BooksSetTile({
    required this.set,
    required this.label,
    required this.enabled,
    required this.onSwitch,
    required this.onRemove,
    required this.onRename,
  });

  final BooksSetInfo set;
  final String label;
  final bool enabled;
  final VoidCallback? onSwitch;
  final VoidCallback? onRemove;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTypography.body),
      subtitle: set.isActive
          ? Text(
              l10n.settingsBooksSwitcherActive,
              style: AppTypography.metadata,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: Key('books-rename-${set.id}'),
            tooltip: l10n.actionRename,
            onPressed: enabled ? onRename : null,
            icon: const Icon(Icons.edit_outlined),
          ),
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
