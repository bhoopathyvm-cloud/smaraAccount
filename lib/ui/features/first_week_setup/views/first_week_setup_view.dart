import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_text_field.dart';
import '../../../core/app_typography.dart';
import '../view_models/first_week_setup_view_model.dart';

/// A short post-onboarding wizard: optionally add a credit card and/or
/// cash account (spec: "First-Week Setup Wizard"). Reachable exactly
/// once - the app router only shows this route while
/// `SettingsRepository.isFirstWeekSetupCompleted()` is still false.
/// Naming the seeded main account happens earlier, via
/// `FirstAccountNameView` - see this view model's doc comment.
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
  final _creditCardController = TextEditingController();
  final _cashAccountController = TextEditingController();

  @override
  void dispose() {
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.firstWeekBlurb, style: AppTypography.metadata),
                const SizedBox(height: AppSpacing.xLarge),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.addCreditCard),
                  value: widget.viewModel.hasCreditCard,
                  onChanged: widget.viewModel.setHasCreditCard,
                ),
                if (widget.viewModel.hasCreditCard)
                  AppTextField(
                    controller: _creditCardController,
                    labelText: l10n.cardName,
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
                  AppTextField(
                    controller: _cashAccountController,
                    labelText: l10n.cashAccountName,
                    onChanged: widget.viewModel.setCashAccountName,
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
