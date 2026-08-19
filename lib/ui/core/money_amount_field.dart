import 'package:flutter/material.dart';

import 'money_formatter.dart';

/// A text field for entering a monetary amount in [currency]'s own
/// convention - accepts that currency's decimal separator (e.g. a comma
/// where that's conventional), not only a period. Reports the parsed
/// value already converted to minor units (e.g. cents) via
/// [onChangedMinor] - null for an empty field. Unparseable non-empty
/// text is rejected explicitly (an error state), never silently treated
/// as empty (localized-money-formatting design.md Decision 3).
class MoneyAmountField extends StatefulWidget {
  const MoneyAmountField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onChangedMinor,
    required this.currency,
    this.suffixText,
    this.helperText,
    this.helperMaxLines,
  });

  final TextEditingController controller;
  final String labelText;
  final ValueChanged<int?> onChangedMinor;
  final String currency;
  final String? suffixText;
  final String? helperText;
  final int? helperMaxLines;

  @override
  State<MoneyAmountField> createState() => _MoneyAmountFieldState();
}

class _MoneyAmountFieldState extends State<MoneyAmountField> {
  bool _isInvalid = false;

  void _handleChanged(String text) {
    final isEmpty = text.trim().isEmpty;
    final minor = parseAmountToMinor(text, widget.currency);
    setState(() => _isInvalid = !isEmpty && minor == null);
    widget.onChangedMinor(minor);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixText: widget.suffixText,
        helperText: _isInvalid ? null : widget.helperText,
        helperMaxLines: widget.helperMaxLines,
        errorText: _isInvalid ? 'Enter a valid amount' : null,
      ),
      onChanged: _handleChanged,
    );
  }
}
