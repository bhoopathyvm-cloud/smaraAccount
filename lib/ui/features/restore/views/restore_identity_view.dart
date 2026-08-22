import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/restore_identity_view_model.dart';

/// Shown when the database already has a signing identity but this
/// device's secure storage has no matching private key (spec:
/// "Recoverable Reinstall or Device Migration" - the reinstall/new-device
/// path). Offers restoring from a saved recovery phrase or an encrypted
/// keystore file; never re-signs or alters any entry.
class RestoreIdentityView extends StatefulWidget {
  const RestoreIdentityView({
    super.key,
    required this.viewModel,
    required this.onRestored,
    required this.onNoRecoveryMaterial,
  });

  final RestoreIdentityViewModel viewModel;
  final VoidCallback onRestored;

  /// Spec: "True Key-Loss Migration" - the disaster-recovery escape
  /// hatch for when neither the recovery phrase nor the keystore file is
  /// available.
  final VoidCallback onNoRecoveryMaterial;

  @override
  State<RestoreIdentityView> createState() => _RestoreIdentityViewState();
}

enum _RestoreMode { phrase, keystore }

class _RestoreIdentityViewState extends State<RestoreIdentityView> {
  _RestoreMode _mode = _RestoreMode.phrase;
  final _phraseController = TextEditingController();
  final _keystoreController = TextEditingController();
  final _passphraseController = TextEditingController();

  @override
  void dispose() {
    _phraseController.dispose();
    _keystoreController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = _mode == _RestoreMode.phrase
        ? await widget.viewModel.restoreFromPhrase(_phraseController.text)
        : await widget.viewModel.restoreFromKeystore(
            fileContents: _keystoreController.text,
            passphrase: _passphraseController.text,
          );
    if (success) widget.onRestored();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.restoreTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.restoreBlurb, style: AppTypography.body),
                const SizedBox(height: AppSpacing.large),
                SegmentedButton<_RestoreMode>(
                  segments: [
                    ButtonSegment(
                      value: _RestoreMode.phrase,
                      label: Text(l10n.recoveryPhrase24),
                    ),
                    ButtonSegment(
                      value: _RestoreMode.keystore,
                      label: Text(l10n.keystoreFile),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) =>
                      setState(() => _mode = selection.first),
                ),
                const SizedBox(height: AppSpacing.large),
                if (_mode == _RestoreMode.phrase)
                  TextField(
                    controller: _phraseController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.recoveryPhrase24,
                    ),
                  )
                else ...[
                  TextField(
                    controller: _keystoreController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.keystoreFileContents,
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
                ],
                if (widget.viewModel.errorMessageFor(l10n) != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    widget.viewModel.errorMessageFor(l10n)!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.xLarge),
                ElevatedButton(
                  onPressed: widget.viewModel.isSubmitting ? null : _submit,
                  child: Text(l10n.actionRestore),
                ),
                const SizedBox(height: AppSpacing.large),
                TextButton(
                  onPressed: widget.onNoRecoveryMaterial,
                  child: Text(l10n.iDontHavePhrase),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
