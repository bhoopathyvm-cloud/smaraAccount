import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/models/exchange_rate_provider.dart';
import '../../../../domain/models/quote_provider.dart';
import '../../../../domain/models/research_tool.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../../../../l10n/l10n.dart';
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
        title: Text(l10nOf(context).settingsTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          viewModel,
          if (viewModel.localeController != null) viewModel.localeController!,
        ]),
        builder: (context, _) {
          final l10n = l10nOf(context);
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              if (viewModel.localeController != null) ...[
                Text(l10n.settingsLanguage, style: AppTypography.sectionLabel),
                const SizedBox(height: AppSpacing.base),
                DropdownButtonFormField<String>(
                  initialValue:
                      viewModel.localeController!.overrideLocale == null
                      ? kSystemLocalePreference
                      : tagFromLocale(
                          viewModel.localeController!.overrideLocale!,
                        ),
                  decoration: InputDecoration(
                    labelText: l10n.settingsLanguage,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: kSystemLocalePreference,
                      child: Text(l10n.settingsLanguageSystem),
                    ),
                    for (final tag in kSupportedLocaleTags)
                      DropdownMenuItem(
                        value: tag,
                        child: Text(endonymForLocaleTag(tag)),
                      ),
                  ],
                  onChanged: (tag) {
                    if (tag != null) {
                      viewModel.localeController!.setPreference(tag);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xLarge),
              ],
              SwitchListTile(
                title: Text(l10n.settingsFetchFxRates),
                subtitle: Text(
                  l10n.settingsFetchFxRatesSubtitle,
                  style: AppTypography.metadata,
                ),
                value: viewModel.referenceRateLookupEnabled,
                onChanged: viewModel.setReferenceRateLookupEnabled,
              ),
              const SizedBox(height: AppSpacing.large),
              DropdownButtonFormField<ExchangeRateProvider>(
                initialValue: viewModel.selectedProvider,
                decoration: InputDecoration(labelText: l10n.settingsRateProvider),
                items: [
                  for (final provider in ExchangeRateProvider.values)
                    DropdownMenuItem(
                      value: provider,
                      child: Text(_exchangeRateProviderLabel(l10n, provider)),
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
              SwitchListTile(
                title: Text(l10n.settingsFetchMarketPrices),
                subtitle: Text(
                  l10n.settingsFetchMarketPricesSubtitle,
                  style: AppTypography.metadata,
                ),
                value: viewModel.marketPriceFetchEnabled,
                onChanged: viewModel.setMarketPriceFetchEnabled,
              ),
              const SizedBox(height: AppSpacing.large),
              DropdownButtonFormField<QuoteProvider>(
                initialValue: viewModel.selectedQuoteProvider,
                decoration: InputDecoration(
                  labelText: l10n.settingsMarketPriceProvider,
                ),
                items: [
                  for (final provider in QuoteProvider.values)
                    DropdownMenuItem(
                      value: provider,
                      child: Text(_quoteProviderLabel(l10n, provider)),
                    ),
                ],
                onChanged: viewModel.marketPriceFetchEnabled
                    ? (provider) {
                        if (provider != null) {
                          viewModel.setSelectedQuoteProvider(provider);
                        }
                      }
                    : null,
              ),
              const SizedBox(height: AppSpacing.xLarge),
              DropdownButtonFormField<ResearchTool>(
                initialValue: viewModel.selectedResearchTool,
                decoration: InputDecoration(
                  labelText: l10n.settingsFavouriteResearchTool,
                ),
                items: [
                  for (final tool in ResearchTool.values)
                    DropdownMenuItem(
                      value: tool,
                      child: Text(_researchToolLabel(l10n, tool)),
                    ),
                ],
                onChanged: (tool) {
                  if (tool != null) {
                    viewModel.setSelectedResearchTool(tool);
                  }
                },
              ),
              Text(
                l10n.settingsFavouriteResearchToolSubtitle,
                style: AppTypography.metadata,
              ),
              const SizedBox(height: AppSpacing.xLarge),
              Text(l10n.settingsBackup, style: AppTypography.sectionLabel),
              const SizedBox(height: AppSpacing.base),
              Text(
                l10n.settingsBackupBlurb,
                style: AppTypography.metadata,
              ),
              const SizedBox(height: AppSpacing.medium),
              ElevatedButton(
                onPressed: viewModel.isBackingUp
                    ? null
                    : () => _showSaveBackupDialog(context, viewModel),
                child: Text(l10n.actionSaveBackup),
              ),
              const SizedBox(height: AppSpacing.small),
              OutlinedButton(
                onPressed: viewModel.isRestoring
                    ? null
                    : () => _showRestoreBackupDialog(context, viewModel),
                child: Text(l10n.actionRestoreBackup),
              ),
              const SizedBox(height: AppSpacing.xLarge),
              Text(l10n.settingsLock, style: AppTypography.sectionLabel),
              const SizedBox(height: AppSpacing.base),
              Text(
                l10n.settingsLockBlurb,
                style: AppTypography.metadata,
              ),
              const SizedBox(height: AppSpacing.medium),
              SwitchListTile(
                title: Text(l10n.settingsRequireUnlock),
                value: viewModel.isAppLockEnabled,
                onChanged: (value) => value
                    ? _showSetPinDialog(context, viewModel)
                    : viewModel.disableAppLock(),
              ),
              if (viewModel.isAppLockEnabled) ...[
                OutlinedButton(
                  onPressed: () => _showChangePinDialog(context, viewModel),
                  child: Text(l10n.actionChangePin),
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<int>(
                  initialValue: viewModel.appLockTimeoutMinutes,
                  decoration: InputDecoration(labelText: l10n.settingsLockAfter),
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text(l10n.settingsLockImmediately),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(l10n.settingsLock1Minute),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text(l10n.settingsLock5Minutes),
                    ),
                    DropdownMenuItem(
                      value: 15,
                      child: Text(l10n.settingsLock15Minutes),
                    ),
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
                    title: Text(l10n.settingsAllowBiometrics),
                    value: viewModel.isBiometricEnabled,
                    onChanged: viewModel.setBiometricEnabled,
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.medium),
              if (viewModel.isSnapshotHidingAvailable)
                SwitchListTile(
                  title: Text(l10n.settingsHideSnapshot),
                  subtitle: Text(
                    l10n.settingsHideSnapshotSubtitle,
                    style: AppTypography.metadata,
                  ),
                  value: viewModel.isSnapshotHidingEnabled,
                  onChanged: viewModel.setSnapshotHidingEnabled,
                )
              else
                Text(
                  l10n.settingsHideSnapshotUnavailable,
                  style: AppTypography.metadata,
                ),
              const SizedBox(height: AppSpacing.xLarge),
              Text(l10n.settingsPayees, style: AppTypography.sectionLabel),
              const SizedBox(height: AppSpacing.base),
              Text(
                l10n.settingsPayeesBlurb,
                style: AppTypography.metadata,
              ),
              const SizedBox(height: AppSpacing.medium),
              OutlinedButton(
                onPressed: onOpenPayees,
                child: Text(l10n.settingsManagePayees),
              ),
              const SizedBox(height: AppSpacing.xLarge),
              Text(l10n.settingsRecurring, style: AppTypography.sectionLabel),
              const SizedBox(height: AppSpacing.base),
              Text(
                l10n.settingsRecurringBlurb,
                style: AppTypography.metadata,
              ),
              const SizedBox(height: AppSpacing.medium),
              OutlinedButton(
                onPressed: onOpenRecurringTemplates,
                child: Text(l10n.settingsManageRecurring),
              ),
              const SizedBox(height: AppSpacing.xLarge),
              Text(l10n.settingsAbout, style: AppTypography.sectionLabel),
              const SizedBox(height: AppSpacing.base),
              Text(
                l10n.whyWeDontEdit,
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                l10n.whyWeDontEditBody,
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
    final l10n = l10nOf(context);
    final passphraseController = TextEditingController();
    String? statusMessage;
    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.actionSaveBackup),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.choosePassphraseTitle,
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: passphraseController,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.keystorePassphrase),
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
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final passphrase = passphraseController.text;
                      if (passphrase.trim().isEmpty) {
                        setDialogState(
                          () => statusMessage = l10n.validationPassphraseRequired,
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
                        dialogTitle: l10n.actionSaveBackup,
                        fileName: fileName,
                        bytes: Uint8List.fromList(utf8.encode(contents)),
                      );
                      if (dialogContext.mounted) {
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

  Future<void> _showRestoreBackupDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final l10n = l10nOf(context);
    final pageContext = context;
    final passphraseController = TextEditingController();
    PlatformFile? pickedFile;
    String? statusMessage;
    var isBusy = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.actionRestoreBackup),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.restoreBackupBlurb,
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
                        ? l10n.actionChooseFile
                        : pickedFile!.name,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: passphraseController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.keystorePassphrase),
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
              child: Text(l10n.actionCancel),
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
                          () => statusMessage = l10n.chooseBackupFileFirst,
                        );
                        return;
                      }
                      if (passphrase.trim().isEmpty) {
                        setDialogState(
                          () => statusMessage = l10n.validationPassphraseRequired,
                        );
                        return;
                      }

                      final confirmed = await confirmDestructiveAction(
                        context: dialogContext,
                        title: l10n.replaceBooksTitle,
                        message: l10n.replaceBooksBody,
                        confirmLabel: l10n.actionReplace,
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
              child: Text(l10n.actionRestore),
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
    final l10n = l10nOf(context);
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? statusMessage;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.setPinTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.pinLabel),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.confirmPin),
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
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final pin = pinController.text;
                if (pin.length < 4) {
                  setDialogState(
                    () => statusMessage = l10n.validationPinMinLength,
                  );
                  return;
                }
                if (pin != confirmController.text) {
                  setDialogState(
                    () => statusMessage = l10n.validationPinsDoNotMatch,
                  );
                  return;
                }
                await viewModel.enableAppLock(pin);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(l10n.actionSetPin),
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
    final l10n = l10nOf(context);
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmController = TextEditingController();
    String? statusMessage;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.actionChangePin),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: currentPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.currentPin),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: newPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.newPin),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.confirmNewPin),
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
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPin = newPinController.text;
                if (newPin.length < 4) {
                  setDialogState(
                    () => statusMessage = l10n.validationPinMinLength,
                  );
                  return;
                }
                if (newPin != confirmController.text) {
                  setDialogState(
                    () => statusMessage = l10n.validationPinsDoNotMatch,
                  );
                  return;
                }
                final changed = await viewModel.changePin(
                  currentPin: currentPinController.text,
                  newPin: newPin,
                );
                if (!changed) {
                  setDialogState(
                    () => statusMessage = l10n.validationWrongPin,
                  );
                  return;
                }
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(l10n.actionChangePin),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoredSuccessDialog(BuildContext context) {
    final l10n = l10nOf(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.backupRestored),
        content: Text(l10n.backupRestoredBody),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (Platform.isAndroid || Platform.isIOS) {
                SystemNavigator.pop();
              } else {
                exit(0);
              }
            },
            child: Text(l10n.actionCloseApp),
          ),
        ],
      ),
    );
  }
}

String _exchangeRateProviderLabel(
  AppLocalizations l10n,
  ExchangeRateProvider provider,
) {
  return switch (provider) {
    ExchangeRateProvider.frankfurter => l10n.providerFrankfurter,
    ExchangeRateProvider.openErApi => l10n.providerOpenErApi,
  };
}

String _quoteProviderLabel(AppLocalizations l10n, QuoteProvider provider) {
  return switch (provider) {
    QuoteProvider.stooq => l10n.providerStooq,
    QuoteProvider.yahooFinance => l10n.providerYahooFinance,
  };
}

String _researchToolLabel(AppLocalizations l10n, ResearchTool tool) {
  return switch (tool) {
    ResearchTool.chatGpt => l10n.researchChatGpt,
    ResearchTool.claude => l10n.researchClaude,
    ResearchTool.gemini => l10n.researchGemini,
    ResearchTool.metaAi => l10n.researchMetaAi,
  };
}
