import 'package:flutter/material.dart';

import 'app_colors.dart';
import '../../l10n/l10n.dart';

/// The design system's "Destructive" button pattern (smara-design-system.md):
/// red outlined, red text, transparent background.
final destructiveButtonStyle = OutlinedButton.styleFrom(
  foregroundColor: AppColors.signal,
  side: const BorderSide(color: AppColors.signal, width: 1.5),
);

/// Shows a Cancel/confirm dialog styled with [destructiveButtonStyle] and
/// resolves to whether the user confirmed.
Future<bool> confirmDestructiveAction({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  final l10n = l10nOf(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.actionCancel),
        ),
        OutlinedButton(
          style: destructiveButtonStyle,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel ?? l10n.actionHide),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
