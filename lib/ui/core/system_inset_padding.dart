import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Scrollable padding that keeps the last item clear of the system
/// navigation bar / home indicator. When [MediaQuery.viewPadding] bottom
/// is zero the result matches [EdgeInsets.all] with [base].
EdgeInsets scrollPaddingAvoidingSystemInsets(
  BuildContext context, {
  double base = AppSpacing.large,
}) {
  return EdgeInsets.fromLTRB(
    base,
    base,
    base,
    base + MediaQuery.viewPaddingOf(context).bottom,
  );
}
