import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';

/// First screen on a device with no signing identity yet (spec:
/// `device-migration-bundle`'s "Startup Setup Choice"). New Setup
/// proceeds exactly as first-time onboarding already did; Import From
/// Backup skips it entirely, landing directly in restored, ready-to-use
/// books.
class SetupChoiceView extends StatelessWidget {
  const SetupChoiceView({
    super.key,
    required this.onNewSetup,
    required this.onImportFromBackup,
  });

  final VoidCallback onNewSetup;
  final VoidCallback onImportFromBackup;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.setupChoiceTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.setupChoiceBlurb, style: AppTypography.body),
            const SizedBox(height: AppSpacing.xLarge),
            ElevatedButton(
              onPressed: onNewSetup,
              child: Text(l10n.actionNewSetup),
            ),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton(
              onPressed: onImportFromBackup,
              child: Text(l10n.actionImportFromBackup),
            ),
          ],
        ),
      ),
    );
  }
}
