import 'package:flutter/foundation.dart';

import '../../../../data/books_set/active_books_session.dart';
import '../../../../data/repositories/books_set_repository.dart';
import '../../../../domain/app_error.dart';
import '../../../../l10n/l10n.dart';

/// Lists books sets and switches / creates / removes them via
/// [ActiveBooksSession] (books-switcher).
class BooksSwitcherViewModel extends ChangeNotifier with LocalizedErrorMixin {
  BooksSwitcherViewModel({required ActiveBooksSession session})
    : _session = session {
    _session.addListener(_onSessionChanged);
    _load();
  }

  final ActiveBooksSession _session;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  List<BooksSetInfo> _sets = const [];
  List<BooksSetInfo> get sets => _sets;

  void _onSessionChanged() {
    _load();
  }

  Future<void> _load() async {
    if (_disposed) return;
    _isLoading = true;
    notifyListeners();
    try {
      _sets = await _session.listSets();
      if (_disposed) return;
      clearFailure();
    } catch (e) {
      if (_disposed) return;
      setFailure(e);
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> refresh() => _load();

  bool _disposed = false;

  Future<bool> switchTo(String booksSetId) async {
    if (_isBusy) return false;
    _isBusy = true;
    notifyListeners();
    try {
      await _session.switchTo(booksSetId);
      _sets = await _session.listSets();
      clearFailure();
      return true;
    } catch (e) {
      setFailure(e);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> createSet(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      setFailure(const AppFailure(AppErrorCode.validationNameRequired));
      return false;
    }
    if (_isBusy) return false;
    _isBusy = true;
    notifyListeners();
    try {
      await _session.createSet(displayName: trimmed);
      clearFailure();
      return true;
    } catch (e) {
      setFailure(e);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> removeSet(String booksSetId) async {
    if (_isBusy) return false;
    _isBusy = true;
    notifyListeners();
    try {
      await _session.removeSet(booksSetId, confirmed: true);
      await _load();
      clearFailure();
      return true;
    } catch (e) {
      setFailure(e);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _session.removeListener(_onSessionChanged);
    super.dispose();
  }
}
