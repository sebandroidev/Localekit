import 'package:drift/drift.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/tables/projects_table.dart';

part 'projects_dao.g.dart';

/// Data access object for the [Projects] table.
@DriftAccessor(tables: [Projects])
class ProjectsDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectsDaoMixin {
  /// Creates a [ProjectsDao] bound to [db].
  ProjectsDao(super.db);

  /// Returns all projects.
  Future<List<Project>> getAllProjects() => select(projects).get();

  /// Watches all projects reactively.
  Stream<List<Project>> watchAllProjects() => select(projects).watch();

  /// Returns the project with [id], or null if not found.
  Future<Project?> getProjectById(String id) =>
      (select(projects)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Returns the project with [path], or null if not found.
  Future<Project?> getProjectByPath(String path) =>
      (select(projects)..where((t) => t.path.equals(path))).getSingleOrNull();

  /// Inserts or replaces a project row.
  Future<int> upsertProject(ProjectsCompanion entry) =>
      into(projects).insertOnConflictUpdate(entry);

  /// Deletes the project with [id].
  Future<int> deleteProject(String id) =>
      (delete(projects)..where((t) => t.id.equals(id))).go();

  /// Updates `lastScanned` for the project with [id].
  Future<bool> updateLastScanned(String id, int timestampMs) async {
    final count = await (update(projects)..where((t) => t.id.equals(id)))
        .write(ProjectsCompanion(lastScanned: Value(timestampMs)));
    return count > 0;
  }
}
