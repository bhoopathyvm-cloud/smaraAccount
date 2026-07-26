import 'package:flutter/material.dart';

import '../../../../domain/models/exchange_rate_provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/settings_view_model.dart';

/// Views are lean. No business logic, no Repository calls. Listen to the
/// ViewModel; render what it exposes (smara-tech-guidelines.md).
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              SwitchListTile(
                title: const Text('Fetch reference exchange rates'),
                subtitle: Text(
                  'Shows an indicative market rate next to the '
                  'destination amount on cross-currency transfers, for '
                  'comparison only - never used to fill in the amount.',
                  style: AppTypography.metadata,
                ),
                value: viewModel.referenceRateLookupEnabled,
                onChanged: viewModel.setReferenceRateLookupEnabled,
              ),
              const SizedBox(height: AppSpacing.large),
              DropdownButtonFormField<ExchangeRateProvider>(
                initialValue: viewModel.selectedProvider,
                decoration: const InputDecoration(labelText: 'Rate provider'),
                items: [
                  for (final provider in ExchangeRateProvider.values)
                    DropdownMenuItem(
                      value: provider,
                      child: Text(provider.displayName),
                    ),
                ],
                onChanged: viewModel.referenceRateLookupEnabled
                    ? (provider) {
                        if (provider != null) {
                          viewModel.setSelectedProvider(provider);
                        }
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
