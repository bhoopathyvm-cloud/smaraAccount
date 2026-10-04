import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/join_qr_payload.dart';
import '../../../../domain/models/linked_device.dart';
import '../../../../domain/models/linked_device_role.dart';
import '../../../../domain/navigation/app_navigation_policy.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../join_qr_scanner.dart';
import '../view_models/linked_devices_view_model.dart';
import 'join_code_entry_panel.dart';
import 'join_qr_offer_panel.dart';
import 'join_qr_scan_page.dart';

/// Settings "Linked devices" section with catch-up copy, first-open
/// permission sentence, "Add a device", and "Add a person" / remove-person
/// (shared-accounts tasks 2.3–2.4).
class LinkedDevicesSection extends StatelessWidget {
  const LinkedDevicesSection({
    super.key,
    required this.viewModel,
    this.joinQrScanner,
  });

  final LinkedDevicesViewModel viewModel;

  /// Optional test seam; when null, the camera [JoinQrScanPage] is used.
  final JoinQrScanner? joinQrScanner;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final active = viewModel.devices.where((d) => d.isActive).toList();
        final removed = viewModel.devices.where((d) => !d.isActive).toList();
        bool isPerson(LinkedDevice d) => d.personDisplayName != null;
        final myDevices = [
          ...active.where((d) => !isPerson(d)),
          ...removed.where((d) => !isPerson(d)),
        ];
        final people = [...active.where(isPerson), ...removed.where(isPerson)];
        final showPeople =
            people.isNotEmpty || viewModel.canAdd || viewModel.canApproveClaims;
        final hasPeers = active.length > 1;
        Widget tile(LinkedDevice device) {
          final isLocal = device.deviceId == viewModel.localDeviceId;
          return _LinkedDeviceTile(
            device: device,
            isLocal: isLocal,
            canRemove:
                device.isActive && viewModel.canManageMembership && !isLocal,
            enabled: device.isActive && !viewModel.isBusy,
            onRemove: device.isActive
                ? () => _confirmRemovePerson(context, device)
                : null,
            onRename: isLocal ? () => _renameThisDevice(context) : null,
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.settingsLinkedDevices,
                style: AppTypography.sectionLabel,
              ),
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
                _SectionHeading(
                  key: const Key('linked-devices-my-devices'),
                  title: l10n.linkedDevicesMyDevicesHeading,
                  help: l10n.linkedDevicesMyDevicesHelp,
                ),
                for (final device in myDevices) tile(device),
                if (!hasPeers)
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
                ],
                if (showPeople) ...[
                  _SectionHeading(
                    key: const Key('linked-devices-people'),
                    title: l10n.linkedDevicesPeopleHeading,
                    help: l10n.linkedDevicesPeopleHelp,
                  ),
                  for (final device in people) tile(device),
                  if (viewModel.canAdd) ...[
                    OutlinedButton(
                      key: const Key('add-person-button'),
                      onPressed: viewModel.isBusy
                          ? null
                          : () => _showAddPerson(context),
                      child: Text(l10n.claimsAddPerson),
                    ),
                    const SizedBox(height: AppSpacing.small),
                  ],
                  if (viewModel.canApproveClaims) ...[
                    OutlinedButton(
                      key: const Key('review-claims-button'),
                      onPressed: () => context.push(AppNavPaths.approverQueue),
                      child: Text(l10n.claimsReviewTitle),
                    ),
                    const SizedBox(height: AppSpacing.small),
                  ],
                ],
                _SectionHeading(
                  key: const Key('linked-devices-join-sync'),
                  title: l10n.linkedDevicesJoinSyncHeading,
                  help: l10n.linkedDevicesJoinSyncHelp,
                ),
                if (hasPeers) ...[
                  ElevatedButton(
                    onPressed: viewModel.isBusy ? null : viewModel.syncNow,
                    child: Text(
                      viewModel.isBusy
                          ? l10n.settingsLinkedDevicesSyncNowBusy
                          : l10n.settingsLinkedDevicesSyncNow,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                ],
                OutlinedButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : () => _scanJoinQr(context),
                  child: Text(l10n.settingsLinkedDevicesScanQr),
                ),
                ExpansionTile(
                  key: const Key('linked-devices-more-ways'),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.linkedDevicesMoreWays,
                    style: AppTypography.body,
                  ),
                  children: [
                    TextButton(
                      key: const Key('enter-code-instead'),
                      onPressed: viewModel.isBusy
                          ? null
                          : () => _enterJoinCode(context),
                      child: Text(l10n.settingsLinkedDevicesEnterCodeInstead),
                    ),
                    if (hasPeers)
                      OutlinedButton(
                        onPressed:
                            viewModel.isBusy ||
                                viewModel.connectByAddressAction == null
                            ? null
                            : () => _showConnectByAddress(context),
                        child: Text(l10n.settingsLinkedDevicesConnectByAddress),
                      ),
                  ],
                ),
              ],
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.small),
                Text(
                  viewModel.errorMessage!,
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.signal,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Asks for this device's name the first time it adds or joins, so other
  /// devices show a real name instead of "This device".
  Future<bool> _ensureDeviceName(BuildContext context) async {
    if (!viewModel.needsDeviceName) return true;
    final name = await _askDeviceName(context, initial: null);
    if (name == null) return false;
    return viewModel.setLocalDeviceName(name);
  }

  Future<void> _renameThisDevice(BuildContext context) async {
    final name = await _askDeviceName(
      context,
      initial: viewModel.localDisplayName,
    );
    if (name != null) await viewModel.setLocalDeviceName(name);
  }

  Future<String?> _askDeviceName(
    BuildContext context, {
    required String? initial,
  }) async {
    final l10n = l10nOf(context);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _DeviceNameDialog(
        initial: initial ?? defaultDeviceName(context, l10n),
      ),
    );
    final trimmed = name?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  Future<void> _showAddDevice(BuildContext context) async {
    if (!await _ensureDeviceName(context) || !context.mounted) return;
    final payload = await viewModel.startAddDevice();
    if (payload == null || !context.mounted) return;
    final l10n = l10nOf(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            // Fixed width avoids AlertDialog intrinsic-size walk into
            // QrImageView's LayoutBuilder (throws on macOS / desktop).
            return AlertDialog(
              title: Text(l10n.settingsLinkedDevicesAddDevice),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      JoinQrOfferPanel(
                        payload: payload,
                        joinCode: viewModel.activeJoinCode,
                        onCodesDontMatch: () {
                          viewModel.cancelJoinBecauseCodesDontMatch();
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      if (viewModel.pendingHostCheckCode != null) ...[
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          l10n.settingsLinkedDevicesConfirmCheckCodeBody,
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          viewModel.pendingHostCheckCode!,
                          key: const Key('join-host-check-code'),
                          style: AppTypography.sectionLabel.copyWith(
                            letterSpacing: 4,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          key: const Key('join-host-codes-match'),
                          onPressed: () {
                            viewModel.confirmHostCheckCodeMatch();
                          },
                          child: Text(l10n.settingsLinkedDevicesCodesMatch),
                        ),
                      ],
                    ],
                  ),
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
      },
    );
  }

  Future<void> _showAddPerson(BuildContext context) async {
    if (!await _ensureDeviceName(context) || !context.mounted) return;
    final l10n = l10nOf(context);
    final nameController = TextEditingController();
    final personName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.claimsAddPerson),
          content: TextField(
            key: const Key('add-person-name-field'),
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
              key: const Key('add-person-name-continue'),
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
    final role = await showDialog<LinkedDeviceRole>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.claimsAddPerson),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                key: const Key('add-person-role-claimant'),
                title: Text(l10n.linkedDevicesRoleEmployee),
                subtitle: Text(l10n.linkedDevicesRoleEmployeeHelp),
                onTap: () =>
                    Navigator.of(dialogContext).pop(LinkedDeviceRole.claimant),
              ),
              ListTile(
                key: const Key('add-person-role-approver'),
                title: Text(l10n.linkedDevicesRoleApprover),
                subtitle: Text(l10n.linkedDevicesRoleApproverHelp),
                onTap: () =>
                    Navigator.of(dialogContext).pop(LinkedDeviceRole.approver),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionCancel),
            ),
          ],
        );
      },
    );
    if (role == null || !context.mounted) return;
    final roleLabel = role == LinkedDeviceRole.approver
        ? l10n.claimsRoleApprover
        : l10n.claimsRoleClaimant;
    // Approver also gets Member so they can bookkeep (e.g. category rename
    // in the company acceptance hard case).
    final roles = role == LinkedDeviceRole.approver
        ? {LinkedDeviceRole.approver, LinkedDeviceRole.member}
        : {LinkedDeviceRole.claimant};
    final payload = await viewModel.startAddPerson(
      personDisplayName: personName,
      roles: roles,
    );
    if (payload == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            return AlertDialog(
              title: Text(l10n.claimsAddPerson),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      JoinQrOfferPanel(
                        payload: payload,
                        joinCode: viewModel.activeJoinCode,
                        subtitle: Text(
                          '$roleLabel: ${personName.trim()}',
                          style: AppTypography.metadata,
                        ),
                        onCodesDontMatch: () {
                          viewModel.cancelJoinBecauseCodesDontMatch();
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      if (viewModel.pendingHostCheckCode != null) ...[
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          l10n.settingsLinkedDevicesConfirmCheckCodeBody,
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          viewModel.pendingHostCheckCode!,
                          key: const Key('join-host-check-code'),
                          style: AppTypography.sectionLabel.copyWith(
                            letterSpacing: 4,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          key: const Key('join-host-codes-match'),
                          onPressed: () {
                            viewModel.confirmHostCheckCodeMatch();
                          },
                          child: Text(l10n.settingsLinkedDevicesCodesMatch),
                        ),
                      ],
                    ],
                  ),
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
      },
    );
  }

  Future<void> _enterJoinCode(BuildContext context) async {
    if (!await _ensureDeviceName(context) || !context.mounted) return;
    final l10n = l10nOf(context);
    String? entryError;
    final found = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.settingsLinkedDevicesEnterCodeTitle),
              content: SingleChildScrollView(
                child: JoinCodeEntryPanel(
                  errorMessage: entryError,
                  isBusy: viewModel.isBusy,
                  onSubmit: (typed) async {
                    final result = await viewModel.lookupJoinCode(typed);
                    if (!dialogContext.mounted) return;
                    if (result.isSuccess) {
                      Navigator.of(dialogContext).pop(true);
                      return;
                    }
                    // Ignore stale failures if a coalesced lookup already
                    // produced a pending success (re-entrant tap race).
                    if (viewModel.pendingJoinCodeSuccess != null) {
                      Navigator.of(dialogContext).pop(true);
                      return;
                    }
                    setState(() {
                      entryError = viewModel.joinCodeErrorMessage(
                        l10n,
                        result.error!,
                      );
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.actionCancel),
                ),
              ],
            );
          },
        );
      },
    );
    if (found == true && context.mounted) {
      await _confirmJoinCodeCheckCode(context);
    }
  }

  Future<void> _confirmJoinCodeCheckCode(BuildContext context) async {
    final l10n = l10nOf(context);
    final pending = viewModel.pendingJoinCodeSuccess;
    if (pending == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsLinkedDevicesConfirmCheckCodeTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.settingsLinkedDevicesConfirmCheckCodeBody,
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                pending.checkCode,
                key: const Key('join-code-check-code'),
                style: AppTypography.sectionLabel.copyWith(
                  letterSpacing: 4,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              key: const Key('join-codes-dont-match'),
              onPressed: () {
                viewModel.cancelJoinBecauseCodesDontMatch();
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(l10n.settingsLinkedDevicesCodesDontMatch),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.settingsLinkedDevicesCodesMatch),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      await viewModel.confirmJoinCodeMatch();
    }
  }

  Future<void> _scanJoinQr(BuildContext context) async {
    if (!await _ensureDeviceName(context) || !context.mounted) return;
    final l10n = l10nOf(context);
    JoinQrPayload? payload;
    final scanner = joinQrScanner;
    if (scanner != null) {
      payload = await scanner.scanOnce();
    } else {
      payload = await Navigator.of(context).push<JoinQrPayload>(
        MaterialPageRoute(builder: (_) => const JoinQrScanPage()),
      );
    }
    if (payload == null || !context.mounted) return;

    final validated = viewModel.validateScannedJoin(payload);
    if (validated == null) {
      if (!context.mounted) return;
      final message =
          viewModel.errorMessage ?? l10n.settingsLinkedDevicesJoinExpired;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    // QRs carry their join code: run the same lookup, check code and
    // handshake as "Enter code instead", so the inviting device learns this
    // device's certificate and the two can sync.
    final embeddedCode = validated.joinCode;
    if (embeddedCode != null) {
      final result = await viewModel.lookupJoinCode(embeddedCode);
      if (!context.mounted) return;
      if (result.isSuccess || viewModel.pendingJoinCodeSuccess != null) {
        await _confirmJoinCodeCheckCode(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.joinCodeErrorMessage(l10n, result.error!)),
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsLinkedDevicesConfirmCheckCodeTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.settingsLinkedDevicesConfirmCheckCodeBody,
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                validated.checkCode,
                key: const Key('join-qr-scanned-check-code'),
                style: AppTypography.sectionLabel.copyWith(
                  letterSpacing: 4,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              key: const Key('join-codes-dont-match'),
              onPressed: () {
                viewModel.cancelJoinBecauseCodesDontMatch();
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(l10n.settingsLinkedDevicesCodesDontMatch),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.settingsLinkedDevicesCodesMatch),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    await viewModel.registerHostFromScannedJoin(validated);
  }

  Future<void> _showConnectByAddress(BuildContext context) async {
    final l10n = l10nOf(context);
    final peers = viewModel.devices
        .where((d) => d.isActive && d.deviceId != viewModel.localDeviceId)
        .toList();
    if (peers.isEmpty) return;

    var selectedId = peers.first.deviceId;
    final hostController = TextEditingController();
    final portController = TextEditingController(text: '0');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.settingsLinkedDevicesConnectByAddressTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.settingsLinkedDevicesConnectByAddressBody,
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  DropdownButtonFormField<String>(
                    initialValue: selectedId,
                    decoration: InputDecoration(
                      labelText: l10n.settingsLinkedDevicesPeer,
                    ),
                    items: [
                      for (final peer in peers)
                        DropdownMenuItem(
                          value: peer.deviceId,
                          child: Text(peer.displayName),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedId = value);
                    },
                  ),
                  TextField(
                    controller: hostController,
                    decoration: InputDecoration(
                      labelText: l10n.settingsLinkedDevicesHost,
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  TextField(
                    controller: portController,
                    decoration: InputDecoration(
                      labelText: l10n.settingsLinkedDevicesPort,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.actionCancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.settingsLinkedDevicesSaveAddress),
                ),
              ],
            );
          },
        );
      },
    );

    final host = hostController.text.trim();
    final port = int.tryParse(portController.text.trim());
    hostController.dispose();
    portController.dispose();
    if (saved != true || host.isEmpty || port == null || port <= 0) return;
    if (!context.mounted) return;
    await viewModel.connectByAddress(
      peerDeviceId: selectedId,
      host: host,
      port: port,
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

/// "Name this device": owns its text controller so it outlives the dialog's
/// closing animation.
class _DeviceNameDialog extends StatefulWidget {
  const _DeviceNameDialog({required this.initial});

  final String initial;

  @override
  State<_DeviceNameDialog> createState() => _DeviceNameDialogState();
}

class _DeviceNameDialogState extends State<_DeviceNameDialog> {
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
      title: Text(l10n.linkedDevicesNameTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.linkedDevicesNameHelp, style: AppTypography.metadata),
          const SizedBox(height: AppSpacing.small),
          TextField(
            key: const Key('device-name-field'),
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.linkedDevicesNameLabel),
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
          key: const Key('device-name-save'),
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({super.key, required this.title, required this.help});

  final String title;
  final String help;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.medium,
        bottom: AppSpacing.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.base),
          Text(help, style: AppTypography.metadata),
        ],
      ),
    );
  }
}

class _LinkedDeviceTile extends StatelessWidget {
  const _LinkedDeviceTile({
    required this.device,
    required this.isLocal,
    required this.canRemove,
    required this.enabled,
    required this.onRemove,
    required this.onRename,
  });

  final LinkedDevice device;
  final bool isLocal;
  final bool canRemove;
  final bool enabled;
  final VoidCallback? onRemove;
  final VoidCallback? onRename;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final roleLabel = linkedDeviceRoleLabel(l10n, device.roles);
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

    final name = device.personDisplayName ?? device.displayName;
    final title = isLocal ? l10n.linkedDevicesThisDevice(name) : name;

    return ListTile(
      key: isLocal ? const Key('linked-device-this-device') : null,
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
          : onRename != null
          ? TextButton(
              key: const Key('rename-this-device'),
              onPressed: enabled ? onRename : null,
              child: Text(l10n.actionRename),
            )
          : null,
    );
  }
}

/// Role in plain words: what this person or device does in these books.
String linkedDeviceRoleLabel(
  AppLocalizations l10n,
  Set<LinkedDeviceRole> roles,
) {
  if (roles.contains(LinkedDeviceRole.owner)) {
    return l10n.linkedDevicesRoleOwner;
  }
  if (roles.contains(LinkedDeviceRole.approver)) {
    return l10n.linkedDevicesRoleApprover;
  }
  if (roles.contains(LinkedDeviceRole.claimant) &&
      !roles.contains(LinkedDeviceRole.member)) {
    return l10n.linkedDevicesRoleEmployee;
  }
  return l10n.linkedDevicesRoleBookkeeper;
}

/// The name a device suggests for itself before the user types one. iOS
/// doesn't let apps read the phone's own name, so this is only the type.
String defaultDeviceName(BuildContext context, AppLocalizations l10n) {
  final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS =>
      tablet
          ? l10n.linkedDevicesDefaultNameIpad
          : l10n.linkedDevicesDefaultNameIphone,
    TargetPlatform.android =>
      tablet
          ? l10n.linkedDevicesDefaultNameAndroidTablet
          : l10n.linkedDevicesDefaultNameAndroidPhone,
    TargetPlatform.windows => l10n.linkedDevicesDefaultNameWindows,
    TargetPlatform.linux => l10n.linkedDevicesDefaultNameLinux,
    _ => l10n.linkedDevicesDefaultNameMac,
  };
}
