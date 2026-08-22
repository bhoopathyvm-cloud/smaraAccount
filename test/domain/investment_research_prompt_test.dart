import 'package:smara_accounting/domain/investment_research_prompt.dart';
import 'package:smara_accounting/domain/models/instrument.dart';
import 'package:smara_accounting/domain/models/research_tool.dart';
import 'package:test/test.dart';

void main() {
  const apple = Instrument(
    id: 'i1',
    name: 'Apple Inc',
    kind: InstrumentKind.stock,
    ticker: 'AAPL',
    isin: 'US0378331005',
    archived: false,
  );

  test('prompt includes identifiers and research asks, not advice', () {
    final prompt = buildInvestmentResearchPrompt(apple);
    expect(prompt, contains('Apple Inc'));
    expect(prompt, contains('AAPL'));
    expect(prompt, contains('US0378331005'));
    expect(prompt.toLowerCase(), contains('downside'));
    expect(prompt.toLowerCase(), contains('upside'));
    expect(prompt.toLowerCase(), contains('not financial advice'));
    expect(prompt.toLowerCase(), contains('do not give buy, sell, or hold'));
  });

  test('prompt omits quantity, cost, and account name', () {
    final prompt = buildInvestmentResearchPrompt(apple);
    expect(prompt.toLowerCase(), isNot(contains('quantity')));
    expect(prompt.toLowerCase(), isNot(contains('cost')));
    expect(prompt.toLowerCase(), isNot(contains('brokerage')));
    expect(prompt.toLowerCase(), isNot(contains('checking')));
  });

  test('chatgpt query url encodes the prompt', () {
    final prompt = buildInvestmentResearchPrompt(apple);
    final uri = researchQueryUri(ResearchTool.chatGpt, prompt);
    expect(uri, isNotNull);
    expect(uri!.host, equals('chatgpt.com'));
    expect(uri.queryParameters['q'], equals(prompt));
  });
}
