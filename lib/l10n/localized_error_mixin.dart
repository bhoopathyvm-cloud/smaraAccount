import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../domain/app_error.dart';
import 'generated/app_localizations.dart';
import 'localize_error.dart';

/// Shared failure storage so ViewModels keep a structured error and views
/// can localize it for the active locale.
mixin LocalizedErrorMixin on ChangeNotifier {
  Object? _failure;

  Object? get failure => _failure;

  String? errorMessageFor(AppLocalizations l10n) =>
      _failure == null ? null : localizeCaughtError(l10n, _failure!);

  /// English mapping for unit tests that assert on [errorMessage].
  String? get errorMessage =>
      errorMessageFor(lookupAppLocalizations(const Locale('en')));

  void setFailure(Object? error) {
    _failure = error;
    // The UI shows a localized sentence ("Something went wrong"); keep the
    // real cause visible in debug logs so it can be diagnosed.
    if (kDebugMode && error != null) {
      debugPrint('[$runtimeType] failure: $error');
    }
    notifyListeners();
  }

  void clearFailure() {
    if (_failure == null) return;
    _failure = null;
    notifyListeners();
  }
}

AppFailure validation(
  AppErrorCode code, [
  Map<String, String> params = const {},
]) => AppFailure(code, params: params);
