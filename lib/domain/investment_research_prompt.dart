import '../l10n/generated/app_localizations.dart';
import 'models/instrument.dart';
import 'models/research_tool.dart';

/// Builds the packed research prompt from identifiers only — never
/// quantity, cost, or account name (investment-research-enablement). The
/// template and asks follow [l10n]'s active locale; the instrument's
/// stored name/ticker/ISIN are used as-is
/// (i18n-full-ui-and-input-language design.md Decision 7).
String buildInvestmentResearchPrompt(
  AppLocalizations l10n,
  Instrument instrument,
) {
  final ticker = instrument.ticker?.trim();
  final isin = instrument.isin?.trim();
  final tickerLine = (ticker == null || ticker.isEmpty)
      ? l10n.researchPromptTickerNoneProvided
      : l10n.researchPromptTickerLine(ticker);
  final isinLine = (isin == null || isin.isEmpty)
      ? l10n.researchPromptIsinNoneProvided
      : l10n.researchPromptIsinLine(isin);
  return '${l10n.researchPromptIntro}\n'
      '${l10n.researchPromptNameLine(instrument.name)}\n'
      '$tickerLine\n'
      '$isinLine';
}

/// Builds the *identify* prompt from the typed name only — asks the
/// favourite AI tool for the ISIN, primary exchange + ticker, trading
/// currency, market-data symbol, and cross-listings, and forbids advice
/// (instrument-identifier-assist Decision 1). Never includes quantity,
/// cost, or account information. Uses [l10n]'s active locale.
String buildInstrumentIdentifyPrompt(AppLocalizations l10n, String name) {
  return '${l10n.identifyPromptIntro}\n'
      '${l10n.researchPromptNameLine(name)}';
}

Uri? researchQueryUri(ResearchTool tool, String prompt) {
  final template = tool.queryUrlTemplate;
  if (template == null) return null;
  return Uri.parse(
    template.replaceAll('{prompt}', Uri.encodeQueryComponent(prompt)),
  );
}
