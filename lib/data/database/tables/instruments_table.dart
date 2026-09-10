import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/instrument_kind.dart';

export '../../../domain/models/instrument_kind.dart';

@DataClassName('InstrumentRow')
class Instruments extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<InstrumentKind>()();
  TextColumn get ticker => text().nullable()();
  TextColumn get isin => text().nullable()();

  /// Canonical market-data symbol confirmed at Save (e.g. `UBSG.SW`), used
  /// in preference to [ticker] when fetching quotes
  /// (instrument-identifier-assist). Nullable; unresolved until the user
  /// confirms a listing or a later refresh resolves it.
  TextColumn get resolvedSymbol => text().nullable()();

  /// Registry code of the exchange the resolved listing trades on (e.g.
  /// `SIX`), binding its currency and national fallback endpoint.
  TextColumn get exchange => text().nullable()();

  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
