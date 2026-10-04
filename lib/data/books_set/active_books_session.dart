import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/crypto/secure_key_storage.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../../domain/linked_devices/reserved_join_identity.dart';
import '../database/app_database.dart';
import '../repositories/account_repository.dart';
import '../repositories/books_set_repository.dart';
import '../repositories/identity_repository.dart';
import '../repositories/ledger_repository.dart';
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

  /// Creates this device's Signing Identity for [booksSetId] under that set's
  /// namespaced secure-storage key, without switching the active set.
  ///
  /// Call before the join hello so the host pins the identity that will sign
  /// the joined set — never the household set's key (Decision 4).
  Future<ReservedJoinIdentity> reserveJoinIdentity({
    required String booksSetId,
    String currency = 'USD',
  }) async {
    await BooksSetPaths.ensureBooksSetDirectory(
      _booksSets.supportDirectory,
      booksSetId,
    );
    final file = BooksSetPaths.databaseFile(
      _booksSets.supportDirectory,
      booksSetId,
    );
    final keys = _booksSets.signingKeyServiceFor(booksSetId);
    final previousWarn = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase.openFile(file);
    try {
      await db.customSelect('SELECT 1').get();
      final ledger = LedgerRepository(database: db, signingKeyService: keys);
      final accounts = AccountRepository(
        database: db,
        ledgerRepository: ledger,
      );
      final identity = IdentityRepository(
        database: db,
        accountRepository: accounts,
        signingKeyService: keys,
      );
      var current = await identity.currentIdentity();
      if (current == null) {
        final generated = await identity.generateFirstIdentity();
        current = await identity.confirmFirstIdentity(
          generated,
          currency: currency,
          seedStarterCategories: false,
        );
      }
      return ReservedJoinIdentity(
        booksSetId: booksSetId,
        identityId: current.identityId,
        publicKey: current.publicKey,
      );
    } finally {
      await db.close();
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = previousWarn;
    }
  }

  /// Opens [booksSetId] (creating an empty set when missing), runs [seed]
  /// against that database, then notifies listeners.
  ///
  /// Join must seed membership/identity **before** notify so the router
  /// rebuild does not treat the set as a fresh New-setup device.
  Future<void> openJoinedSet({
    required String booksSetId,
    String displayName = '',
    required Future<void> Function(AppDatabase db, SigningKeyService keys) seed,
  }) async {
    final ids = await BooksSetPaths.listBooksSetIds(
      _booksSets.supportDirectory,
    );
    if (ids.contains(booksSetId)) {
      _database = await _booksSets.switchActiveSet(booksSetId);
    } else {
      await _booksSets.createSet(displayName: displayName, id: booksSetId);
      _database = _booksSets.activeDatabase;
    }
    await seed(database, _signingKeyService);
    _generation++;
    notifyListeners();
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
