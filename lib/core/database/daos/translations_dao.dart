import 'package:drift/drift.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/tables/translations_table.dart';

part 'translations_dao.g.dart';

/// Data access object for the [Translations] table.
@DriftAccessor(tables: [Translations])
class TranslationsDao extends DatabaseAccessor<AppDatabase>
    with _$TranslationsDaoMixin {
  /// Creates a [TranslationsDao] bound to [db].
  TranslationsDao(super.db);

  /// Returns all translations for [stringId].
  Future<List<Translation>> getTranslationsForString(String stringId) =>
      (select(translations)..where((t) => t.stringId.equals(stringId))).get();

  /// Watches all translations for [stringId].
  Stream<List<Translation>> watchTranslationsForString(String stringId) =>
      (select(translations)..where((t) => t.stringId.equals(stringId)))
          .watch();

  /// Returns the translation for ([stringId], [locale]), or null.
  Future<Translation?> getTranslation(String stringId, String locale) =>
      (select(translations)
            ..where(
              (t) =>
                  t.stringId.equals(stringId) & t.locale.equals(locale),
            ))
          .getSingleOrNull();

  /// Inserts or replaces a translation row.
  Future<int> upsertTranslation(TranslationsCompanion entry) =>
      into(translations).insertOnConflictUpdate(entry);

  /// Inserts or replaces multiple translation rows in a single batch.
  Future<void> upsertTranslations(List<TranslationsCompanion> entries) =>
      batch((b) => b.insertAllOnConflictUpdate(translations, entries));

  /// Deletes all translations belonging to [stringId].
  Future<int> deleteTranslationsForString(String stringId) =>
      (delete(translations)..where((t) => t.stringId.equals(stringId))).go();

  /// Updates the [status] column of the translation with [id].
  Future<bool> updateStatus(String id, String status) async {
    final count =
        await (update(translations)..where((t) => t.id.equals(id)))
            .write(TranslationsCompanion(status: Value(status)));
    return count > 0;
  }
}
