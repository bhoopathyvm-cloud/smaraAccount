import 'package:flutter/material.dart';

/// A text field for entering a monetary amount. Reports the parsed value
/// already converted to minor units (e.g. cents) via [onChangedMinor] -
/// null for an empty or unparseable value.
class MoneyAmountField extends StatelessWidget {
  const MoneyAmountField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onChangedMinor,
    this.suffixText,
    this.helperText,
    this.helperMaxLines,
  });

  final TextEditingController controller;
  final String labelText;
  final ValueChanged<int?> onChangedMinor;
  final String? suffixText;
  final String? helperText;
  final int? helperMaxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: labelText,
        suffixText: suffixText,
        helperText: helperText,
        helperMaxLines: helperMaxLines,
      ),
      onChanged: (text) {
        final amount = double.tryParse(text);
        onChangedMinor(amount == null ? null : (amount * 100).round());
      },
    );
  }
}
