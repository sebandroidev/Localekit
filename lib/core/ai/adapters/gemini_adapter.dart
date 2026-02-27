import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:localekit/core/ai/ai_provider.dart';

/// Gemini REST adapter for AI-assisted translation (AI-02).
///
/// Uses the `generateContent` endpoint with the `gemini-2.0-flash` model.
/// The API key is expected to be provided at construction time (BYOK pattern).
class GeminiAdapter implements AiTranslationProvider {
  GeminiAdapter({required this.apiKey});

  final String apiKey;

  static const _model = 'gemini-2.0-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models'
      '/$_model:generateContent';

  @override
  bool get isConfigured => apiKey.isNotEmpty;

  @override
  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (!isConfigured) {
      throw StateError('Gemini API key is not configured.');
    }

    final prompt =
        'Translate the following UI string from $sourceLang to $targetLang. '
        'Return ONLY the translated text, with no explanation, quotes, or '
        'additional commentary. Preserve any placeholders in curly braces '
        '(e.g. {name}, {count}) exactly as they appear.\n\n'
        'Source text: $text';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 512,
      },
    });

    final response = await http.post(
      Uri.parse('$_endpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw FormatException('Gemini returned no candidates', response.body);
    }
    final first = candidates.first as Map<String, dynamic>;
    final content = first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw FormatException('Gemini returned no parts', response.body);
    }
    final part = parts.first as Map<String, dynamic>;
    final translated = part['text'] as String?;
    if (translated == null) {
      throw FormatException('Gemini returned null text', response.body);
    }
    return translated.trim();
  }
}

/// Stub for OpenAI — not yet implemented (M2).
class OpenAiAdapter implements AiTranslationProvider {
  const OpenAiAdapter();

  @override
  bool get isConfigured => false;

  @override
  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) =>
      throw UnimplementedError('OpenAI adapter is not yet implemented.');
}

/// Stub for Anthropic — not yet implemented (M2).
class AnthropicAdapter implements AiTranslationProvider {
  const AnthropicAdapter();

  @override
  bool get isConfigured => false;

  @override
  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) =>
      throw UnimplementedError('Anthropic adapter is not yet implemented.');
}
