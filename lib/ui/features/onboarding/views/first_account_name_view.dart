import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_text_field.dart';
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

  /// The seeded English name, captured once so a save that leaves the
  /// editor's localized display text untouched can canonicalize back to
  /// it (system_name_localizer.dart's `canonicalNameToPersist`) instead of
  /// persisting the display language into the database.
  String _originalSeedName = '';

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
            _originalSeedName = widget.viewModel.name;
            _controller.text = editingNameFor(l10n, widget.viewModel.name);
            widget.viewModel.setName(_controller.text);
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
                Text(l10n.firstAccountBlurb, style: AppTypography.metadata),
                const SizedBox(height: AppSpacing.medium),
                AppTextField(
                  controller: _controller,
                  labelText: l10n.accountName,
                  onChanged: widget.viewModel.setName,
                ),
                if (widget.viewModel.errorMessageFor(l10n) != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    widget.viewModel.errorMessageFor(l10n)!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.xLarge),
                ElevatedButton(
                  onPressed: widget.viewModel.isSubmitting
                      ? null
                      : () async {
                          widget.viewModel.setName(
                            canonicalNameToPersist(
                              l10n,
                              _originalSeedName,
                              _controller.text,
                            ),
                          );
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
