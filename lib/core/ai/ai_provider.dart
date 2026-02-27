/// Abstract interface that every AI translation adapter must implement.
///
/// Adding a new provider means implementing this interface and registering
/// an [AiProviderType] variant.
abstract interface class AiTranslationProvider {
  /// Translates [text] from [sourceLang] to [targetLang].
  ///
  /// Returns the translated string, or throws on error.
  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  });

  /// Returns true if this provider is properly configured (has a valid key).
  bool get isConfigured;
}

/// Supported AI provider types (BYOK).
enum AiProviderType {
  /// Google Gemini (AI-02 — active in M1).
  gemini,

  /// OpenAI GPT (stub — AI-03 planned for M2).
  openAi,

  /// Anthropic Claude (stub — AI-04 planned for M2).
  anthropic,
}
