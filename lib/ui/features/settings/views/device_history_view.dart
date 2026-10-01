import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/device_history_view_model.dart';

/// Lists IDENTITY_CONTINUED events in household wording.
class DeviceHistoryView extends StatelessWidget {
  const DeviceHistoryView({super.key, required this.viewModel});

  final DeviceHistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deviceHistoryTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final items = viewModel.items;
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Text(
                l10n.deviceHistoryEmpty,
                style: AppTypography.body,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.large),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.medium),
            itemBuilder: (context, index) {
              final item = items[index];
              final continued = dateFormat.format(item.continuedAt.toLocal());
              final text = item.copySavedAt == null
                  ? l10n.deviceHistoryContinuedOn(continued)
                  : l10n.deviceHistoryContinuedFromCopy(
                      continued,
                      dateFormat.format(item.copySavedAt!.toLocal()),
                    );
              return Text(text, style: AppTypography.body);
            },
          );
        },
      ),
    );
  }
}
