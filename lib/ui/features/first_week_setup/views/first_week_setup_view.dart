import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
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
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.firstWeekTitle, style: AppTypography.headerTitle),
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
                  l10n.whatsMainAccountCalled,
                  style: AppTypography.sectionLabel,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  l10n.firstWeekBlurb,
                  style: AppTypography.metadata,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _mainAccountController,
                  decoration: InputDecoration(labelText: l10n.accountName),
                  onChanged: widget.viewModel.setMainAccountName,
                ),
                const SizedBox(height: AppSpacing.xLarge),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.addCreditCard),
                  value: widget.viewModel.hasCreditCard,
                  onChanged: widget.viewModel.setHasCreditCard,
                ),
                if (widget.viewModel.hasCreditCard)
                  TextField(
                    controller: _creditCardController,
                    decoration: InputDecoration(labelText: l10n.cardName),
                    onChanged: widget.viewModel.setCreditCardName,
                  ),
                const SizedBox(height: AppSpacing.large),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.addCashAccount),
                  value: widget.viewModel.hasCashAccount,
                  onChanged: widget.viewModel.setHasCashAccount,
                ),
                if (widget.viewModel.hasCashAccount)
                  TextField(
                    controller: _cashAccountController,
                    decoration: InputDecoration(
                      labelText: l10n.cashAccountName,
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
                  child: Text(l10n.actionFinish),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
