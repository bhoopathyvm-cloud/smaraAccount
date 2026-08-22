import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/instrument_quote_refresh.dart';
import 'package:smara_accounting/data/instrument_quote_service.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/instrument.dart';

import '../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late LedgerRepository ledger;
  late Instrument instrument;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    ledger = LedgerRepository(
      database: db,
      signingKeyService: SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      ),
    );
    final generated = await ledger.generateFirstIdentity();
    await ledger.confirmFirstIdentity(generated, currency: 'USD');
    instrument = await ledger.createInstrument(
      name: 'Apple',
      kind: InstrumentKind.stock,
      ticker: 'AAPL.US',
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('disable stops quote HTTP requests', () async {
    final settings = SettingsRepository();
    await settings.setMarketPriceFetchEnabled(false);
    var requested = false;
    final refresh = InstrumentQuoteRefresh(
      settingsRepository: settings,
      ledgerRepository: ledger,
      quoteService: InstrumentQuoteService(
        client: MockClient((request) async {
          requested = true;
          return http.Response('', 500);
        }),
      ),
    );

    await refresh.refresh([instrument]);
    expect(requested, isFalse);
  });

  test('enabled refresh does not put quantity on the wire', () async {
    Uri? captured;
    final refresh = InstrumentQuoteRefresh(
      settingsRepository: SettingsRepository(),
      ledgerRepository: ledger,
      quoteService: InstrumentQuoteService(
        client: MockClient((request) async {
          captured = request.url;
          return http.Response(
            'Symbol,Date,Time,Open,High,Low,Close,Volume\n'
            'AAPL.US,2026-01-02,22:00:00,1,1,1,10.00,1\n',
            200,
          );
        }),
      ),
    );

    await refresh.refresh([instrument]);
    expect(captured, isNotNull);
    expect(captured!.toString().toLowerCase(), isNot(contains('quantity')));
    expect(
      (await ledger.watchInstrumentQuotes().first).single.priceMinor,
      equals(1000),
    );
  });
}
