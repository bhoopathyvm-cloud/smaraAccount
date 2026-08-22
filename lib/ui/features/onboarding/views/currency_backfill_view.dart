import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/currency_backfill_view_model.dart';

const _commonCurrencies = ['USD', 'EUR', 'GBP', 'INR', 'CAD', 'AUD', 'JPY'];

/// One-time screen shown after upgrading a database created before
/// multi-currency-support (schemaVersion 3): every existing account group
/// needs a currency before the app is otherwise usable again
/// (multi-currency-support design.md Migration Plan step 3 - a real
/// installation up to this point is presumably already single-currency,
/// so one choice applies to every group).
class CurrencyBackfillView extends StatefulWidget {
  const CurrencyBackfillView({
    super.key,
    required this.viewModel,
    required this.onFinished,
  });

  final CurrencyBackfillViewModel viewModel;
  final VoidCallback onFinished;

  @override
  State<CurrencyBackfillView> createState() => _CurrencyBackfillViewState();
}

class _CurrencyBackfillViewState extends State<CurrencyBackfillView> {
  final _controller = TextEditingController(text: _commonCurrencies.first);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => RegExp(r'^[A-Z]{3}$').hasMatch(_controller.text);

  Future<void> _submit() async {
    if (!_isValid) return;
    final success = await widget.viewModel.submit(_controller.text);
    if (success) widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.currencyBackfillTitle,
          style: AppTypography.headerTitle,
        ),
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
                Text(l10n.currencyBackfillBlurb, style: AppTypography.body),
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
