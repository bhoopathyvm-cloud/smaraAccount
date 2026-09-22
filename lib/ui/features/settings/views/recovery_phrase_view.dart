import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../onboarding/view_models/recovery_phrase_setup_view_model.dart';

/// Settings screen displaying the current identity's recovery phrase, on
/// request, at any time (spec: "Optional Recovery and Backup Setup" -
/// this is no longer a mandatory onboarding step). An identity restored
/// from a keystore file, recovery phrase, or device migration bundle has
/// no phrase of its own to show; see
/// [RecoveryPhraseSetupViewModel.loadExistingPhraseForDisplay].
class RecoveryPhraseView extends StatefulWidget {
  const RecoveryPhraseView({super.key, required this.viewModel});

  final RecoveryPhraseSetupViewModel viewModel;

  @override
  State<RecoveryPhraseView> createState() => _RecoveryPhraseViewState();
}

class _RecoveryPhraseViewState extends State<RecoveryPhraseView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.viewModel.loadExistingPhraseForDisplay();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recoveryPhraseTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (!widget.viewModel.hasCheckedExistingPhrase) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.viewModel.hasGenerationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.viewModel.errorMessageFor(l10n)!,
                      style: AppTypography.body.copyWith(
                        color: AppColors.signal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.large),
                    ElevatedButton(
                      onPressed: () => widget.viewModel
                          .loadExistingPhraseForDisplay(retry: true),
                      child: Text(l10n.actionRetry),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!widget.viewModel.isReady) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Text(
                  l10n.noRecoveryPhraseAvailable,
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
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
                    l10n.recoveryPhraseBlurb,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                Text(l10n.recoveryPhraseWriteDown, style: AppTypography.body),
                const SizedBox(height: AppSpacing.large),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 3,
                    crossAxisSpacing: AppSpacing.base,
                    mainAxisSpacing: AppSpacing.base,
                  ),
                  itemCount: widget.viewModel.words.length,
                  itemBuilder: (context, index) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.medium,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pageBackground,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSmall,
                        ),
                      ),
                      child: Text(
                        '${index + 1}. ${widget.viewModel.words[index]}',
                        style: AppTypography.tableData,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
