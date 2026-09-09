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
import 'package:smara_accounting/data/repositories/investment_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/investment/exchange_registry.dart';
import 'package:smara_accounting/domain/models/instrument.dart';

import '../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late LedgerRepository ledger;
  late InvestmentRepository investment;
  late Instrument instrument;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
    ledger = LedgerRepository(database: db, signingKeyService: keys);
    final accountRepository = AccountRepository(
      database: db,
      ledgerRepository: ledger,
    );
    final identityRepository = IdentityRepository(
      database: db,
      accountRepository: accountRepository,
      signingKeyService: keys,
    );
    investment = InvestmentRepository(database: db, ledgerRepository: ledger);
    final generated = await identityRepository.generateFirstIdentity();
    await identityRepository.confirmFirstIdentity(generated, currency: 'USD');
    instrument = await investment.createInstrument(
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
      investmentRepository: investment,
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
      investmentRepository: investment,
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
      (await investment.watchInstrumentQuotes().first).single.priceMinor,
      equals(1000),
    );
  });

  test('refresh sends the resolved symbol in preference to the ticker', () async {
    final resolved = await investment.createInstrument(
      name: 'UBS',
      kind: InstrumentKind.stock,
      ticker: 'ubsg',
      resolvedSymbol: 'UBSG.SW',
      exchange: 'SIX',
    );
    String? stooqSymbol;
    final refresh = InstrumentQuoteRefresh(
      settingsRepository: SettingsRepository(),
      investmentRepository: investment,
      quoteService: InstrumentQuoteService(
        client: MockClient((request) async {
          if (request.url.path.contains('/q/l/')) {
            stooqSymbol = request.url.queryParameters['s'];
            return http.Response(
              'Symbol,Date,Time,Open,High,Low,Close,Volume\n'
              'UBSG.SW,2026-01-02,22:00:00,1,1,1,25.00,1\n',
              200,
            );
          }
          return http.Response('', 500);
        }),
      ),
    );

    await refresh.refresh([resolved]);
    // The resolved symbol, not the raw `ubsg`, goes on the wire.
    expect(stooqSymbol, equals('ubsg.sw'));
  });

  test('national fallback is tried only when the primary provider misses', () async {
    final nse = await investment.createInstrument(
      name: 'Reliance',
      kind: InstrumentKind.stock,
      ticker: 'RELIANCE',
      resolvedSymbol: 'RELIANCE.NS',
      exchange: 'NSE',
    );
    var yahooChartCalls = 0;
    final refresh = InstrumentQuoteRefresh(
      settingsRepository: SettingsRepository(),
      investmentRepository: investment,
      quoteService: InstrumentQuoteService(
        client: MockClient((request) async {
          if (request.url.path.contains('/q/l/')) {
            // Primary (Stooq) has no .NS listing.
            return http.Response('', 404);
          }
          if (request.url.path.contains('/v8/finance/chart/')) {
            yahooChartCalls++;
            return http.Response(
              '{"chart":{"result":[{"meta":{"regularMarketPrice":1400,"currency":"INR"}}]}}',
              200,
            );
          }
          return http.Response('', 500);
        }),
      ),
    );

    await refresh.refresh([nse]);
    expect(yahooChartCalls, equals(1));
    final quote = (await investment.watchInstrumentQuotes().first).single;
    expect(quote.currency, equals('INR'));
    expect(quote.priceMinor, equals(140000));
  });

  test('national fallback is skipped when the primary provider succeeds', () async {
    final nse = await investment.createInstrument(
      name: 'Reliance',
      kind: InstrumentKind.stock,
      ticker: 'RELIANCE',
      resolvedSymbol: 'RELIANCE.NS',
      exchange: 'NSE',
    );
    var yahooChartCalls = 0;
    final refresh = InstrumentQuoteRefresh(
      settingsRepository: SettingsRepository(),
      investmentRepository: investment,
      quoteService: InstrumentQuoteService(
        client: MockClient((request) async {
          if (request.url.path.contains('/q/l/')) {
            return http.Response(
              'Symbol,Date,Time,Open,High,Low,Close,Volume\n'
              'RELIANCE.NS,2026-01-02,22:00:00,1,1,1,30.00,1\n',
              200,
            );
          }
          if (request.url.path.contains('/v8/finance/chart/')) {
            yahooChartCalls++;
            return http.Response('', 500);
          }
          return http.Response('', 500);
        }),
      ),
    );

    await refresh.refresh([nse]);
    expect(yahooChartCalls, equals(0));
  });

  test('an unresolved instrument is resolved and stored on refresh', () async {
    final settings = SettingsRepository();
    await settings.setDefaultExchange(exchangeForCode('SIX')!);
    final unresolved = await investment.createInstrument(
      name: 'UBS',
      kind: InstrumentKind.stock,
      isin: 'CH0244767585',
    );
    final refresh = InstrumentQuoteRefresh(
      settingsRepository: settings,
      investmentRepository: investment,
      quoteService: InstrumentQuoteService(
        client: MockClient((request) async {
          if (request.url.path.contains('/v1/finance/search')) {
            return http.Response(
              '{"quotes":['
              '{"symbol":"UBSG.SW","longname":"UBS Group AG","exchDisp":"Swiss","quoteType":"EQUITY"},'
              '{"symbol":"UBS","longname":"UBS Group AG","exchDisp":"NYSE","quoteType":"EQUITY"}'
              ']}',
              200,
            );
          }
          if (request.url.path.contains('/q/l/')) {
            return http.Response(
              'Symbol,Date,Time,Open,High,Low,Close,Volume\n'
              'UBSG.SW,2026-01-02,22:00:00,1,1,1,25.00,1\n',
              200,
            );
          }
          return http.Response('', 500);
        }),
      ),
    );

    await refresh.refresh([unresolved]);
    final stored = (await investment.watchInstruments(
      includeArchived: true,
    ).first).firstWhere((i) => i.id == unresolved.id);
    // The default exchange (SIX) biases the auto-pick to the .SW listing.
    expect(stored.resolvedSymbol, equals('UBSG.SW'));
    expect(stored.exchange, equals('SIX'));
  });
}
