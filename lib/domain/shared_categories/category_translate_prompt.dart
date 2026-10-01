import '../models/research_tool.dart';
import '../investment_research_prompt.dart' show researchQueryUri;

export '../investment_research_prompt.dart' show researchQueryUri;

/// Payload handed to the Research Tool / clipboard for "Translate with AI".
/// Spec: only the category word (or short phrase) — never amounts, accounts,
/// or other category rows.
String buildCategoryTranslatePrompt(String categoryName) => categoryName.trim();

/// Opens (or prepares) the favourite Research Tool with only [categoryName].
Uri? categoryTranslateQueryUri(ResearchTool tool, String categoryName) {
  final prompt = buildCategoryTranslatePrompt(categoryName);
  if (prompt.isEmpty) return null;
  return researchQueryUri(tool, prompt);
}
