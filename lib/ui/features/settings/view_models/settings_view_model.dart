import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/lock/app_lock_service.dart';
import '../../../../domain/lock/biometric_authenticator.dart';
import '../../../../domain/models/exchange_rate_provider.dart';
import '../../../../domain/models/quote_provider.dart';
import '../../../../domain/models/research_tool.dart';
import '../../../core/app_lock_controller.dart';

/// The app's Settings surface: the reference exchange-rate lookup's
/// enable/disable toggle and predefined-provider selection (design.md
/// Decision 5), ledger-backup-restore's Save/Restore backup actions, and
/// app-lock's PIN/biometric/timeout/snapshot-hiding controls. Deliberately
/// minimal - not a general preferences screen.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required SettingsRepository settingsRepository,
    required LedgerRepository ledgerRepository,
    required AppLockService appLockService,
    required BiometricAuthenticator biometricAuthenticator,
    required AppLockController appLockController,
  }) : _settingsRepository = settingsRepository,
       _ledgerRepository = ledgerRepository,
       _appLockService = appLockService,
       _biometricAuthenticator = biometricAuthenticator,
       _appLockController = appLockController {
    _load();
  }

  final SettingsRepository _settingsRepository;
  final LedgerRepository _ledgerRepository;
  final AppLockService _appLockService;
  final BiometricAuthenticator _biometricAuthenticator;
  final AppLockController _appLockController;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _referenceRateLookupEnabled = false;
  bool get referenceRateLookupEnabled => _referenceRateLookupEnabled;

  ExchangeRateProvider _selectedProvider = ExchangeRateProvider.values.first;
  ExchangeRateProvider get selectedProvider => _selectedProvider;

  bool _marketPriceFetchEnabled = true;
  bool get marketPriceFetchEnabled => _marketPriceFetchEnabled;

  QuoteProvider _selectedQuoteProvider = QuoteProvider.values.first;
  QuoteProvider get selectedQuoteProvider => _selectedQuoteProvider;

  ResearchTool _selectedResearchTool = ResearchTool.values.first;
  ResearchTool get selectedResearchTool => _selectedResearchTool;

  bool _isAppLockEnabled = false;
  bool get isAppLockEnabled => _isAppLockEnabled;

  int _appLockTimeoutMinutes = 0;
  int get appLockTimeoutMinutes => _appLockTimeoutMinutes;

  bool _isBiometricEnabled = false;
  bool get isBiometricEnabled => _isBiometricEnabled;

  bool _isBiometricAvailable = false;
  bool get isBiometricAvailable => _isBiometricAvailable;

  bool get isSnapshotHidingEnabled =>
      _appLockController.isSnapshotHidingEnabled;

  /// app-lock design.md Decision 2: a real app-switcher-snapshot
  /// mechanism only exists on iOS/Android in this app's four target
  /// platforms - Settings offers the toggle only there, and states
  /// plainly on desktop that there's nothing to turn on rather than
  /// showing a no-op switch.
  bool get isSnapshotHidingAvailable =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  Future<void> _load() async {
    _referenceRateLookupEnabled = await _settingsRepository
        .isReferenceRateLookupEnabled();
    _selectedProvider = await _settingsRepository.selectedProvider();
    _marketPriceFetchEnabled = await _settingsRepository
        .isMarketPriceFetchEnabled();
    _selectedQuoteProvider = await _settingsRepository.selectedQuoteProvider();
    _selectedResearchTool = await _settingsRepository.selectedResearchTool();
    _isAppLockEnabled = await _settingsRepository.isAppLockEnabled();
    _appLockTimeoutMinutes = await _settingsRepository.appLockTimeoutMinutes();
    _isBiometricEnabled = await _settingsRepository.isAppLockBiometricEnabled();
    _isBiometricAvailable = await _biometricAuthenticator.isAvailable();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setReferenceRateLookupEnabled(bool value) async {
    _referenceRateLookupEnabled = value;
    notifyListeners();
    await _settingsRepository.setReferenceRateLookupEnabled(value);
  }

  Future<void> setSelectedProvider(ExchangeRateProvider provider) async {
    _selectedProvider = provider;
    notifyListeners();
    await _settingsRepository.setSelectedProvider(provider);
  }

  Future<void> setMarketPriceFetchEnabled(bool value) async {
    _marketPriceFetchEnabled = value;
    notifyListeners();
    await _settingsRepository.setMarketPriceFetchEnabled(value);
  }

  Future<void> setSelectedQuoteProvider(QuoteProvider provider) async {
    _selectedQuoteProvider = provider;
    notifyListeners();
    await _settingsRepository.setSelectedQuoteProvider(provider);
  }

  Future<void> setSelectedResearchTool(ResearchTool tool) async {
    _selectedResearchTool = tool;
    notifyListeners();
    await _settingsRepository.setSelectedResearchTool(tool);
  }

  bool _isBackingUp = false;
  bool get isBackingUp => _isBackingUp;

  bool _isRestoring = false;
  bool get isRestoring => _isRestoring;

  String? _backupErrorMessage;
  String? get backupErrorMessage => _backupErrorMessage;
  void clearBackupError() {
    if (_backupErrorMessage == null) return;
    _backupErrorMessage = null;
    notifyListeners();
  }

  /// Returns the encrypted backup file's contents, or null (with
  /// [backupErrorMessage] set) on failure.
  Future<String?> exportBackup({required String passphrase}) async {
    _isBackingUp = true;
    _backupErrorMessage = null;
    notifyListeners();
    try {
      final contents = await _ledgerRepository.exportLedgerBackup(
        passphrase: passphrase,
      );
      _isBackingUp = false;
      notifyListeners();
      return contents;
    } catch (e) {
      _isBackingUp = false;
      _backupErrorMessage = 'Could not create the backup: $e';
      notifyListeners();
      return null;
    }
  }

  /// Restores from [fileContents]. On success, this app's database
  /// connection is closed - the caller is responsible for having the user
  /// restart the app. On failure, [backupErrorMessage] explains why and
  /// nothing on disk has changed.
  Future<bool> restoreBackup({
    required String fileContents,
    required String passphrase,
  }) async {
    _isRestoring = true;
    _backupErrorMessage = null;
    notifyListeners();
    try {
      await _ledgerRepository.restoreLedgerBackup(
        fileContents: fileContents,
        passphrase: passphrase,
      );
      _isRestoring = false;
      notifyListeners();
      return true;
    } on ForeignBackupIdentityException catch (e) {
      _isRestoring = false;
      _backupErrorMessage = e.message;
      notifyListeners();
      return false;
    } on InvalidLedgerBackupException catch (e) {
      _isRestoring = false;
      _backupErrorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isRestoring = false;
      _backupErrorMessage =
          'Could not restore this backup - wrong passphrase, or not a '
          'Smara backup file.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> hasPinSet() => _appLockService.hasPinSet();

  /// Sets [pin] as the app-lock PIN and turns app lock on. Call only
  /// after the UI has already confirmed the user typed the same PIN
  /// twice - this method itself does not ask for confirmation.
  Future<void> enableAppLock(String pin) async {
    await _appLockService.setPin(pin);
    await _settingsRepository.setAppLockEnabled(true);
    _isAppLockEnabled = true;
    notifyListeners();
  }

  /// Turns app lock off and clears the stored PIN - re-enabling always
  /// starts from a fresh PIN, rather than silently keeping an old one
  /// live while "disabled".
  Future<void> disableAppLock() async {
    await _appLockService.clearPin();
    await _settingsRepository.setAppLockEnabled(false);
    await _settingsRepository.setAppLockBiometricEnabled(false);
    _isAppLockEnabled = false;
    _isBiometricEnabled = false;
    notifyListeners();
  }

  /// Verifies [currentPin] before setting [newPin]. Returns false (PIN
  /// left unchanged) if [currentPin] doesn't match the one on record.
  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final matches = await _appLockService.verifyPin(currentPin);
    if (!matches) return false;
    await _appLockService.setPin(newPin);
    return true;
  }

  Future<void> setAppLockTimeoutMinutes(int minutes) async {
    _appLockTimeoutMinutes = minutes;
    notifyListeners();
    await _settingsRepository.setAppLockTimeoutMinutes(minutes);
  }

  Future<void> setBiometricEnabled(bool value) async {
    _isBiometricEnabled = value;
    notifyListeners();
    await _settingsRepository.setAppLockBiometricEnabled(value);
  }

  Future<void> setSnapshotHidingEnabled(bool value) async {
    await _appLockController.setSnapshotHidingEnabled(value);
    notifyListeners();
  }
}
