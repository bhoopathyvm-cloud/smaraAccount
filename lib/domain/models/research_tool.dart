/// Predefined consumer research tools. No API key, no custom URL.
enum ResearchTool { chatGpt, claude, gemini, metaAi }

extension ResearchToolDisplay on ResearchTool {
  String get displayName => switch (this) {
    ResearchTool.chatGpt => 'ChatGPT',
    ResearchTool.claude => 'Claude',
    ResearchTool.gemini => 'Gemini',
    ResearchTool.metaAi => 'Meta AI',
  };

  /// Query URL template, or null when the tool has no public `?q=` endpoint
  /// (copy-only). `{prompt}` is replaced with a URI-encoded research prompt.
  String? get queryUrlTemplate => switch (this) {
    ResearchTool.chatGpt => 'https://chatgpt.com/?q={prompt}',
    ResearchTool.claude => 'https://claude.ai/new?q={prompt}',
    ResearchTool.gemini => 'https://gemini.google.com/app?q={prompt}',
    ResearchTool.metaAi => 'https://www.meta.ai/?q={prompt}',
  };
}
