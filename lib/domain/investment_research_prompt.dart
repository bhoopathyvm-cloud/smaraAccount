import 'models/instrument.dart';
import 'models/research_tool.dart';

/// Builds the packed research prompt from identifiers only — never
/// quantity, cost, or account name (investment-research-enablement).
String buildInvestmentResearchPrompt(Instrument instrument) {
  final ticker = instrument.ticker?.trim();
  final isin = instrument.isin?.trim();
  final tickerLine = (ticker == null || ticker.isEmpty)
      ? 'Ticker: (none provided)'
      : 'Ticker: $ticker';
  final isinLine = (isin == null || isin.isEmpty)
      ? 'ISIN: (none provided)'
      : 'ISIN: $isin';
  return 'Research this publicly listed instrument for a household investor. '
      'Identify the issuer, summarize recent news with dates if known, and '
      'outline downside risks and upside drivers. Separate facts from '
      'speculation. Do not give buy, sell, or hold advice. This is not '
      'financial advice.\n'
      'Name: ${instrument.name}\n'
      '$tickerLine\n'
      '$isinLine';
}

Uri? researchQueryUri(ResearchTool tool, String prompt) {
  final template = tool.queryUrlTemplate;
  if (template == null) return null;
  return Uri.parse(
    template.replaceAll('{prompt}', Uri.encodeQueryComponent(prompt)),
  );
}
