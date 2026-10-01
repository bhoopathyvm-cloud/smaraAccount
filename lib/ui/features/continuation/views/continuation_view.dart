import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/continuation_view_model.dart';

/// Shown when books exist without a matching private key.
class ContinuationView extends StatelessWidget {
  const ContinuationView({
    super.key,
    required this.viewModel,
    required this.onContinued,
    required this.onRestoreFromCopy,
  });

  final ContinuationViewModel viewModel;
  final VoidCallback onContinued;
  final VoidCallback onRestoreFromCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.continueBooksTitle,
          style: AppTypography.headerTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.continueBooksBlurb, style: AppTypography.body),
                if (viewModel.errorMessageFor(l10n) != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    viewModel.errorMessageFor(l10n)!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : () async {
                          final ok = await viewModel.continueBooks();
                          if (ok) onContinued();
                        },
                  child: Text(l10n.continueBooksAction),
                ),
                const SizedBox(height: AppSpacing.medium),
                OutlinedButton(
                  onPressed: viewModel.isBusy ? null : onRestoreFromCopy,
                  child: Text(l10n.restoreFromCopyAction),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
