import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/crypto/recovery_phrase_language.dart';
import '../../../../l10n/default_currency.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/recovery_phrase_setup_view_model.dart';

/// A few common ISO 4217 codes shown as quick picks; any 3-letter code can
/// be typed instead (multi-currency-support keeps no built-in FX/currency
/// data source, so this list is purely a UI convenience, not validated
/// against a canonical registry).
const _commonCurrencies = ['USD', 'EUR', 'GBP', 'INR', 'CAD', 'AUD', 'JPY'];

/// First onboarding screen (deferred-onboarding-first-entry): the currency
/// chosen here seeds all four starter account groups and commits the
/// signing identity, before the user ever sees the recovery phrase
/// (multi-currency-support design.md addendum - a group's currency can't
/// change once it has active accounts, so this choice matters before the
/// starter financial account is created).
class CurrencySelectionView extends StatefulWidget {
  const CurrencySelectionView({
    super.key,
    required this.viewModel,
    required this.onFinished,
  });

  final RecoveryPhraseSetupViewModel viewModel;
  final VoidCallback onFinished;

  @override
  State<CurrencySelectionView> createState() => _CurrencySelectionViewState();
}

class _CurrencySelectionViewState extends State<CurrencySelectionView> {
  final _controller = TextEditingController();

  /// The currency default follows the chosen language (onboarding-language-
  /// selection Decision 7) but only seeds the initial text once - after that
  /// it is a plain, freely-editable value like any other.
  bool _seededDefault = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_seededDefault) {
      _seededDefault = true;
      final languageCode = Localizations.localeOf(context).languageCode;
      _controller.text = defaultCurrencyForLocale(languageCode);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => RegExp(r'^[A-Z]{3}$').hasMatch(_controller.text);

  Future<void> _submit() async {
    if (!_isValid) return;
    final l10n = l10nOf(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    // The recovery phrase is generated inside commitIdentity below, so the
    // English-fallback disclosure (onboarding-language-selection Decision 8)
    // must be shown and accepted here, before that call.
    if (recoveryPhraseUsesEnglishFallback(languageCode)) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.recoveryPhraseEnglishFallbackTitle),
          content: Text(l10n.recoveryPhraseEnglishFallbackBlurb),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.actionContinue),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }
    if (!mounted) return;

    final success = await widget.viewModel.commitIdentity(
      _controller.text,
      recoveryPhraseLanguage: bip39LanguageForLocale(languageCode),
    );
    if (success) widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chooseCurrencyTitle, style: AppTypography.headerTitle),
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
                Text(l10n.chooseCurrencyBlurb, style: AppTypography.body),
                const SizedBox(height: AppSpacing.large),
                Wrap(
                  spacing: AppSpacing.small,
                  children: [
                    for (final code in _commonCurrencies)
                      ChoiceChip(
                        label: Text(code),
                        selected: _controller.text == code,
                        onSelected: (_) =>
                            setState(() => _controller.text = code),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),
                TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 3,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) =>
                          newValue.copyWith(text: newValue.text.toUpperCase()),
                    ),
                  ],
                  decoration: InputDecoration(labelText: l10n.currencyCodeIso),
                  onChanged: (_) => setState(() {}),
                ),
                if (widget.viewModel.errorMessageFor(l10n) != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    widget.viewModel.errorMessageFor(l10n)!,
                    style: AppTypography.body.copyWith(color: AppColors.signal),
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                ElevatedButton(
                  onPressed: widget.viewModel.isSubmitting || !_isValid
                      ? null
                      : _submit,
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
