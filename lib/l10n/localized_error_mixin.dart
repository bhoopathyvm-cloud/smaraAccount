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
