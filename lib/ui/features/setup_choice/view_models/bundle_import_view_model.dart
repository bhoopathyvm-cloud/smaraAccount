import 'package:flutter/foundation.dart';

import '../../../../data/repositories/books_copy_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';

/// Startup "Restore from a copy" path (books-copy-and-continuation).
/// Replaces the local database with a Books Copy (or a legacy backup /
/// bundle with any key discarded). On success the caller must have the
/// user restart the app.
class BundleImportViewModel extends ChangeNotifier with LocalizedErrorMixin {
  BundleImportViewModel({required BooksCopyRepository booksCopyRepository})
    : _booksCopyRepository = booksCopyRepository;

  final BooksCopyRepository _booksCopyRepository;

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
      await _booksCopyRepository.restoreBooksCopy(
        fileContents: fileContents,
        passphrase: passphrase,
      );
      _isImporting = false;
      notifyListeners();
      return true;
    } on InvalidLedgerBackupException catch (e) {
      setFailure(e);
    } catch (_) {
      setFailure(const AppFailure(AppErrorCode.backupRestoreFailed));
    }

    _isImporting = false;
    notifyListeners();
    return false;
  }
}
