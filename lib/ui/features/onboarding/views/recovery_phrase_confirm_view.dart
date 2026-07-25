import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/recovery_phrase_setup_view_model.dart';

/// Penultimate onboarding step: the user re-enters a subset of the
/// recovery phrase's words to prove possession before the ledger becomes
/// usable (spec: "the user must confirm possession of the phrase (e.g.
/// re-entering part of it) before recording their first transaction").
/// Only validates the words - the signing identity isn't committed until
/// the user also picks a currency on the next screen (see
/// [RecoveryPhraseSetupViewModel.finishOnboarding]).
class RecoveryPhraseConfirmView extends StatefulWidget {
  const RecoveryPhraseConfirmView({
    super.key,
    required this.viewModel,
    required this.onConfirmed,
  });

  final RecoveryPhraseSetupViewModel viewModel;
  final VoidCallback onConfirmed;

  @override
  State<RecoveryPhraseConfirmView> createState() =>
      _RecoveryPhraseConfirmViewState();
}

class _RecoveryPhraseConfirmViewState extends State<RecoveryPhraseConfirmView> {
  final _controllers = {
    for (final i in RecoveryPhraseSetupViewModel.confirmationWordIndices)
      i: TextEditingController(),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final entered = {
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    };
    final success = widget.viewModel.confirm(entered);
    if (success) widget.onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm your phrase', style: AppTypography.headerTitle),
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
                  'Enter the requested words from the phrase you just saved.',
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.large),
                for (final index
                    in RecoveryPhraseSetupViewModel
                        .confirmationWordIndices) ...[
                  TextField(
                    controller: _controllers[index],
                    decoration: InputDecoration(
                      labelText: 'Word #${index + 1}',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                ],
                if (widget.viewModel.errorMessage != null) ...[
                  Text(
                    widget.viewModel.errorMessage!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                ],
                const SizedBox(height: AppSpacing.medium),
                ElevatedButton(
                  onPressed: widget.viewModel.isSubmitting ? null : _submit,
                  child: const Text('Confirm'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
