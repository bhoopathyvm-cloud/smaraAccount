import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/crypto/secure_key_storage.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../database/app_database.dart';
import '../repositories/books_set_repository.dart';
import 'books_set_paths.dart';

/// Owns the active books set's [AppDatabase] connection and notifies
/// listeners when the set is switched, created, or removed so DI and UI
/// rebuild against the newly opened file (books-switcher / linked-devices).
class ActiveBooksSession extends ChangeNotifier {
  ActiveBooksSession({
    required BooksSetRepository booksSets,
    required BooksSetStore store,
    SigningKeyService? signingKeyService,
  }) : _booksSets = booksSets,
       _store = store,
       _signingKeyService =
           signingKeyService ??
           SigningKeyService(resolveBooksSetId: store.activeBooksSetId);

  /// Production constructor: resolves the app support directory and opens
  /// the active set (running the legacy layout migration if needed).
  static Future<ActiveBooksSession> open({
    Directory? supportDirectory,
    BooksSetStore? store,
    SecureKeyStorage? secureStorage,
  }) async {
    final dir = supportDirectory ?? await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final booksStore = store ?? BooksSetStore();
    final storage = secureStorage ?? FlutterSecureKeyStorage();
    final booksSets = BooksSetRepository(
      supportDirectory: dir,
      store: booksStore,
      secureStorage: storage,
    );
    final session = ActiveBooksSession(
      booksSets: booksSets,
      store: booksStore,
      signingKeyService: SigningKeyService(
        secureStorage: storage,
        resolveBooksSetId: booksStore.activeBooksSetId,
      ),
    );
    await session.ensureOpen();
    return session;
  }

  final BooksSetRepository _booksSets;
  final BooksSetStore _store;
  final SigningKeyService _signingKeyService;

  AppDatabase? _database;
  int _generation = 0;

  BooksSetRepository get booksSets => _booksSets;
  BooksSetStore get store => _store;
  SigningKeyService get signingKeyService => _signingKeyService;

  /// Monotonic counter bumped on every open/switch/create so ProxyProviders
  /// can recreate ViewModels bound to the previous database.
  int get generation => _generation;

  bool get isReady => _database != null;

  AppDatabase get database {
    final db = _database;
    if (db == null) {
      throw StateError('ActiveBooksSession.ensureOpen() has not completed.');
    }
    return db;
  }

  Future<String?> activeBooksSetId() => _store.activeBooksSetId();

  Future<void> ensureOpen() async {
    _database = await _booksSets.openActive();
    _generation++;
    notifyListeners();
  }

  Future<List<BooksSetInfo>> listSets() => _booksSets.listSets();

  Future<void> switchTo(String booksSetId) async {
    _database = await _booksSets.switchActiveSet(booksSetId);
    _generation++;
    notifyListeners();
  }

  Future<BooksSetInfo> createSet({
    required String displayName,
    String? id,
  }) async {
    final info = await _booksSets.createSet(displayName: displayName, id: id);
    _database = _booksSets.activeDatabase;
    _generation++;
    notifyListeners();
    return info;
  }

  Future<void> renameSet(String booksSetId, String displayName) {
    return _booksSets.renameSet(booksSetId, displayName);
  }

  Future<void> removeSet(String booksSetId, {required bool confirmed}) async {
    await _booksSets.removeSet(booksSetId, confirmed: confirmed);
    notifyListeners();
  }

  @override
  void dispose() {
    _booksSets.close();
    super.dispose();
  }
}
