import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/linked_devices/join_code.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';

/// Dialog body for "Enter code instead" (task 4.3).
class JoinCodeEntryPanel extends StatefulWidget {
  const JoinCodeEntryPanel({
    super.key,
    required this.onSubmit,
    this.errorMessage,
    this.isBusy = false,
  });

  /// Called with the raw typed value (may be lowercase / without dash).
  final Future<void> Function(String typed) onSubmit;
  final String? errorMessage;
  final bool isBusy;

  @override
  State<JoinCodeEntryPanel> createState() => _JoinCodeEntryPanelState();
}

class _JoinCodeEntryPanelState extends State<JoinCodeEntryPanel> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Local guard: parent [isBusy] may not rebuild before a second tap
    // (integration-test tapReliably retries), and a re-entrant lookupJoinCode
    // returns notFound while the first lookup is still in flight.
    if (widget.isBusy || _submitting) return;
    final typed = _controller.text.trim();
    if (typed.isEmpty) return;
    _submitting = true;
    setState(() {});
    try {
      await widget.onSubmit(typed);
    } finally {
      _submitting = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.settingsLinkedDevicesJoinSameWifi, style: AppTypography.body),
        const SizedBox(height: AppSpacing.medium),
        TextField(
          key: const Key('join-code-entry-field'),
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z\-\s]')),
          ],
          decoration: InputDecoration(
            labelText: l10n.settingsLinkedDevicesJoinCodeLabel,
            hintText: l10n.settingsLinkedDevicesEnterCodeHint,
          ),
          onSubmitted: (_) => _submit(),
        ),
        if (widget.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.small),
          Text(
            widget.errorMessage!,
            key: const Key('join-code-entry-error'),
            style: AppTypography.metadata.copyWith(color: AppColors.signal),
          ),
        ],
        const SizedBox(height: AppSpacing.medium),
        ElevatedButton(
          key: const Key('join-code-entry-submit'),
          onPressed: (widget.isBusy || _submitting) ? null : _submit,
          child: Text(
            (widget.isBusy || _submitting)
                ? l10n.settingsLinkedDevicesSyncNowBusy
                : l10n.settingsLinkedDevicesEnterCodeSubmit,
          ),
        ),
      ],
    );
  }
}

/// Formats a typed join code for display after normalize (`XXXX-XXXX`).
String formatJoinCodeDisplay(String typed) {
  final raw = JoinCode.normalize(typed);
  if (raw.length != 8) return typed;
  return '${raw.substring(0, 4)}-${raw.substring(4, 8)}';
}
