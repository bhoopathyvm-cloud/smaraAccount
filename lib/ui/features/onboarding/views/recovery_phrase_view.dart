import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/recovery_phrase_setup_view_model.dart';

/// Displays the device's recovery phrase with explicit consequences
/// messaging (spec: "Mandatory Recovery Phrase Acknowledgment" - "the
/// recovery phrase is displayed with an explanation of the consequences of
/// losing both the device and the phrase"). deferred-onboarding-first-entry:
/// by the time this screen shows, the signing identity is already
/// committed and the user has already recorded one guided entry with it -
/// see [RecoveryPhraseSetupViewModel].
class RecoveryPhraseView extends StatefulWidget {
  const RecoveryPhraseView({
    super.key,
    required this.viewModel,
    required this.onContinue,
  });

  final RecoveryPhraseSetupViewModel viewModel;
  final VoidCallback onContinue;

  @override
  State<RecoveryPhraseView> createState() => _RecoveryPhraseViewState();
}

class _RecoveryPhraseViewState extends State<RecoveryPhraseView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.ensureGenerated();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recoveryPhraseTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.hasGenerationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.viewModel.errorMessage!,
                      style: AppTypography.body.copyWith(
                        color: AppColors.signal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.large),
                    ElevatedButton(
                      onPressed: widget.viewModel.ensureGenerated,
                      child: Text(l10n.actionRetry),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!widget.viewModel.isReady) {
            return const Center(child: CircularProgressIndicator());
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
                Text(
                  l10n.recoveryPhraseWriteDown,
                  style: AppTypography.body,
                ),
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
                const SizedBox(height: AppSpacing.xLarge),
                ElevatedButton(
                  onPressed: widget.onContinue,
                  child: Text(l10n.iveSavedRecoveryPhrase),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
