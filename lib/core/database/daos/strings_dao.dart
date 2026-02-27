import 'package:drift/drift.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/tables/strings_table.dart';

part 'strings_dao.g.dart';

/// Data access object for the [LocaleStrings] table.
@DriftAccessor(tables: [LocaleStrings])
class StringsDao extends DatabaseAccessor<AppDatabase>
    with _$StringsDaoMixin {
  /// Creates a [StringsDao] bound to [db].
  StringsDao(super.db);

  /// Returns all strings belonging to [projectId].
  Future<List<LocaleString>> getStringsForProject(String projectId) =>
      (select(localeStrings)
            ..where((t) => t.projectId.equals(projectId)))
          .get();

  /// Watches all strings belonging to [projectId].
  Stream<List<LocaleString>> watchStringsForProject(String projectId) =>
      (select(localeStrings)
            ..where((t) => t.projectId.equals(projectId)))
          .watch();

  /// Returns the string with [id], or null if not found.
  Future<LocaleString?> getStringById(String id) =>
      (select(localeStrings)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Inserts or replaces a string row.
  Future<int> upsertString(LocaleStringsCompanion entry) =>
      into(localeStrings).insertOnConflictUpdate(entry);

  /// Inserts or replaces multiple string rows in a single batch.
  Future<void> upsertStrings(List<LocaleStringsCompanion> entries) =>
      batch((b) => b.insertAllOnConflictUpdate(localeStrings, entries));

  /// Deletes the string with [id].
  Future<int> deleteString(String id) =>
      (delete(localeStrings)..where((t) => t.id.equals(id))).go();

  /// Deletes all strings belonging to [projectId].
  Future<int> deleteStringsForProject(String projectId) =>
      (delete(localeStrings)
            ..where((t) => t.projectId.equals(projectId)))
          .go();

  /// Updates the [status] column of the string with [id].
  Future<bool> updateStatus(String id, String status) async {
    final count =
        await (update(localeStrings)..where((t) => t.id.equals(id)))
            .write(LocaleStringsCompanion(status: Value(status)));
    return count > 0;
  }
}
