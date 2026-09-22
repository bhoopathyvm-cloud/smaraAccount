import 'package:flutter/foundation.dart';

import '../../../../data/repositories/device_migration_bundle_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';

/// Startup Import From Backup path (spec: `device-migration-bundle`).
/// Unlike [RestoreIdentityViewModel] (key-only restore onto a device that
/// already has the matching database some other way), this replaces the
/// database *and* restores the private key together from one file, so
/// the device is ready to record a new entry immediately on success.
class BundleImportViewModel extends ChangeNotifier with LocalizedErrorMixin {
  BundleImportViewModel({
    required DeviceMigrationBundleRepository bundleRepository,
  }) : _bundleRepository = bundleRepository;

  final DeviceMigrationBundleRepository _bundleRepository;

  bool _isImporting = false;
  bool get isImporting => _isImporting;

  /// Returns true on success. On success, this app's database connection
  /// is closed - the caller is responsible for having the user restart
  /// the app, same as [SettingsViewModel.restoreBackup].
  Future<bool> importBundle({
    required String fileContents,
    required String passphrase,
  }) async {
    _isImporting = true;
    clearFailure();
    notifyListeners();

    try {
      await _bundleRepository.importBundle(
        fileContents: fileContents,
        passphrase: passphrase,
      );
      _isImporting = false;
      notifyListeners();
      return true;
    } on InvalidDeviceMigrationBundleException catch (e) {
      setFailure(e);
    } on ForeignDeviceMigrationBundleIdentityException catch (e) {
      setFailure(e);
    } catch (_) {
      setFailure(
        const AppFailure(AppErrorCode.deviceMigrationBundleImportFailed),
      );
    }

    _isImporting = false;
    notifyListeners();
    return false;
  }
}
