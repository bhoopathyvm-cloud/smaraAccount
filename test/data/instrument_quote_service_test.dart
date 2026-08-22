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
}
