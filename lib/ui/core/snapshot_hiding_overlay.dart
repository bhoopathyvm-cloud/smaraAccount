import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_lock_controller.dart';

/// Obscures [child] with an opaque cover whenever the app is backgrounded
/// and the user has turned on snapshot hiding (app-lock spec: "App-Switcher
/// Snapshot Hides Balances"). Wraps the whole app, above `MaterialApp.router`,
/// so the cover is the last thing rendered before the OS captures its
/// app-switcher/task-switcher snapshot on iOS and Android - the two
/// platforms `AppLockController.isSnapshotHidingEnabled` is ever true on
/// (design.md Decision 2: no equivalent mechanism on desktop, so this
/// overlay is a no-op there regardless of the setting).
class SnapshotHidingOverlay extends StatelessWidget {
  const SnapshotHidingOverlay({
    super.key,
    required this.appLockController,
    required this.child,
  });

  final AppLockController appLockController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appLockController,
      builder: (context, _) {
        final shouldCover =
            appLockController.isBackgrounded &&
            appLockController.isSnapshotHidingEnabled;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              child,
              if (shouldCover)
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.primary,
                    child: Center(
                      child: Icon(
                        Icons.lock_outline,
                        size: 48,
                        color: AppColors.cardBackground,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
