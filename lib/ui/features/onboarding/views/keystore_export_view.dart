import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/recovery_phrase_setup_view_model.dart';

/// Optional second onboarding step: an additional, passphrase-protected
/// keystore file backup (spec: "Optional keystore file export"). Never
/// blocks progress - Skip and Export both continue to confirmation.
class KeystoreExportView extends StatefulWidget {
  const KeystoreExportView({
    super.key,
    required this.viewModel,
    required this.onContinue,
  });

  final RecoveryPhraseSetupViewModel viewModel;
  final VoidCallback onContinue;

  @override
  State<KeystoreExportView> createState() => _KeystoreExportViewState();
}

class _KeystoreExportViewState extends State<KeystoreExportView> {
  final _passphraseController = TextEditingController();
  String? _statusMessage;
  bool _isExporting = false;

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final passphrase = _passphraseController.text;
    if (passphrase.trim().isEmpty) {
      setState(() => _statusMessage = l10nOf(context).enterPassphraseToProtect);
      return;
    }

    setState(() {
      _isExporting = true;
      _statusMessage = null;
    });

    try {
      final contents = await widget.viewModel.exportKeystoreFile(
        passphrase: passphrase,
      );
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'smara-keystore-${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File(p.join(directory.path, fileName));
      await file.writeAsString(contents);
      widget.viewModel.recordKeystoreExportPath(file.path);
      setState(() {
        _isExporting = false;
        _statusMessage = l10nOf(context).savedToPath(file.path);
      });
    } catch (_) {
      setState(() {
        _isExporting = false;
        _statusMessage = l10nOf(context).keystoreExportFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.optionalBackupFile, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.keystoreExportBlurb, style: AppTypography.body),
            const SizedBox(height: AppSpacing.large),
            TextField(
              controller: _passphraseController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.keystorePassphrase),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: AppSpacing.medium),
              Text(
                _statusMessage!,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xLarge),
            ElevatedButton(
              onPressed: _isExporting ? null : _export,
              child: Text(l10n.exportKeystoreFile),
            ),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton(
              onPressed: widget.onContinue,
              child: Text(
                widget.viewModel.keystoreExportPath == null
                    ? l10n.actionSkip
                    : l10n.actionContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
