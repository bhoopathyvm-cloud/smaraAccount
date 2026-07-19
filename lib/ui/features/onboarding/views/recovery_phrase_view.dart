import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/recovery_phrase_setup_view_model.dart';

/// First onboarding screen: generates the device's recovery phrase and
/// displays it with explicit consequences messaging (spec: "Mandatory
/// Recovery Phrase Acknowledgment" - "the recovery phrase is displayed
/// with an explanation of the consequences of losing both the device and
/// the phrase"). The phrase is not yet committed to the database - see
/// [RecoveryPhraseSetupViewModel].
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Your recovery phrase', style: AppTypography.headerTitle),
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
                      child: const Text('Retry'),
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
                    'These 24 words are the only way to recover your transaction '
                    'history if this device is lost, reset, or replaced. Smara '
                    'Accounting has no server and cannot recover them for you.\n\n'
                    'If you lose this device and this phrase together, every '
                    'transaction you\'ve recorded becomes permanently unverifiable.',
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                Text(
                  'Write these words down in order and store them somewhere safe '
                  'and separate from this device.',
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
                  child: const Text('I\'ve saved my recovery phrase'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
