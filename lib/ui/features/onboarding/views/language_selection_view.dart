import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';

/// First onboarding screen (onboarding-language-selection): the user picks
/// the app language, by its own native name, before the currency screen and
/// before the signing identity is committed. Writes through the same
/// [LocaleController] / `preferredLocaleTag` preference Settings uses, so the
/// choice applies to the rest of onboarding immediately and persists.
///
/// The choice is mandatory (design.md Decision 6): the list pre-highlights the
/// locale the app currently resolves to, but Continue stays disabled until the
/// user explicitly taps a row. Tapping the already-highlighted row (or "Same
/// as device") counts, so a user whose device locale is already right needs
/// only one tap - never a pointless change-and-change-back.
class LanguageSelectionView extends StatefulWidget {
  const LanguageSelectionView({
    super.key,
    required this.localeController,
    required this.onFinished,
  });

  final LocaleController localeController;
  final VoidCallback onFinished;

  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView> {
  /// Whether the user has explicitly tapped a row during this screen's
  /// lifetime. Continue is disabled until this is true (design.md Decision 6).
  bool _hasSelected = false;

  void _select(String tag) {
    widget.localeController.setPreference(tag);
    if (!_hasSelected) setState(() => _hasSelected = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSelectTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: widget.localeController,
        builder: (context, _) {
          // Pre-highlight the effective locale: the persisted override if any,
          // else the "same as device" sentinel (which resolves to the device
          // locale with an English fallback).
          final selectedTag = widget.localeController.overrideLocale == null
              ? kSystemLocalePreference
              : tagFromLocale(widget.localeController.overrideLocale!);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Text(l10n.languageSelectBlurb, style: AppTypography.body),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _languageTile(
                      label: l10n.settingsLanguageSystem,
                      tag: kSystemLocalePreference,
                      selectedTag: selectedTag,
                    ),
                    for (final tag in kSupportedLocaleTags)
                      _languageTile(
                        label: endonymForLocaleTag(tag),
                        tag: tag,
                        selectedTag: selectedTag,
                      ),
                  ],
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
          );
        },
      ),
    );
  }

  Widget _languageTile({
    required String label,
    required String tag,
    required String selectedTag,
  }) {
    final selected = tag == selectedTag;
    return ListTile(
      title: Text(label),
      selected: selected,
      trailing: selected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () => _select(tag),
    );
  }
}
