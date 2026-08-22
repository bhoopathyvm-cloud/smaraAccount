import 'package:flutter/foundation.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/lock/app_lock_service.dart';
import '../../../../domain/lock/biometric_authenticator.dart';
import '../../../../l10n/l10n.dart';
import '../../../../domain/exceptions.dart';
import '../../../core/app_lock_controller.dart';

/// The unlock screen's form state (app-lock spec: "Application Lock").
/// Offers biometrics first (auto-prompted once, on open) when enabled,
/// with the PIN always available as a fallback or primary path.
class LockViewModel extends ChangeNotifier with LocalizedErrorMixin {
  LockViewModel({
    required AppLockService appLockService,
    required BiometricAuthenticator biometricAuthenticator,
    required SettingsRepository settingsRepository,
    required AppLockController lockController,
  }) : _appLockService = appLockService,
       _biometricAuthenticator = biometricAuthenticator,
       _settingsRepository = settingsRepository,
       _lockController = lockController {
    _init();
  }

  final AppLockService _appLockService;
  final BiometricAuthenticator _biometricAuthenticator;
  final SettingsRepository _settingsRepository;
  final AppLockController _lockController;

  bool _biometricEnabled = false;
  bool get biometricEnabled => _biometricEnabled;

  bool _isVerifying = false;
  bool get isVerifying => _isVerifying;

  Future<void> _init() async {
    _biometricEnabled = await _settingsRepository.isAppLockBiometricEnabled();
    notifyListeners();
    if (_biometricEnabled) {
      await authenticateWithBiometrics();
    }
  }

  /// Silent on failure/cancellation - the PIN field stays available
  /// either way, so a dismissed biometric prompt isn't a dead end.
  Future<void> authenticateWithBiometrics() async {
    _isVerifying = true;
    notifyListeners();
    final success = await _biometricAuthenticator.authenticate(
      reason: englishAppLocalizations.unlockBiometricReason,
    );
    _isVerifying = false;
    notifyListeners();
    if (success) {
      _lockController.markUnlocked();
    }
  }

  Future<bool> submitPin(String pin) async {
    _isVerifying = true;
    clearFailure();
    notifyListeners();
    final ok = await _appLockService.verifyPin(pin);
    _isVerifying = false;
    if (ok) {
      notifyListeners();
      _lockController.markUnlocked();
      return true;
    }
    setFailure(const AppFailure(AppErrorCode.validationWrongPin));
    return false;
  }
}
