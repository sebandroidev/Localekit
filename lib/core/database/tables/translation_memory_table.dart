import 'package:drift/drift.dart';

/// Caches AI-generated translations keyed by a SHA-256 hash.
///
/// Prevents redundant API calls for identical source strings and
/// locale pairs. Hash is computed as SHA-256(sourceText|sourceLang|targetLang).
class TranslationMemory extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// SHA-256 hash of `"${sourceText}|${sourceLang}|${targetLang}"`.
  /// Unique index enables O(1) cache lookup.
  TextColumn get sourceHash => text().unique()();

  /// BCP-47 source language code (e.g. `en`).
  TextColumn get sourceLang => text()();

  /// BCP-47 target language code (e.g. `fr`).
  TextColumn get targetLang => text()();

  /// The original source string.
  TextColumn get sourceText => text()();

  /// The cached translation result.
  TextColumn get translated => text()();

  /// Unix timestamp (ms) when this entry was cached.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
