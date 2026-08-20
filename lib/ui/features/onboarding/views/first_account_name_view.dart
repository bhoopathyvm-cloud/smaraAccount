import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/first_account_name_view_model.dart';

/// Names the seeded starter account before the guided first entry
/// (deferred-onboarding-first-entry spec: "Guided First Entry Before
/// Acknowledgment").
class FirstAccountNameView extends StatefulWidget {
  const FirstAccountNameView({
    super.key,
    required this.viewModel,
    required this.onFinished,
  });

  final FirstAccountNameViewModel viewModel;
  final VoidCallback onFinished;

  @override
  State<FirstAccountNameView> createState() => _FirstAccountNameViewState();
}

class _FirstAccountNameViewState extends State<FirstAccountNameView> {
  final _controller = TextEditingController();
  var _syncedInitialName = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.firstAccountTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!_syncedInitialName) {
            _syncedInitialName = true;
            _controller.text = widget.viewModel.name;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.whatsMainAccountCalled,
                  style: AppTypography.sectionLabel,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  l10n.firstAccountBlurb,
                  style: AppTypography.metadata,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: l10n.accountName),
                  onChanged: widget.viewModel.setName,
                ),
                if (widget.viewModel.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    widget.viewModel.errorMessage!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.xLarge),
                ElevatedButton(
                  onPressed: widget.viewModel.isSubmitting
                      ? null
                      : () async {
                          final success = await widget.viewModel.submit();
                          if (success) widget.onFinished();
                        },
                  child: Text(l10n.actionContinue),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
