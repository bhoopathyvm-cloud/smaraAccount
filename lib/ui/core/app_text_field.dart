import 'package:flutter/material.dart';

/// A text field for household-authored text (names, payees, memos,
/// descriptions) that carries the active UI locale as an IME hint, so the
/// on-screen keyboard suggests the selected language's script where the OS
/// honors it (Android API 24+; Flutter documents this as best-effort - iOS/
/// macOS keep whatever system keyboard is already active).
///
/// Fields that must stay Latin-or-digit only (ISO currency codes, PIN,
/// BIP39 recovery words, ticker/ISIN) MUST NOT use this widget with
/// [latinOnly] false - pass `latinOnly: true`, or use a plain [TextField]
/// with its own restricting `inputFormatters`, so no Indic/CJK/Arabic IME
/// hint is ever attached to them
/// (i18n-full-ui-and-input-language design.md Decision 2).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.maxLines = 1,
    this.autofocus = false,
    this.latinOnly = false,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final bool autofocus;

  /// True for ISO currency, PIN, BIP39, ticker/ISIN, and similar fields
  /// that must never carry a non-Latin IME hint.
  final bool latinOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      maxLines: maxLines,
      textInputAction: textInputAction,
      hintLocales: latinOnly ? null : [Localizations.localeOf(context)],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
