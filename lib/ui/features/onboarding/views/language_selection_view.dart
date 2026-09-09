import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/crypto/bip39_language_for_locale.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';

/// Mandatory first onboarding screen (onboarding-language-selection):
/// requires an explicit language choice - confirming the pre-highlighted,
/// already-effective locale counts - before Continue is enabled. Writes
/// through the same `LocaleController` / `preferredLocaleTag` preference
/// Settings uses, so there is no new persisted preference and no view
/// model of its own (design.md Decision 4).
///
/// Uses plain [ListTile]s with a manually-drawn radio icon rather than
/// [RadioListTile]/[RadioGroup]: a real `Radio` only fires `onChanged` when
/// the tapped value differs from the current group value, so re-tapping an
/// already-selected row - exactly the "confirm the pre-highlighted locale"
/// interaction this screen requires (Decision 6) - would silently do
/// nothing under the standard widget.
class LanguageSelectionView extends StatefulWidget {
  const LanguageSelectionView({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView> {
  bool _hasSelected = false;

  String _currentTag(LocaleController controller) {
    final override = controller.overrideLocale;
    return override == null ? kSystemLocalePreference : tagFromLocale(override);
  }

  void _select(LocaleController controller, String tag) {
    controller.setPreference(tag);
    setState(() => _hasSelected = true);
  }

  Widget _tile(
    BuildContext context, {
    required LocaleController controller,
    required String tag,
    required String label,
  }) {
    final selected = _currentTag(controller) == tag;
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? AppColors.primary : null,
      ),
      title: Text(label),
      onTap: () => _select(controller, tag),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final localeController = context.watch<LocaleController>();
    final effectiveLanguageCode = Localizations.localeOf(context).languageCode;
    final showsBip39Notice =
        effectiveLanguageCode != 'en' &&
        bip39LanguageForLocale(effectiveLanguageCode) == Language.english;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chooseLanguageTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Text(l10n.chooseLanguageBlurb, style: AppTypography.body),
          ),
          Expanded(
            child: ListView(
              children: [
                _tile(
                  context,
                  controller: localeController,
                  tag: kSystemLocalePreference,
                  label: l10n.settingsLanguageSystem,
                ),
                for (final tag in kSupportedLocaleTags)
                  _tile(
                    context,
                    controller: localeController,
                    tag: tag,
                    label: endonymForLocaleTag(tag),
                  ),
              ],
            ),
          ),
          if (showsBip39Notice)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.large,
                vertical: AppSpacing.medium,
              ),
              child: Text(
                l10n.chooseLanguageBip39Notice,
                style: AppTypography.metadata.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ElevatedButton(
              onPressed: _hasSelected ? widget.onFinished : null,
              child: Text(l10n.actionContinue),
            ),
          ),
        ],
      ),
    );
  }
}
