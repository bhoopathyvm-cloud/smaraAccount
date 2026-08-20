import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_amount_field.dart';
import '../../../core/status_banner.dart';
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
    final l10n = l10nOf(context);
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    var type = AccountType.asset;
    String? groupId;
    int? openingBalanceMinor;
    var isCreditCard = false;
    var holdsInvestments = false;

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
          final selectedGroupCurrency = groups
              .where((group) => group.id == groupId)
              .map((group) => group.currency)
              .firstWhere((currency) => currency != null, orElse: () => null);
          return AlertDialog(
            title: Text(l10n.createAccount),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l10n.name),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  SegmentedButton<AccountType>(
                    segments: [
                      ButtonSegment(
                        value: AccountType.asset,
                        label: Text(l10n.asset),
                      ),
                      ButtonSegment(
                        value: AccountType.liability,
                        label: Text(l10n.liability),
                      ),
                    ],
                    selected: {type},
                    onSelectionChanged: (selection) {
                      setDialogState(() {
                        type = selection.first;
                        groupId = null;
                        if (type != AccountType.liability) {
                          isCreditCard = false;
                        }
                        if (type != AccountType.asset) {
                          holdsInvestments = false;
                        }
                      });
                    },
                  ),
                  // credit-card-household-flow: set once at creation,
                  // never changeable afterward - a Liability-only flag,
                  // mirroring the holdsInvestments pattern.
                  if (type == AccountType.asset)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(l10n.thisAccountHoldsInvestments),
                      subtitle: Text(
                        l10n.thisAccountHoldsInvestmentsSubtitle,
                      ),
                      value: holdsInvestments,
                      onChanged: (value) => setDialogState(
                        () => holdsInvestments = value ?? false,
                      ),
                    ),
                  if (type == AccountType.liability)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(l10n.thisIsACreditCard),
                      value: isCreditCard,
                      onChanged: (value) =>
                          setDialogState(() => isCreditCard = value ?? false),
                    ),
                  const SizedBox(height: AppSpacing.medium),
                  EntityPickerField<AccountGroup>(
                    key: ValueKey(type),
                    labelText: l10n.groupLabel,
                    items: groups,
                    idOf: (group) => group.id,
                    labelOf: (group) => localizeStoredName(l10n, group.name),
                    value: groupId,
                    onChanged: (value) => groupId = value,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  MoneyAmountField(
                    controller: balanceController,
                    labelText: l10n.openingBalanceOptional,
                    currency: selectedGroupCurrency ?? 'USD',
                    onChangedMinor: (value) => openingBalanceMinor = value,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.actionCancel),
              ),
              ElevatedButton(
                onPressed: groupId == null
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final created = await viewModel.createAccount(
                          name: name,
                          type: type,
                          groupId: groupId!,
                          openingBalanceMinor: openingBalanceMinor,
                          isCreditCard: isCreditCard,
                          holdsInvestments: holdsInvestments,
                        );
                        if (created && dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                child: Text(l10n.actionCreate),
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
    final l10n = l10nOf(context);
    final controller = TextEditingController(text: account.name);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renameAccount),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.actionCancel),
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
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameGroupDialog(
    BuildContext context,
    AccountGroup group,
  ) async {
    final l10n = l10nOf(context);
    final controller = TextEditingController(text: group.name);
    final currencyController = TextEditingController(text: group.currency);
    final hasActiveAccounts = viewModel.accounts.any(
      (account) => account.groupId == group.id && !account.archived,
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editGroup),
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
                labelText: l10n.currencyIso,
                helperText: hasActiveAccounts
                    ? l10n.errorCannotChangeGroupCurrencyWithAccounts
                    : null,
                helperMaxLines: 2,
              ),
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
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateGroupDialog(BuildContext context) async {
    final l10n = l10nOf(context);
    final nameController = TextEditingController();
    final currencyController = TextEditingController(
      text: _commonCurrencies.first,
    );
    var kind = AccountGroupKind.assetGroup;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.createGroup),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(labelText: l10n.name),
                ),
                const SizedBox(height: AppSpacing.medium),
                SegmentedButton<AccountGroupKind>(
                  segments: [
                    ButtonSegment(
                      value: AccountGroupKind.assetGroup,
                      label: Text(l10n.asset),
                    ),
                    ButtonSegment(
                      value: AccountGroupKind.liabilityGroup,
                      label: Text(l10n.liability),
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
                  decoration: InputDecoration(
                    labelText: l10n.currencyIsoExample,
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionCancel),
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
              child: Text(l10n.actionCreate),
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
    final l10n = l10nOf(context);
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.hideGroupTitle,
      message: l10n.hideGroupBody(localizeStoredName(l10n, group.name)),
      confirmLabel: l10n.actionHide,
    );
    if (confirmed) await viewModel.archiveGroup(group.id);
  }

  Future<void> _showReassignDialog(
    BuildContext context,
    Account account,
  ) async {
    final l10n = l10nOf(context);
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
          title: Text(l10n.reassignGroup),
          content: EntityPickerField<AccountGroup>(
            labelText: l10n.groupLabel,
            items: groups,
            idOf: (group) => group.id,
            labelOf: (group) => localizeStoredName(l10n, group.name),
            value: groupId,
            onChanged: (value) => setDialogState(() => groupId = value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionCancel),
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
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmArchive(BuildContext context, Account account) async {
    final l10n = l10nOf(context);
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.hideAccountTitle,
      message: l10n.hideAccountBody(localizeStoredName(l10n, account.name)),
      confirmLabel: l10n.actionHide,
    );
    if (confirmed) await viewModel.archiveAccount(account.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10nOf(context).accountsTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            tooltip: l10nOf(context).createGroup,
            onPressed: () => _showCreateGroupDialog(context),
            icon: const Icon(TablerIcons.folderPlus),
          ),
          IconButton(
            tooltip: l10nOf(context).actionTransfer,
            onPressed: onTransfer,
            icon: const Icon(TablerIcons.arrowsExchange),
          ),
          IconButton(
            tooltip: l10nOf(context).importOfx,
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
              StatusBanner(
                message: viewModel.errorMessage!,
                onDismiss: viewModel.clearError,
              ),
            for (final group in viewModel.groups)
              _GroupAccounts(
                group: group,
                accounts: viewModel.accounts
                    .where((account) => account.groupId == group.id)
                    .toList(),
                onRenameGroup: () => _showRenameGroupDialog(context, group),
                onArchiveGroup: () => _confirmArchiveGroup(context, group),
                onUnarchiveGroup: () => viewModel.unarchiveGroup(group.id),
                onRenameAccount: (account) =>
                    _showRenameAccountDialog(context, account),
                onReassignAccount: (account) =>
                    _showReassignDialog(context, account),
                onArchiveAccount: (account) =>
                    _confirmArchive(context, account),
                onUnarchiveAccount: (account) =>
                    viewModel.unarchiveAccount(account.id),
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
    required this.onUnarchiveGroup,
    required this.onRenameAccount,
    required this.onReassignAccount,
    required this.onArchiveAccount,
    required this.onUnarchiveAccount,
  });

  final AccountGroup group;
  final List<Account> accounts;
  final VoidCallback onRenameGroup;
  final VoidCallback onArchiveGroup;

  /// unarchive-accounts-categories: shown only for a user-created,
  /// archived group (a system group is never archived in the first
  /// place, so it never reaches this state).
  final VoidCallback onUnarchiveGroup;
  final ValueChanged<Account> onRenameAccount;
  final ValueChanged<Account> onReassignAccount;
  final ValueChanged<Account> onArchiveAccount;
  final ValueChanged<Account> onUnarchiveAccount;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Column(
      children: [
        ListTile(
          title: Text(
            localizeStoredName(l10n, group.name),
            style: AppTypography.sectionLabel,
          ),
          subtitle: Text(
            group.archived
                ? l10n.hiddenLabel
                : group.currency ?? l10n.noCurrencySet,
            style: AppTypography.metadata,
          ),
          trailing: group.archived
              ? TextButton(
                  onPressed: onUnarchiveGroup,
                  child: Text(l10n.actionRestore),
                )
              : group.isSystem
              ? IconButton(
                  tooltip: l10n.editGroup,
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
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _GroupAction.rename,
                      child: Text(l10n.editGroup),
                    ),
                    PopupMenuItem(
                      value: _GroupAction.archive,
                      child: Text(l10n.actionHide),
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
              child: Text(l10n.homeNoAccounts, style: AppTypography.metadata),
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
            title: Text(
              localizeStoredName(l10n, account.name),
              style: AppTypography.cardTitle,
            ),
            subtitle: Text(
              account.archived
                  ? l10n.hiddenLabel
                  : account.type == AccountType.asset
                  ? l10n.asset
                  : l10n.liability,
              style: AppTypography.metadata,
            ),
            trailing: account.archived
                ? TextButton(
                    onPressed: () => onUnarchiveAccount(account),
                    child: Text(l10n.actionRestore),
                  )
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
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _AccountAction.rename,
                        child: Text(l10n.actionRename),
                      ),
                      PopupMenuItem(
                        value: _AccountAction.reassign,
                        child: Text(l10n.reassignGroup),
                      ),
                      PopupMenuItem(
                        value: _AccountAction.archive,
                        child: Text(l10n.actionHide),
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
