import 'package:drift/drift.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/tables/translation_memory_table.dart';

part 'translation_memory_dao.g.dart';

/// Data access object for the [TranslationMemory] table.
@DriftAccessor(tables: [TranslationMemory])
class TranslationMemoryDao extends DatabaseAccessor<AppDatabase>
    with _$TranslationMemoryDaoMixin {
  /// Creates a [TranslationMemoryDao] bound to [db].
  TranslationMemoryDao(super.db);

  /// Returns the cached translation for [sourceHash], or null on cache miss.
  Future<TranslationMemoryData?> getByHash(String sourceHash) =>
      (select(translationMemory)
            ..where((t) => t.sourceHash.equals(sourceHash)))
          .getSingleOrNull();

  /// Inserts or updates a cache entry.
  Future<int> upsertEntry(TranslationMemoryCompanion entry) =>
      into(translationMemory).insertOnConflictUpdate(entry);

  /// Deletes all entries older than [beforeMs] (Unix ms).
  Future<int> pruneOlderThan(int beforeMs) =>
      (delete(translationMemory)
            ..where((t) => t.createdAt.isSmallerThanValue(beforeMs)))
          .go();
}
