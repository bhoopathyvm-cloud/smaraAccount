import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/models/exchange_rate_provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../view_models/settings_view_model.dart';

/// Views are lean. No business logic, no Repository calls. Listen to the
/// ViewModel; render what it exposes (smara-tech-guidelines.md).
class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.viewModel,
    this.onOpenPayees,
    this.onOpenRecurringTemplates,
  });

  final SettingsViewModel viewModel;

  /// payees-and-spending-memory: opens the minimal payee CRUD screen.
  final VoidCallback? onOpenPayees;

  /// recurring-templates: opens the recurring template CRUD screen.
  final VoidCallback? onOpenRecurringTemplates;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              SwitchListTile(
                title: const Text('Fetch reference exchange rates'),
                subtitle: Text(
                  'Shows an indicative market rate next to the '
                  'destination amount on cross-currency transfers, for '
                  'comparison only - never used to fill in the amount.',
                  style: AppTypography.metadata,
                ),
                value: viewModel.referenceRateLookupEnabled,
                onChanged: viewModel.setReferenceRateLookupEnabled,
              ),
              const SizedBox(height: AppSpacing.large),
              DropdownButtonFormField<ExchangeRateProvider>(
                initialValue: viewModel.selectedProvider,
                decoration: const InputDecoration(labelText: 'Rate provider'),
                items: [
                  for (final provider in ExchangeRateProvider.values)
                    DropdownMenuItem(
                      value: provider,
                      child: Text(provider.displayName),
                    ),
                ],
                onChanged: viewModel.referenceRateLookupEnabled
                    ? (provider) {
                        if (provider != null) {
                          viewModel.setSelectedProvider(provider);
                        }
                      }
                    : null,
              ),
              const SizedBox(height: AppSpacing.xLarge),
              Text('Backup', style: AppTypography.sectionLabel),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Save an encrypted copy of your books to a location you '
                'choose, or restore from one. This is separate from your '
                'recovery phrase or keystore file, which back up your '
                'signing key, not your books.',
                style: AppTypography.metadata,
              ),
              const SizedBox(height: AppSpacing.medium),
              ElevatedButton(
                onPressed: viewModel.isBackingUp
                    ? null
                    : () => _showSaveBackupDialog(context, viewModel),
                child: const Text('Save backup'),
              ),
              const SizedBox(height: AppSpacing.small),
              OutlinedButton(
                onPressed: viewModel.isRestoring
                    ? null
                    : () => _showRestoreBackupDialog(context, viewModel),
                child: const Text('Restore backup'),
              ),
              const SizedBox(height: AppSpacing.xLarge),
              Text('Lock', style: AppTypography.sectionLabel),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Require a PIN, or biometrics where available, to open '
                'the app.',
                style: AppTypography.metadata,
              ),
              const SizedBox(height: AppSpacing.medium),
              SwitchListTile(
                title: const Text('Require unlock to open the app'),
                value: viewModel.isAppLockEnabled,
                onChanged: (value) => value
                    ? _showSetPinDialog(context, viewModel)
                    : viewModel.disableAppLock(),
              ),
              if (viewModel.isAppLockEnabled) ...[
                OutlinedButton(
                  onPressed: () => _showChangePinDialog(context, viewModel),
                  child: const Text('Change PIN'),
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<int>(
                  initialValue: viewModel.appLockTimeoutMinutes,
                  decoration: const InputDecoration(labelText: 'Lock after'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Immediately')),
                    DropdownMenuItem(value: 1, child: Text('1 minute')),
                    DropdownMenuItem(value: 5, child: Text('5 minutes')),
                    DropdownMenuItem(value: 15, child: Text('15 minutes')),
                  ],
                  onChanged: (minutes) {
                    if (minutes != null) {
                      viewModel.setAppLockTimeoutMinutes(minutes);
                    }
                  },
                ),
                if (viewModel.isBiometricAvailable) ...[
                  const SizedBox(height: AppSpacing.medium),
                  SwitchListTile(
                    title: const Text('Also allow biometrics'),
                    value: viewModel.isBiometricEnabled,
                    onChanged: viewModel.setBiometricEnabled,
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.medium),
              if (viewModel.isSnapshotHidingAvailable)
                SwitchListTile(
                  title: const Text('Hide balances in the app switcher'),
                  subtitle: Text(
                    'Obscures this screen when you switch to another app, '
                    "so it isn't visible at a glance in the app switcher.",
                    style: AppTypography.metadata,
                  ),
                  value: viewModel.isSnapshotHidingEnabled,
                  onChanged: viewModel.setSnapshotHidingEnabled,
                )
              else
                Text(
                  "Hiding balances in the app switcher isn't available on "
                  'this platform.',
                  style: AppTypography.metadata,
                ),
              const SizedBox(height: AppSpacing.xLarge),
              Text('Payees', style: AppTypography.sectionLabel),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Remembered payee names and their default category and '
                'account, suggested by autocomplete when recording a '
                'transaction.',
                style: AppTypography.metadata,
              ),
              const SizedBox(height: AppSpacing.medium),
              OutlinedButton(
                onPressed: onOpenPayees,
                child: const Text('Manage payees'),
              ),
              const SizedBox(height: AppSpacing.xLarge),
              Text('Recurring templates', style: AppTypography.sectionLabel),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Bills or income that repeat monthly, like rent or a '
                'paycheck. A due template shows up on Home for you to '
                'record with one tap - never posted automatically.',
                style: AppTypography.metadata,
              ),
              const SizedBox(height: AppSpacing.medium),
              OutlinedButton(
                onPressed: onOpenRecurringTemplates,
                child: const Text('Manage recurring templates'),
              ),
              const SizedBox(height: AppSpacing.xLarge),
              Text('About', style: AppTypography.sectionLabel),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Why we don’t edit old entries',
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'When you fix a mistake, we keep the old line and add a '
                'correction next to it instead of changing what you already '
                'entered. That way your history always shows exactly what '
                'happened and when you fixed it — nothing quietly '
                'changes behind your back.',
                style: AppTypography.metadata,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showSaveBackupDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final passphraseController = TextEditingController();
    String? statusMessage;
    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Save backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose a passphrase to protect this backup. There is no '
                'way to recover it if you forget the passphrase.',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: passphraseController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Passphrase'),
              ),
              if (statusMessage != null) ...[
                const SizedBox(height: AppSpacing.medium),
                Text(
                  statusMessage!,
                  style: AppTypography.body.copyWith(color: AppColors.signal),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final passphrase = passphraseController.text;
                      if (passphrase.trim().isEmpty) {
                        setDialogState(
                          () => statusMessage = 'Enter a passphrase.',
                        );
                        return;
                      }

                      setDialogState(() {
                        isSaving = true;
                        statusMessage = null;
                      });
                      final contents = await viewModel.exportBackup(
                        passphrase: passphrase,
                      );
                      if (contents == null) {
                        setDialogState(() {
                          isSaving = false;
                          statusMessage = viewModel.backupErrorMessage;
                        });
                        return;
                      }

                      final fileName =
                          'smara-backup-'
                          '${DateTime.now().millisecondsSinceEpoch}.smarabackup';
                      await FilePicker.platform.saveFile(
                        dialogTitle: 'Save backup',
                        fileName: fileName,
                        bytes: Uint8List.fromList(utf8.encode(contents)),
                      );
                      if (dialogContext.mounted) {
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

  Future<void> _showRestoreBackupDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final pageContext = context;
    final passphraseController = TextEditingController();
    PlatformFile? pickedFile;
    String? statusMessage;
    var isBusy = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Restore backup'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'This replaces everything currently in this app with the '
                  'backup — it does not merge. Choose a backup file and '
                  'enter the passphrase you protected it with.',
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.medium),
                OutlinedButton(
                  onPressed: isBusy
                      ? null
                      : () async {
                          final result = await FilePicker.platform.pickFiles(
                            withData: true,
                          );
                          final file = result?.files.single;
                          if (file != null) {
                            setDialogState(() {
                              pickedFile = file;
                              statusMessage = null;
                            });
                          }
                        },
                  child: Text(
                    pickedFile == null
                        ? 'Choose backup file'
                        : pickedFile!.name,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: passphraseController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Passphrase'),
                ),
                if (statusMessage != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    statusMessage!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isBusy
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isBusy
                  ? null
                  : () async {
                      final file = pickedFile;
                      final bytes = file?.bytes;
                      final passphrase = passphraseController.text;
                      if (file == null || bytes == null) {
                        setDialogState(
                          () => statusMessage = 'Choose a backup file first.',
                        );
                        return;
                      }
                      if (passphrase.trim().isEmpty) {
                        setDialogState(
                          () =>
                              statusMessage = "Enter the backup's passphrase.",
                        );
                        return;
                      }

                      final confirmed = await confirmDestructiveAction(
                        context: dialogContext,
                        title: 'Replace your local books?',
                        message:
                            'Everything currently in this app will be '
                            'replaced by the backup. This cannot be undone.',
                        confirmLabel: 'Replace',
                      );
                      if (!confirmed) return;

                      setDialogState(() => isBusy = true);
                      final ok = await viewModel.restoreBackup(
                        fileContents: utf8.decode(bytes),
                        passphrase: passphrase,
                      );
                      if (ok) {
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        if (pageContext.mounted) {
                          _showRestoredSuccessDialog(pageContext);
                        }
                      } else {
                        setDialogState(() {
                          isBusy = false;
                          statusMessage = viewModel.backupErrorMessage;
                        });
                      }
                    },
              child: const Text('Restore'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSetPinDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? statusMessage;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Set a PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'PIN'),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Confirm PIN'),
              ),
              if (statusMessage != null) ...[
                const SizedBox(height: AppSpacing.medium),
                Text(
                  statusMessage!,
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
                final pin = pinController.text;
                if (pin.length < 4) {
                  setDialogState(
                    () => statusMessage = 'PIN must be at least 4 digits.',
                  );
                  return;
                }
                if (pin != confirmController.text) {
                  setDialogState(() => statusMessage = "PINs don't match.");
                  return;
                }
                await viewModel.enableAppLock(pin);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Set PIN'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePinDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmController = TextEditingController();
    String? statusMessage;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: currentPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Current PIN'),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: newPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'New PIN'),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Confirm new PIN'),
              ),
              if (statusMessage != null) ...[
                const SizedBox(height: AppSpacing.medium),
                Text(
                  statusMessage!,
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
                final newPin = newPinController.text;
                if (newPin.length < 4) {
                  setDialogState(
                    () => statusMessage = 'PIN must be at least 4 digits.',
                  );
                  return;
                }
                if (newPin != confirmController.text) {
                  setDialogState(() => statusMessage = "PINs don't match.");
                  return;
                }
                final changed = await viewModel.changePin(
                  currentPin: currentPinController.text,
                  newPin: newPin,
                );
                if (!changed) {
                  setDialogState(
                    () => statusMessage = 'Current PIN is incorrect.',
                  );
                  return;
                }
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Change PIN'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoredSuccessDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Backup restored'),
        content: const Text(
          'Your books have been restored. Close and reopen the app to '
          "continue — it can't keep going until you do.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (Platform.isAndroid || Platform.isIOS) {
                SystemNavigator.pop();
              } else {
                exit(0);
              }
            },
            child: const Text('Close app'),
          ),
        ],
      ),
    );
  }
}
