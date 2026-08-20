import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import 'app_typography.dart';

/// The single Add action's choice of what to capture (home-hub-capture:
/// "Home's primary Add action: Spent / Received / Moved money / Import
/// statement" - Register's three separate FABs consolidate into this same
/// sheet, per that change's "Register's Capture Actions Consolidate Into
/// One" requirement).
Future<void> showCaptureActionSheet({
  required BuildContext context,
  required VoidCallback onSpent,
  required VoidCallback onReceived,
  required VoidCallback onTransfer,
  required VoidCallback onImport,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(TablerIcons.arrowUp),
            title: Text('Spent', style: AppTypography.body),
            onTap: () {
              Navigator.of(sheetContext).pop();
              onSpent();
            },
          ),
          ListTile(
            leading: const Icon(TablerIcons.arrowDown),
            title: Text('Received', style: AppTypography.body),
            onTap: () {
              Navigator.of(sheetContext).pop();
              onReceived();
            },
          ),
          ListTile(
            leading: const Icon(TablerIcons.arrowsExchange),
            title: Text('Moved money', style: AppTypography.body),
            onTap: () {
              Navigator.of(sheetContext).pop();
              onTransfer();
            },
          ),
          ListTile(
            leading: const Icon(TablerIcons.fileImport),
            title: Text('Import statement', style: AppTypography.body),
            onTap: () {
              Navigator.of(sheetContext).pop();
              onImport();
            },
          ),
        ],
      ),
    ),
  );
}
