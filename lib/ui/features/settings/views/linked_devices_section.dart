import 'package:flutter/material.dart';

import '../../../../domain/models/linked_device.dart';
import '../../../../domain/models/linked_device_role.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/linked_devices_view_model.dart';

/// Settings "Linked devices" section with catch-up copy, first-open
/// permission sentence, and "Add a device" (linked-devices task 4.2).
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
                _LinkedDeviceTile(device: device),
              for (final device in viewModel.devices.where((d) => !d.isActive))
                _LinkedDeviceTile(device: device),
              if (viewModel.devices.where((d) => d.isActive).length <= 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                  child: Text(
                    l10n.settingsLinkedDevicesEmpty,
                    style: AppTypography.metadata,
                  ),
                ),
              if (viewModel.canAdd)
                OutlinedButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : () => _showAddDevice(context),
                  child: Text(l10n.settingsLinkedDevicesAddDevice),
                ),
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
  const _LinkedDeviceTile({required this.device});

  final LinkedDevice device;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final roleLabel = device.role == LinkedDeviceRole.owner
        ? l10n.settingsLinkedDevicesRoleOwner
        : l10n.settingsLinkedDevicesRoleMember;
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(device.displayName, style: AppTypography.body),
      subtitle: Text(
        [
          roleLabel,
          if (device.canAdd && device.role == LinkedDeviceRole.member)
            l10n.settingsLinkedDevicesCanAdd,
          ?status,
        ].join(' · '),
        style: AppTypography.metadata,
      ),
    );
  }
}
