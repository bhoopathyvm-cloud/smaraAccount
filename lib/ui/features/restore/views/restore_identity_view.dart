import 'package:flutter/material.dart';

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
  });

  final RestoreIdentityViewModel viewModel;
  final VoidCallback onRestored;

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Restore signing key', style: AppTypography.headerTitle),
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
                Text(
                  'This device has an existing ledger, but no matching signing '
                  'key. Restore it from your saved recovery phrase or keystore '
                  'file - your data will verify normally, and nothing will be '
                  're-signed or altered.',
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.large),
                SegmentedButton<_RestoreMode>(
                  segments: const [
                    ButtonSegment(
                      value: _RestoreMode.phrase,
                      label: Text('Recovery phrase'),
                    ),
                    ButtonSegment(
                      value: _RestoreMode.keystore,
                      label: Text('Keystore file'),
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
                    decoration: const InputDecoration(
                      labelText: 'Recovery phrase (all 24 words)',
                    ),
                  )
                else ...[
                  TextField(
                    controller: _keystoreController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Keystore file contents',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextField(
                    controller: _passphraseController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Passphrase'),
                  ),
                ],
                if (widget.viewModel.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    widget.viewModel.errorMessage!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.xLarge),
                ElevatedButton(
                  onPressed: widget.viewModel.isSubmitting ? null : _submit,
                  child: const Text('Restore'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
