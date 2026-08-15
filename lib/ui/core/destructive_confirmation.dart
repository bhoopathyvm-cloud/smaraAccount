import 'package:flutter/material.dart';

import 'app_colors.dart';

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
  String confirmLabel = 'Archive',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          style: destructiveButtonStyle,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
