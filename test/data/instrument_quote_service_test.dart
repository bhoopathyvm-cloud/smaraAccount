import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smara_accounting/data/instrument_quote_service.dart';
import 'package:smara_accounting/domain/models/quote_provider.dart';

void main() {
  test(
    'stooq request includes only the ticker symbol, not quantity or cost',
    () async {
      Uri? captured;
      final service = InstrumentQuoteService(
        client: MockClient((request) async {
          captured = request.url;
          return http.Response(
            'Symbol,Date,Time,Open,High,Low,Close,Volume\n'
            'AAPL.US,2026-01-02,22:00:00,1,1,1,12.50,100\n',
            200,
          );
        }),
      );

      final quote = await service.fetchQuote(
        provider: QuoteProvider.stooq,
        ticker: 'AAPL.US',
      );

      expect(quote?.priceMinor, equals(1250));
      expect(captured, isNotNull);
      expect(captured!.queryParameters.containsKey('s'), isTrue);
      expect(captured!.toString().toLowerCase(), isNot(contains('quantity')));
      expect(captured!.toString().toLowerCase(), isNot(contains('cost')));
      expect(captured!.toString().toLowerCase(), isNot(contains('account')));
    },
  );

  test('failed quote resolves to null without throwing', () async {
    final service = InstrumentQuoteService(
      client: MockClient((request) async => http.Response('', 500)),
    );
    expect(
      await service.fetchQuote(provider: QuoteProvider.stooq, ticker: 'AAPL'),
      isNull,
    );
  });

  test('yahoo request uses ticker or ISIN only', () async {
    Uri? captured;
    final service = InstrumentQuoteService(
      client: MockClient((request) async {
        captured = request.url;
        return http.Response(
          '{"chart":{"result":[{"meta":{"regularMarketPrice":10.5,"currency":"USD"}}]}}',
          200,
        );
      }),
    );
    final quote = await service.fetchQuote(
      provider: QuoteProvider.yahooFinance,
      isin: 'US0378331005',
    );
    expect(quote?.priceMinor, equals(1050));
    expect(quote?.currency, equals('USD'));
    expect(captured!.path, contains('US0378331005'));
  });

  test(
    'yahoo JPY price scales by JPY\'s 0 decimal digits, not a hardcoded x100',
    () async {
      final service = InstrumentQuoteService(
        client: MockClient((request) async {
          return http.Response(
            '{"chart":{"result":[{"meta":{"regularMarketPrice":3000,"currency":"JPY"}}]}}',
            200,
          );
        }),
      );
      final quote = await service.fetchQuote(
        provider: QuoteProvider.yahooFinance,
        ticker: '7203.T',
      );
      expect(quote?.currency, equals('JPY'));
      expect(quote?.priceMinor, equals(3000));
    },
  );

  test(
    'yahoo 3-decimal currency price scales by its own minor-unit digit count',
    () async {
      final service = InstrumentQuoteService(
        client: MockClient((request) async {
          return http.Response(
            '{"chart":{"result":[{"meta":{"regularMarketPrice":1.234,"currency":"BHD"}}]}}',
            200,
          );
        }),
      );
      final quote = await service.fetchQuote(
        provider: QuoteProvider.yahooFinance,
        ticker: 'ALBH.BH',
      );
      expect(quote?.currency, equals('BHD'));
      expect(quote?.priceMinor, equals(1234));
    },
  );

  test('fetchQuote prefers an explicit resolved symbol over ticker', () async {
    Uri? captured;
    final service = InstrumentQuoteService(
      client: MockClient((request) async {
        captured = request.url;
        return http.Response(
          '{"chart":{"result":[{"meta":{"regularMarketPrice":10,"currency":"CHF"}}]}}',
          200,
        );
      }),
    );
    await service.fetchQuote(
      provider: QuoteProvider.yahooFinance,
      symbol: 'UBSG.SW',
      ticker: 'ubsg',
    );
    expect(captured!.path, contains('UBSG.SW'));
    expect(captured!.path, isNot(contains('ubsg,')));
  });

  group('searchIdentifier', () {
    const body =
        '{"quotes":['
        '{"symbol":"UBSG.SW","shortname":"UBS Group AG","longname":"UBS Group AG","exchDisp":"Swiss","quoteType":"EQUITY"},'
        '{"symbol":"UBS","shortname":"UBS Group AG","exchDisp":"NYSE","quoteType":"EQUITY"},'
        '{"symbol":"BTC-USD","shortname":"Bitcoin","exchDisp":"CCC","quoteType":"CRYPTOCURRENCY"}'
        ']}';

    test('returns candidates with a currency inferred from the suffix', () async {
      final service = InstrumentQuoteService(
        client: MockClient((request) async => http.Response(body, 200)),
      );
      final candidates = await service.searchIdentifier('CH0244767585');
      // The crypto row is filtered out; the two equities remain.
      expect(candidates.length, equals(2));
      final swiss = candidates.firstWhere((c) => c.symbol == 'UBSG.SW');
      expect(swiss.currency, equals('CHF'));
      expect(swiss.exchangeCode, equals('SIX'));
      final us = candidates.firstWhere((c) => c.symbol == 'UBS');
      expect(us.currency, equals('USD'));
      expect(us.exchangeCode, isNull);
    });

    test('sends only the query, no quantity/cost/account', () async {
      Uri? captured;
      final service = InstrumentQuoteService(
        client: MockClient((request) async {
          captured = request.url;
          return http.Response(body, 200);
        }),
      );
      await service.searchIdentifier('CH0244767585');
      expect(captured!.queryParameters['q'], equals('CH0244767585'));
      final lower = captured!.toString().toLowerCase();
      expect(lower, isNot(contains('quantity')));
      expect(lower, isNot(contains('cost')));
      expect(lower, isNot(contains('account')));
    });

    test('an empty query never hits the network', () async {
      var requested = false;
      final service = InstrumentQuoteService(
        client: MockClient((request) async {
          requested = true;
          return http.Response('{}', 200);
        }),
      );
      expect(await service.searchIdentifier('  '), isEmpty);
      expect(requested, isFalse);
    });

    test('a failed search resolves to an empty list', () async {
      final service = InstrumentQuoteService(
        client: MockClient((request) async => http.Response('boom', 500)),
      );
      expect(await service.searchIdentifier('AAPL'), isEmpty);
    });
  });
}
