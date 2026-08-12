import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/account_management_view_model.dart';

/// A few common ISO 4217 codes shown as quick picks, matching the same
/// convenience list onboarding's currency picker uses; any 3-letter code
/// can be typed instead.
const _commonCurrencies = ['USD', 'EUR', 'GBP', 'INR', 'CAD', 'AUD', 'JPY'];

class AccountManagementView extends StatelessWidget {
  const AccountManagementView({
    super.key,
    required this.viewModel,
    this.onTransfer,
    this.onImport,
  });

  final AccountManagementViewModel viewModel;
  final VoidCallback? onTransfer;
  final VoidCallback? onImport;

  // These dialog-local controllers are intentionally never disposed: the
  // AlertDialog's exit transition keeps its TextFields mounted (and
  // rebuilding) for a few frames after showDialog's Future resolves, so
  // disposing immediately after await races that animation and throws.
  Future<void> _showCreateDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    var type = AccountType.asset;
    String? groupId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final kind = type == AccountType.asset
              ? AccountGroupKind.assetGroup
              : AccountGroupKind.liabilityGroup;
          final groups = viewModel.groups
              .where((group) => group.kind == kind && !group.archived)
              .toList();
          if (!groups.any((group) => group.id == groupId)) {
            groupId = groups.isEmpty ? null : groups.first.id;
          }
          return AlertDialog(
            title: const Text('Create account'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  SegmentedButton<AccountType>(
                    segments: const [
                      ButtonSegment(
                        value: AccountType.asset,
                        label: Text('Asset'),
                      ),
                      ButtonSegment(
                        value: AccountType.liability,
                        label: Text('Liability'),
                      ),
                    ],
                    selected: {type},
                    onSelectionChanged: (selection) {
                      setDialogState(() {
                        type = selection.first;
                        groupId = null;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  DropdownButtonFormField<String>(
                    key: ValueKey(type),
                    initialValue: groupId,
                    decoration: const InputDecoration(labelText: 'Group'),
                    items: [
                      for (final group in groups)
                        DropdownMenuItem(
                          value: group.id,
                          child: Text(group.name),
                        ),
                    ],
                    onChanged: (value) => groupId = value,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextField(
                    controller: balanceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Opening balance (optional)',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: groupId == null
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final balanceText = balanceController.text.trim();
                        final balance = balanceText.isEmpty
                            ? null
                            : double.tryParse(balanceText);
                        if (balanceText.isNotEmpty && balance == null) return;
                        final created = await viewModel.createAccount(
                          name: name,
                          type: type,
                          groupId: groupId!,
                          openingBalanceMinor: balance == null
                              ? null
                              : (balance * 100).round(),
                        );
                        if (created && dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showRenameAccountDialog(
    BuildContext context,
    Account account,
  ) async {
    final controller = TextEditingController(text: account.name);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename account'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final renamed = await viewModel.renameAccount(
                id: account.id,
                newName: name,
              );
              if (renamed && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameGroupDialog(
    BuildContext context,
    AccountGroup group,
  ) async {
    final controller = TextEditingController(text: group.name);
    final currencyController = TextEditingController(text: group.currency);
    final hasActiveAccounts = viewModel.accounts.any(
      (account) => account.groupId == group.id && !account.archived,
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, autofocus: true),
            const SizedBox(height: AppSpacing.medium),
            TextField(
              controller: currencyController,
              enabled: !hasActiveAccounts,
              textCapitalization: TextCapitalization.characters,
              maxLength: 3,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                TextInputFormatter.withFunction(
                  (oldValue, newValue) =>
                      newValue.copyWith(text: newValue.text.toUpperCase()),
                ),
              ],
              decoration: InputDecoration(
                labelText: 'Currency (ISO 4217)',
                helperText: hasActiveAccounts
                    ? 'Cannot change currency while this group has active accounts.'
                    : null,
                helperMaxLines: 2,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              if (name != group.name) {
                final renamed = await viewModel.renameGroup(
                  id: group.id,
                  newName: name,
                );
                if (!renamed) return;
              }
              final currency = currencyController.text.trim();
              if (!hasActiveAccounts &&
                  currency.isNotEmpty &&
                  currency != group.currency) {
                final changed = await viewModel.changeGroupCurrency(
                  id: group.id,
                  currency: currency,
                );
                if (!changed) return;
              }
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateGroupDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final currencyController = TextEditingController(
      text: _commonCurrencies.first,
    );
    var kind = AccountGroupKind.assetGroup;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: AppSpacing.medium),
                SegmentedButton<AccountGroupKind>(
                  segments: const [
                    ButtonSegment(
                      value: AccountGroupKind.assetGroup,
                      label: Text('Asset'),
                    ),
                    ButtonSegment(
                      value: AccountGroupKind.liabilityGroup,
                      label: Text('Liability'),
                    ),
                  ],
                  selected: {kind},
                  onSelectionChanged: (selection) =>
                      setDialogState(() => kind = selection.first),
                ),
                const SizedBox(height: AppSpacing.medium),
                Wrap(
                  spacing: AppSpacing.small,
                  children: [
                    for (final code in _commonCurrencies)
                      ChoiceChip(
                        label: Text(code),
                        selected: currencyController.text == code,
                        onSelected: (_) => setDialogState(
                          () => currencyController.text = code,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: currencyController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 3,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) =>
                          newValue.copyWith(text: newValue.text.toUpperCase()),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Currency (ISO 4217, e.g. USD)',
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed:
                  !RegExp(r'^[A-Z]{3}$').hasMatch(currencyController.text)
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;
                      final created = await viewModel.createGroup(
                        name: name,
                        kind: kind,
                        currency: currencyController.text,
                      );
                      if (created && dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmArchiveGroup(
    BuildContext context,
    AccountGroup group,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive group?'),
        content: Text(
          '${group.name} will no longer be offered when creating or '
          'reassigning accounts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.signal,
              side: const BorderSide(color: AppColors.signal),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed == true) await viewModel.archiveGroup(group.id);
  }

  Future<void> _showReassignDialog(
    BuildContext context,
    Account account,
  ) async {
    final kind = account.type == AccountType.asset
        ? AccountGroupKind.assetGroup
        : AccountGroupKind.liabilityGroup;
    final currentCurrency = viewModel.groups
        .cast<AccountGroup?>()
        .firstWhere((g) => g?.id == account.groupId, orElse: () => null)
        ?.currency;
    // Only same-currency groups are valid reassignment targets - moving an
    // account to a different-currency group would retroactively reinterpret
    // its historical balances (multi-currency-support design.md, extending
    // multi-account-support's Decision 1/2.9).
    final groups = viewModel.groups
        .where(
          (group) =>
              group.kind == kind &&
              group.currency == currentCurrency &&
              !group.archived,
        )
        .toList();
    var groupId = account.groupId;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Reassign group'),
          content: DropdownButtonFormField<String>(
            initialValue: groupId,
            decoration: const InputDecoration(labelText: 'Group'),
            items: [
              for (final group in groups)
                DropdownMenuItem(value: group.id, child: Text(group.name)),
            ],
            onChanged: (value) => setDialogState(() => groupId = value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: groupId == null
                  ? null
                  : () async {
                      final reassigned = await viewModel.reassignAccountGroup(
                        id: account.id,
                        groupId: groupId!,
                      );
                      if (reassigned && dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmArchive(BuildContext context, Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive account?'),
        content: Text(
          '${account.name} will no longer be available for new transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.signal,
              side: const BorderSide(color: AppColors.signal),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed == true) await viewModel.archiveAccount(account.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accounts', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            tooltip: 'Create group',
            onPressed: () => _showCreateGroupDialog(context),
            icon: const Icon(TablerIcons.folderPlus),
          ),
          IconButton(
            tooltip: 'Transfer',
            onPressed: onTransfer,
            icon: const Icon(TablerIcons.arrowsExchange),
          ),
          IconButton(
            tooltip: 'Import OFX',
            onPressed: onImport,
            icon: const Icon(TablerIcons.fileImport),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'accounts-fab',
        onPressed: () => _showCreateDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(TablerIcons.plus, color: AppColors.cardBackground),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            if (viewModel.errorMessage != null)
              MaterialBanner(
                content: Text(viewModel.errorMessage!),
                actions: [
                  TextButton(
                    onPressed: viewModel.clearError,
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            for (final group in viewModel.groups)
              _GroupAccounts(
                group: group,
                accounts: viewModel.accounts
                    .where((account) => account.groupId == group.id)
                    .toList(),
                onRenameGroup: () => _showRenameGroupDialog(context, group),
                onArchiveGroup: () => _confirmArchiveGroup(context, group),
                onRenameAccount: (account) =>
                    _showRenameAccountDialog(context, account),
                onReassignAccount: (account) =>
                    _showReassignDialog(context, account),
                onArchiveAccount: (account) =>
                    _confirmArchive(context, account),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupAccounts extends StatelessWidget {
  const _GroupAccounts({
    required this.group,
    required this.accounts,
    required this.onRenameGroup,
    required this.onArchiveGroup,
    required this.onRenameAccount,
    required this.onReassignAccount,
    required this.onArchiveAccount,
  });

  final AccountGroup group;
  final List<Account> accounts;
  final VoidCallback onRenameGroup;
  final VoidCallback onArchiveGroup;
  final ValueChanged<Account> onRenameAccount;
  final ValueChanged<Account> onReassignAccount;
  final ValueChanged<Account> onArchiveAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(group.name, style: AppTypography.sectionLabel),
          subtitle: Text(
            group.archived ? 'Archived' : group.currency ?? 'No currency set',
            style: AppTypography.metadata,
          ),
          trailing: group.archived
              ? null
              : group.isSystem
              ? IconButton(
                  tooltip: 'Edit group',
                  icon: const Icon(TablerIcons.pencil),
                  onPressed: onRenameGroup,
                )
              : PopupMenuButton<_GroupAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _GroupAction.rename:
                        onRenameGroup();
                      case _GroupAction.archive:
                        onArchiveGroup();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _GroupAction.rename,
                      child: Text('Edit group'),
                    ),
                    PopupMenuItem(
                      value: _GroupAction.archive,
                      child: Text('Archive'),
                    ),
                  ],
                ),
        ),
        const Divider(height: 1),
        if (accounts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('No accounts', style: AppTypography.metadata),
            ),
          ),
        for (final account in accounts)
          ListTile(
            leading: Icon(
              account.archived ? TablerIcons.archive : TablerIcons.wallet,
              color: account.archived
                  ? AppColors.textMuted
                  : AppColors.textSecondary,
            ),
            title: Text(account.name, style: AppTypography.cardTitle),
            subtitle: Text(
              account.archived ? 'Archived' : account.type.name,
              style: AppTypography.metadata,
            ),
            trailing: account.archived
                ? null
                : PopupMenuButton<_AccountAction>(
                    onSelected: (action) {
                      switch (action) {
                        case _AccountAction.rename:
                          onRenameAccount(account);
                        case _AccountAction.reassign:
                          onReassignAccount(account);
                        case _AccountAction.archive:
                          onArchiveAccount(account);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _AccountAction.rename,
                        child: Text('Rename'),
                      ),
                      PopupMenuItem(
                        value: _AccountAction.reassign,
                        child: Text('Reassign group'),
                      ),
                      PopupMenuItem(
                        value: _AccountAction.archive,
                        child: Text('Archive'),
                      ),
                    ],
                  ),
          ),
        const SizedBox(height: AppSpacing.medium),
      ],
    );
  }
}

enum _AccountAction { rename, reassign, archive }

enum _GroupAction { rename, archive }
