import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/l10n.dart';

/// Success dialog after restoring a Books Copy: explains that later entries
/// on the other device will not appear here, and how to bring them over.
Future<void> showBooksCopyRestoredSuccessDialog(BuildContext context) {
  final l10n = l10nOf(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.backupRestored),
      content: Text(l10n.backupRestoredBody),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (Platform.isAndroid || Platform.isIOS) {
              SystemNavigator.pop();
            } else {
              exit(0);
            }
          },
          child: Text(l10n.actionCloseApp),
        ),
      ],
    ),
  );
}
