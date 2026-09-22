import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/settings_view_model.dart';

/// Settings screen exporting a device migration bundle: books and signing
/// key together, in one passphrase-protected file, for moving to a new
/// device in one step (spec: `device-migration-bundle`). Reachable at any
/// time, optional, alongside the recovery phrase and keystore file.
class DeviceMigrationBundleExportView extends StatefulWidget {
  const DeviceMigrationBundleExportView({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  State<DeviceMigrationBundleExportView> createState() =>
      _DeviceMigrationBundleExportViewState();
}

class _DeviceMigrationBundleExportViewState
    extends State<DeviceMigrationBundleExportView> {
  final _passphraseController = TextEditingController();
  String? _statusMessage;

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final l10n = l10nOf(context);
    final passphrase = _passphraseController.text;
    final passphraseError = widget.viewModel.passphraseValidationError(
      passphrase,
    );
    if (passphraseError != null) {
      setState(() => _statusMessage = localizeError(l10n, passphraseError));
      return;
    }

    setState(() => _statusMessage = null);
    final contents = await widget.viewModel.exportDeviceMigrationBundle(
      passphrase: passphrase,
    );
    if (!mounted) return;
    if (contents == null) {
      setState(
        () => _statusMessage = widget.viewModel.backupErrorMessageFor(l10n),
      );
      return;
    }

    final fileName =
        'smara-device-migration-'
        '${DateTime.now().millisecondsSinceEpoch}.smarabundle';
    await FilePicker.saveFile(
      dialogTitle: l10n.exportDeviceMigrationBundle,
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(contents)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.deviceMigrationBundleExportTitle,
          style: AppTypography.headerTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.signal),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMedium,
                    ),
                  ),
                  child: Text(
                    l10n.deviceMigrationBundleExportBlurb,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                TextField(
                  controller: _passphraseController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.keystorePassphrase,
                  ),
                ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    _statusMessage!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.xLarge),
                ElevatedButton(
                  onPressed: widget.viewModel.isExportingBundle
                      ? null
                      : _export,
                  child: Text(l10n.exportDeviceMigrationBundle),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
