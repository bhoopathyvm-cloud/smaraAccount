import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/first_week_setup_view_model.dart';

/// A short post-onboarding wizard: name the main account, optionally add
/// a credit card and/or cash account (spec: "First-Week Setup Wizard").
/// Reachable exactly once - the app router only shows this route while
/// `SettingsRepository.isFirstWeekSetupCompleted()` is still false.
class FirstWeekSetupView extends StatefulWidget {
  const FirstWeekSetupView({
    super.key,
    required this.viewModel,
    required this.onFinished,
  });

  final FirstWeekSetupViewModel viewModel;
  final VoidCallback onFinished;

  @override
  State<FirstWeekSetupView> createState() => _FirstWeekSetupViewState();
}

class _FirstWeekSetupViewState extends State<FirstWeekSetupView> {
  final _mainAccountController = TextEditingController();
  final _creditCardController = TextEditingController();
  final _cashAccountController = TextEditingController();
  var _syncedInitialName = false;

  @override
  void dispose() {
    _mainAccountController.dispose();
    _creditCardController.dispose();
    _cashAccountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set up your accounts', style: AppTypography.headerTitle),
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
          // Prefill once, when the seeded account's name first becomes
          // known - not on every rebuild, or the user's own typing would
          // keep getting overwritten.
          if (!_syncedInitialName) {
            _syncedInitialName = true;
            _mainAccountController.text = widget.viewModel.mainAccountName;
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
                  'name you recognize, like your bank.',
                  style: AppTypography.metadata,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _mainAccountController,
                  decoration: const InputDecoration(labelText: 'Account name'),
                  onChanged: widget.viewModel.setMainAccountName,
                ),
                const SizedBox(height: AppSpacing.xLarge),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Add a credit card'),
                  value: widget.viewModel.hasCreditCard,
                  onChanged: widget.viewModel.setHasCreditCard,
                ),
                if (widget.viewModel.hasCreditCard)
                  TextField(
                    controller: _creditCardController,
                    decoration: const InputDecoration(labelText: 'Card name'),
                    onChanged: widget.viewModel.setCreditCardName,
                  ),
                const SizedBox(height: AppSpacing.large),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Add a cash account'),
                  value: widget.viewModel.hasCashAccount,
                  onChanged: widget.viewModel.setHasCashAccount,
                ),
                if (widget.viewModel.hasCashAccount)
                  TextField(
                    controller: _cashAccountController,
                    decoration: const InputDecoration(
                      labelText: 'Cash account name',
                    ),
                    onChanged: widget.viewModel.setCashAccountName,
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
                          final success = await widget.viewModel.finish();
                          if (success) widget.onFinished();
                        },
                  child: const Text('Finish'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
