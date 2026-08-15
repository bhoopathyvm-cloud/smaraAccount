import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// A status/error message banner. Shows a Dismiss action only when
/// [onDismiss] is supplied; [isError] switches the message to signal-red.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.isError = false,
  });

  final String message;
  final VoidCallback? onDismiss;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(
        message,
        style: isError
            ? AppTypography.body.copyWith(color: AppColors.signal)
            : null,
      ),
      actions: [
        if (onDismiss != null)
          TextButton(onPressed: onDismiss, child: const Text('Dismiss'))
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
