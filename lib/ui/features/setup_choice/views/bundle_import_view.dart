import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../view_models/bundle_import_view_model.dart';

/// Startup Import From Backup screen (spec: `device-migration-bundle`).
/// Reached only from [SetupChoiceView], before any signing identity
/// exists on this device.
class BundleImportView extends StatefulWidget {
  const BundleImportView({super.key, required this.viewModel});

  final BundleImportViewModel viewModel;

  @override
  State<BundleImportView> createState() => _BundleImportViewState();
}

class _BundleImportViewState extends State<BundleImportView> {
  PlatformFile? _pickedFile;
  String? _localError;
  final _passphraseController = TextEditingController();

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final file = await FilePicker.pickFile();
    if (file != null) setState(() => _pickedFile = file);
  }

  Future<void> _import() async {
    final l10n = l10nOf(context);
    final file = _pickedFile;
    if (file == null) {
      setState(() => _localError = l10n.chooseDeviceMigrationBundleFileFirst);
      return;
    }
    setState(() => _localError = null);

    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.replaceBooksTitle,
      message: l10n.importDeviceMigrationBundleBlurb,
      confirmLabel: l10n.actionImport,
    );
    if (!confirmed || !mounted) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;
    final ok = await widget.viewModel.importBundle(
      fileContents: utf8.decode(bytes),
      passphrase: _passphraseController.text,
    );
    if (!mounted) return;
    if (ok) {
      _showImportedSuccessDialog(context);
    }
  }

  void _showImportedSuccessDialog(BuildContext context) {
    final l10n = l10nOf(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deviceMigrationBundleImported),
        content: Text(l10n.deviceMigrationBundleImportedBody),
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

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.importDeviceMigrationBundleTitle,
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
                Text(
                  l10n.importDeviceMigrationBundleBlurb,
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.large),
                OutlinedButton(
                  onPressed: widget.viewModel.isImporting ? null : _pickFile,
                  child: Text(
                    _pickedFile == null
                        ? l10n.actionChooseFile
                        : _pickedFile!.name,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _passphraseController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.keystorePassphrase,
                  ),
                ),
                if ((_localError ?? widget.viewModel.errorMessageFor(l10n)) !=
                    null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    _localError ?? widget.viewModel.errorMessageFor(l10n)!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.xLarge),
                ElevatedButton(
                  onPressed: widget.viewModel.isImporting ? null : _import,
                  child: Text(l10n.actionImport),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
