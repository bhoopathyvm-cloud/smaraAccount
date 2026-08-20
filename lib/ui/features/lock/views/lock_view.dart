import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/lock_view_model.dart';

/// Blocks the whole app behind a PIN (and, if enabled, biometrics) until
/// unlocked (app-lock spec: "Application Lock"). Reached only via the
/// router's redirect guard - never pushed directly, and
/// `automaticallyImplyLeading: false` since there's nowhere to go back to.
class LockView extends StatefulWidget {
  const LockView({super.key, required this.viewModel});

  final LockViewModel viewModel;

  @override
  State<LockView> createState() => _LockViewState();
}

class _LockViewState extends State<LockView> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await widget.viewModel.submitPin(_pinController.text);
    if (success) _pinController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locked', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(TablerIcons.lock, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    'Enter your PIN to continue',
                    style: AppTypography.cardTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(labelText: 'PIN'),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (widget.viewModel.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      widget.viewModel.errorMessage!,
                      style: AppTypography.body.copyWith(
                        color: AppColors.signal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.large),
                  ElevatedButton(
                    onPressed: widget.viewModel.isVerifying ? null : _submit,
                    child: const Text('Unlock'),
                  ),
                  if (widget.viewModel.biometricEnabled) ...[
                    const SizedBox(height: AppSpacing.medium),
                    OutlinedButton(
                      onPressed: widget.viewModel.isVerifying
                          ? null
                          : widget.viewModel.authenticateWithBiometrics,
                      child: const Text('Use biometrics'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
