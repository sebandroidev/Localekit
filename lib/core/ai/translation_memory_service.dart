import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/ai/adapters/gemini_adapter.dart';
import 'package:localekit/core/ai/ai_provider.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/daos/translation_memory_dao.dart';
import 'package:localekit/core/database/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'translation_memory_service.g.dart';

/// Orchestrates AI translation with a translation memory cache (AI-09).
///
/// Before calling the AI provider, checks whether an identical
/// (source + srcLang + tgtLang) combination exists in the cache. On a miss,
/// calls the provider and stores the result for future lookups.
class TranslationMemoryService {
  TranslationMemoryService({
    required this.tmDao,
    required this.provider,
  });

  final TranslationMemoryDao tmDao;
  final AiTranslationProvider provider;

  /// Returns a cached or freshly-translated string.
  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final hash = _hash(text, sourceLang, targetLang);

    // Cache hit?
    final cached = await tmDao.getByHash(hash);
    if (cached != null) {
      return cached.translated;
    }

    // Cache miss — call provider.
    final translated = await provider.translate(
      text: text,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    // Store result.
    final now = DateTime.now().millisecondsSinceEpoch;
    await tmDao.upsertEntry(
      TranslationMemoryCompanion.insert(
        id: '${hash}_$now',
        sourceHash: hash,
        sourceLang: sourceLang,
        targetLang: targetLang,
        sourceText: text,
        translated: translated,
        createdAt: now,
      ),
    );

    return translated;
  }

  /// SHA-256 of `source|srcLang|tgtLang` (same key as DB unique index).
  static String _hash(String text, String srcLang, String tgtLang) {
    final bytes = utf8.encode('$text|$srcLang|$tgtLang');
    return sha256.convert(bytes).toString();
  }
}

/// Provides the [TranslationMemoryService] for the current API key.
///
/// The API key is read from [geminiApiKeyProvider]. When the key is empty,
/// the service's [GeminiAdapter] will throw on use, which surfaces
/// gracefully in the UI.
@Riverpod(keepAlive: true)
TranslationMemoryService translationMemoryService(Ref ref) {
  final key = ref.watch(geminiApiKeyProvider);
  return TranslationMemoryService(
    tmDao: ref.watch(translationMemoryDaoProvider),
    provider: GeminiAdapter(apiKey: key),
  );
}

/// Holds the Gemini API key entered by the user.
///
/// In M1 the key lives only in memory. Persistence via
/// `flutter_secure_storage` is planned for M2.
@Riverpod(keepAlive: true)
class GeminiApiKey extends _$GeminiApiKey {
  @override
  String build() => '';

  // ignore: use_setters_to_change_properties — Riverpod notifier convention
  void setKey(String key) => state = key;
}
