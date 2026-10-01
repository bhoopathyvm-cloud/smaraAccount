import 'package:flutter/material.dart';

import '../../../../domain/models/linked_device.dart';
import '../../../../domain/models/linked_device_role.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../view_models/linked_devices_view_model.dart';

/// Settings "Linked devices" section with catch-up copy, first-open
/// permission sentence, "Add a device", and "Add a person" / remove-person
/// (shared-accounts tasks 2.3–2.4).
class LinkedDevicesSection extends StatelessWidget {
  const LinkedDevicesSection({super.key, required this.viewModel});

  final LinkedDevicesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.settingsLinkedDevices, style: AppTypography.sectionLabel),
            const SizedBox(height: AppSpacing.base),
            Text(
              l10n.settingsLinkedDevicesCatchUp,
              style: AppTypography.metadata,
            ),
            const SizedBox(height: AppSpacing.medium),
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.large),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (viewModel.showingPermissionExplanation)
              _PermissionExplanation(viewModel: viewModel)
            else ...[
              if (viewModel.suggestSecondOwner) ...[
                Text(
                  l10n.settingsLinkedDevicesSuggestSecondOwner,
                  style: AppTypography.metadata,
                ),
                const SizedBox(height: AppSpacing.medium),
              ],
              for (final request in viewModel.pendingJoins)
                _PendingJoinTile(
                  name: request.requesterDisplayName,
                  enabled: !viewModel.isBusy,
                  onApprove: () => viewModel.approveJoin(request.requestId),
                  onRefuse: () => viewModel.refuseJoin(request.requestId),
                ),
              for (final device in viewModel.devices.where((d) => d.isActive))
                _LinkedDeviceTile(
                  device: device,
                  localDeviceId: viewModel.localDeviceId,
                  canRemove:
                      viewModel.canManageMembership &&
                      device.deviceId != viewModel.localDeviceId,
                  enabled: !viewModel.isBusy,
                  onRemove: () => _confirmRemovePerson(context, device),
                ),
              for (final device in viewModel.devices.where((d) => !d.isActive))
                _LinkedDeviceTile(
                  device: device,
                  localDeviceId: viewModel.localDeviceId,
                  canRemove: false,
                  enabled: false,
                  onRemove: null,
                ),
              if (viewModel.devices.where((d) => d.isActive).length <= 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                  child: Text(
                    l10n.settingsLinkedDevicesEmpty,
                    style: AppTypography.metadata,
                  ),
                ),
              if (viewModel.canAdd) ...[
                OutlinedButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : () => _showAddDevice(context),
                  child: Text(l10n.settingsLinkedDevicesAddDevice),
                ),
                const SizedBox(height: AppSpacing.small),
                OutlinedButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : () => _showAddPerson(context),
                  child: Text(l10n.claimsAddPerson),
                ),
              ],
              if (!viewModel.showingPermissionExplanation &&
                  viewModel.devices.where((d) => d.isActive).length > 1) ...[
                const SizedBox(height: AppSpacing.medium),
                ElevatedButton(
                  onPressed: viewModel.isBusy ? null : viewModel.syncNow,
                  child: Text(
                    viewModel.isBusy
                        ? l10n.settingsLinkedDevicesSyncNowBusy
                        : l10n.settingsLinkedDevicesSyncNow,
                  ),
                ),
              ],
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

  Future<void> _showAddDevice(BuildContext context) async {
    final payload = await viewModel.startAddDevice();
    if (payload == null || !context.mounted) return;
    final l10n = l10nOf(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsLinkedDevicesAddDevice),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.settingsLinkedDevicesJoinSameWifi,
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.medium),
                SelectableText(payload.encode(), style: AppTypography.metadata),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                viewModel.clearActiveJoinQr();
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.actionCancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddPerson(BuildContext context) async {
    final l10n = l10nOf(context);
    final nameController = TextEditingController();
    final personName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.claimsAddPerson),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.claimsPersonNameLabel),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(nameController.text),
              child: Text(l10n.actionContinue),
            ),
          ],
        );
      },
    );
    if (personName == null || personName.trim().isEmpty || !context.mounted) {
      return;
    }
    final payload = await viewModel.startAddPerson(
      personDisplayName: personName,
    );
    if (payload == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.claimsAddPerson),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.settingsLinkedDevicesJoinSameWifi,
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  '${l10n.claimsRoleClaimant}: ${personName.trim()}',
                  style: AppTypography.metadata,
                ),
                const SizedBox(height: AppSpacing.medium),
                SelectableText(payload.encode(), style: AppTypography.metadata),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                viewModel.clearActiveJoinQr();
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.actionCancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmRemovePerson(
    BuildContext context,
    LinkedDevice device,
  ) async {
    final l10n = l10nOf(context);
    final name = device.personDisplayName ?? device.displayName;
    final warning = await viewModel.removalWarningFor(device.deviceId);
    if (warning == null || !context.mounted) return;

    final open = warning.openClaims;
    final hasBalance = warning.balanceMinor != 0;
    final String message;
    if (open > 0 && hasBalance) {
      message = l10n.claimsRemovePersonWarning(name, open);
    } else if (open > 0) {
      message = l10n.claimsRemovePersonWarningOpenOnly(name, open);
    } else if (hasBalance) {
      message = l10n.claimsRemovePersonWarningBalanceOnly(name);
    } else {
      message = l10n.claimsRemovePersonWarningClean(name);
    }

    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.claimsRemovePersonTitle(name),
      message: message,
      confirmLabel: l10n.claimsRemovePersonConfirm,
    );
    if (confirmed && context.mounted) {
      await viewModel.removePerson(device.deviceId);
    }
  }
}

class _PermissionExplanation extends StatelessWidget {
  const _PermissionExplanation({required this.viewModel});

  final LinkedDevicesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsLinkedDevicesPermissionSentence,
          style: AppTypography.body,
        ),
        const SizedBox(height: AppSpacing.medium),
        ElevatedButton(
          onPressed: viewModel.isBusy
              ? null
              : viewModel.continueAfterPermissionExplanation,
          child: Text(l10n.settingsLinkedDevicesContinue),
        ),
      ],
    );
  }
}

class _PendingJoinTile extends StatelessWidget {
  const _PendingJoinTile({
    required this.name,
    required this.enabled,
    required this.onApprove,
    required this.onRefuse,
  });

  final String name;
  final bool enabled;
  final VoidCallback onApprove;
  final VoidCallback onRefuse;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        l10n.settingsLinkedDevicesPendingJoin(name),
        style: AppTypography.body,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: enabled ? onApprove : null,
            child: Text(l10n.settingsLinkedDevicesApproveJoin),
          ),
          TextButton(
            onPressed: enabled ? onRefuse : null,
            child: Text(l10n.settingsLinkedDevicesRefuseJoin),
          ),
        ],
      ),
    );
  }
}

class _LinkedDeviceTile extends StatelessWidget {
  const _LinkedDeviceTile({
    required this.device,
    required this.localDeviceId,
    required this.canRemove,
    required this.enabled,
    required this.onRemove,
  });

  final LinkedDevice device;
  final String? localDeviceId;
  final bool canRemove;
  final bool enabled;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final roleLabel = _roleLabel(l10n, device);
    String? status;
    if (device.isErasePending) {
      status = l10n.settingsLinkedDevicesErasePending;
    } else if (device.isErased && device.erasedAt != null) {
      status = l10n.settingsLinkedDevicesErasedOn(
        device.erasedAt!.toLocal().toIso8601String().split('T').first,
      );
    } else if (!device.isActive) {
      status = l10n.membershipNoticeDeviceRemoved(device.displayName);
    }

    final title = device.personDisplayName ?? device.displayName;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTypography.body),
      subtitle: Text(
        [
          roleLabel,
          if (device.canAdd && device.role == LinkedDeviceRole.member)
            l10n.settingsLinkedDevicesCanAdd,
          ?status,
        ].join(' · '),
        style: AppTypography.metadata,
      ),
      trailing: canRemove
          ? TextButton(
              onPressed: enabled ? onRemove : null,
              child: Text(l10n.claimsRemovePerson),
            )
          : null,
    );
  }

  String _roleLabel(AppLocalizations l10n, LinkedDevice device) {
    if (device.roles.contains(LinkedDeviceRole.owner)) {
      return l10n.settingsLinkedDevicesRoleOwner;
    }
    if (device.roles.contains(LinkedDeviceRole.approver)) {
      return l10n.claimsRoleApprover;
    }
    if (device.roles.contains(LinkedDeviceRole.claimant) &&
        !device.roles.contains(LinkedDeviceRole.member)) {
      return l10n.claimsRoleClaimant;
    }
    if (device.roles.contains(LinkedDeviceRole.member)) {
      return l10n.settingsLinkedDevicesRoleMember;
    }
    return device.role.name;
  }
}
