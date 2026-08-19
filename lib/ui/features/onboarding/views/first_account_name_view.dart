import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Name your account', style: AppTypography.headerTitle),
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
                  "What's your main account called?",
                  style: AppTypography.sectionLabel,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  'This is the account already set up for you - give it a '
                  'name you recognize, like your bank. You will record one '
                  'Spent or Received next, then protect the device with your '
                  'recovery phrase.',
                  style: AppTypography.metadata,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(labelText: 'Account name'),
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
                  child: const Text('Continue'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
