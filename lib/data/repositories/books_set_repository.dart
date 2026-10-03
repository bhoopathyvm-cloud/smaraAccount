import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/crypto/secure_key_storage.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../books_set/books_set_paths.dart';
import '../database/app_database.dart';

/// Summary of a books set available on this device.
class BooksSetInfo {
  const BooksSetInfo({
    required this.id,
    required this.displayName,
    required this.isActive,
  });

  final String id;

  /// User-given name, or empty when the set was never named (never the raw
  /// books-set id — UI falls back to a localized "Books N" label).
  final String displayName;
  final bool isActive;

  /// True when [displayName] is a real user-visible name (not empty and not
  /// the raw id left by earlier builds that stored the UUID as the name).
  bool get hasUserVisibleName => displayName.isNotEmpty && displayName != id;
}

/// Creates, lists, renames, removes, and switches books sets on this device
/// (linked-devices-and-sync / books-switcher). Each set has its own SQLite
/// file and namespaced signing key.
///
/// Does not depend on Identity/Account/Ledger repositories (ADR 0002).
class BooksSetRepository {
  BooksSetRepository({
    required Directory supportDirectory,
    required BooksSetStore store,
    required SecureKeyStorage secureStorage,
    Uuid? uuid,
  }) : _supportDirectory = supportDirectory,
       _store = store,
       _secureStorage = secureStorage,
       _uuid = uuid ?? const Uuid();

  final Directory _supportDirectory;
  final BooksSetStore _store;
  final SecureKeyStorage _secureStorage;
  final Uuid _uuid;

  AppDatabase? _activeDatabase;
  String? _activeBooksSetId;

  /// Currently open active-set database, if this repository opened one.
  AppDatabase? get activeDatabase => _activeDatabase;

  /// Id of the currently open books set, if any (sync; set in [_openSet]).
  String? get activeBooksSetId => _activeBooksSetId;

  /// App support directory used for books / receipts paths.
  Directory get supportDirectory => _supportDirectory;

  /// Ensures legacy layout is migrated, then opens the active set's database.
  Future<AppDatabase> openActive() async {
    await BooksSetPaths.migrateLegacyLayoutIfNeeded(
      supportDirectory: _supportDirectory,
      store: _store,
      secureStorage: _secureStorage,
    );
    var id = await _store.activeBooksSetId();
    if (id == null) {
      id = _uuid.v4();
      await _store.setActiveBooksSetId(id);
      await BooksSetPaths.ensureBooksSetDirectory(_supportDirectory, id);
    }
    return _openSet(id);
  }

  /// Creates a new empty books set, seeds metadata, and makes it active.
  /// Closes any previously open connection first.
  Future<BooksSetInfo> createSet({
    required String displayName,
    String? id,
  }) async {
    final setId = id ?? _uuid.v4();
    await BooksSetPaths.ensureBooksSetDirectory(_supportDirectory, setId);
    await _closeActive();
    await _store.setActiveBooksSetId(setId);
    await _openSet(setId, displayName: displayName);
    return BooksSetInfo(id: setId, displayName: displayName, isActive: true);
  }

  /// Lists books sets found under `books/`, reading display names from each
  /// set's metadata table when present. Unnamed sets (missing name, empty
  /// name, or legacy UUID-as-name) get an empty [BooksSetInfo.displayName]
  /// so the UI can show a localized fallback instead of the raw id.
  Future<List<BooksSetInfo>> listSets() async {
    final activeId = await _store.activeBooksSetId();
    final ids = await BooksSetPaths.listBooksSetIds(_supportDirectory);
    final result = <BooksSetInfo>[];
    for (final id in ids) {
      final name = await _readDisplayName(id);
      final userVisible = name != null && name.isNotEmpty && name != id
          ? name
          : '';
      result.add(
        BooksSetInfo(
          id: id,
          displayName: userVisible,
          isActive: id == activeId,
        ),
      );
    }
    return result;
  }

  /// Renames a books set's user-visible name inside that set's database.
  Future<void> renameSet(String booksSetId, String displayName) async {
    final file = BooksSetPaths.databaseFile(_supportDirectory, booksSetId);
    if (!await file.exists()) {
      throw StateError('Books set "$booksSetId" does not exist.');
    }
    if (_activeDatabase != null &&
        await _store.activeBooksSetId() == booksSetId) {
      await _upsertDisplayName(_activeDatabase!, booksSetId, displayName);
      return;
    }
    final previousWarn = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase.openFile(file);
    try {
      await _upsertDisplayName(db, booksSetId, displayName);
    } finally {
      await db.close();
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = previousWarn;
    }
  }

  /// Removes a books set's directory and namespaced signing key after the
  /// caller has confirmed. Refuses to remove the only remaining set, or the
  /// active set without switching first when others exist.
  Future<void> removeSet(String booksSetId, {required bool confirmed}) async {
    if (!confirmed) {
      throw ArgumentError('Removing a books set requires confirmation.');
    }
    final ids = await BooksSetPaths.listBooksSetIds(_supportDirectory);
    if (!ids.contains(booksSetId)) {
      throw StateError('Books set "$booksSetId" does not exist.');
    }
    if (ids.length == 1) {
      throw StateError('Cannot remove the only books set on this device.');
    }
    final activeId = await _store.activeBooksSetId();
    if (activeId == booksSetId) {
      throw StateError(
        'Switch to another books set before removing the active one.',
      );
    }

    await BooksSetPaths.deleteBooksSetDirectory(_supportDirectory, booksSetId);
    final keys = SigningKeyService(
      secureStorage: _secureStorage,
      booksSetId: booksSetId,
    );
    await keys.deleteStoredKey();
  }

  /// Closes the current Drift connection, marks [booksSetId] active, and
  /// opens that set's database file.
  Future<AppDatabase> switchActiveSet(String booksSetId) async {
    final dir = BooksSetPaths.booksSetDirectory(_supportDirectory, booksSetId);
    if (!await dir.exists()) {
      throw StateError('Books set "$booksSetId" does not exist.');
    }
    await _closeActive();
    await _store.setActiveBooksSetId(booksSetId);
    return _openSet(booksSetId);
  }

  /// Signing key service scoped to a books set (or the active set).
  SigningKeyService signingKeyServiceFor(String booksSetId) {
    return SigningKeyService(
      secureStorage: _secureStorage,
      booksSetId: booksSetId,
    );
  }

  Future<void> close() => _closeActive();

  Future<AppDatabase> _openSet(String booksSetId, {String? displayName}) async {
    await BooksSetPaths.ensureBooksSetDirectory(_supportDirectory, booksSetId);
    final file = BooksSetPaths.databaseFile(_supportDirectory, booksSetId);
    final db = AppDatabase.openFile(file);
    _activeDatabase = db;
    _activeBooksSetId = booksSetId;
    // Touch the database so migrations (including schema 19 tables) run
    // before callers insert metadata or entries.
    await db.customSelect('SELECT 1').get();
    await _ensureMetadataRow(db, booksSetId, displayName: displayName);
    return db;
  }

  Future<void> _ensureMetadataRow(
    AppDatabase db,
    String booksSetId, {
    String? displayName,
  }) async {
    final existing = await (db.select(
      db.booksSetMetadata,
    )..where((t) => t.id.equals(booksSetId))).getSingleOrNull();
    if (existing != null) {
      // Apply an explicit non-empty rename.
      if (displayName != null &&
          displayName.isNotEmpty &&
          existing.displayName != displayName) {
        await (db.update(db.booksSetMetadata)
              ..where((t) => t.id.equals(booksSetId)))
            .write(BooksSetMetadataCompanion(displayName: Value(displayName)));
        return;
      }
      // Clear legacy UUID-as-name so listSets never surfaces the raw id.
      if (existing.displayName == booksSetId) {
        await (db.update(db.booksSetMetadata)
              ..where((t) => t.id.equals(booksSetId)))
            .write(const BooksSetMetadataCompanion(displayName: Value('')));
      }
      return;
    }
    await db
        .into(db.booksSetMetadata)
        .insert(
          BooksSetMetadataCompanion.insert(
            id: booksSetId,
            displayName: displayName ?? '',
          ),
        );
  }

  Future<void> _upsertDisplayName(
    AppDatabase db,
    String booksSetId,
    String displayName,
  ) async {
    final existing = await (db.select(
      db.booksSetMetadata,
    )..where((t) => t.id.equals(booksSetId))).getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.booksSetMetadata)
          .insert(
            BooksSetMetadataCompanion.insert(
              id: booksSetId,
              displayName: displayName,
            ),
          );
    } else {
      await (db.update(db.booksSetMetadata)
            ..where((t) => t.id.equals(booksSetId)))
          .write(BooksSetMetadataCompanion(displayName: Value(displayName)));
    }
  }

  Future<String?> _readDisplayName(String booksSetId) async {
    final file = BooksSetPaths.databaseFile(_supportDirectory, booksSetId);
    if (!await file.exists()) return null;
    if (_activeDatabase != null &&
        await _store.activeBooksSetId() == booksSetId) {
      final row = await (_activeDatabase!.select(
        _activeDatabase!.booksSetMetadata,
      )..where((t) => t.id.equals(booksSetId))).getSingleOrNull();
      return row?.displayName;
    }
    // Brief secondary open for metadata only — not the active connection.
    final previousWarn = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase.openFile(file);
    try {
      await db.customSelect('SELECT 1').get();
      final row = await (db.select(
        db.booksSetMetadata,
      )..where((t) => t.id.equals(booksSetId))).getSingleOrNull();
      return row?.displayName;
    } finally {
      await db.close();
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = previousWarn;
    }
  }

  Future<void> _closeActive() async {
    final db = _activeDatabase;
    _activeDatabase = null;
    _activeBooksSetId = null;
    if (db != null) {
      await db.close();
    }
  }
}
