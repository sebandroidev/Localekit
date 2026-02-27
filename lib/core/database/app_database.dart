import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:localekit/core/database/daos/projects_dao.dart';
import 'package:localekit/core/database/daos/strings_dao.dart';
import 'package:localekit/core/database/daos/translations_dao.dart';
import 'package:localekit/core/database/tables/projects_table.dart';
import 'package:localekit/core/database/tables/strings_table.dart';
import 'package:localekit/core/database/tables/translations_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// The main Drift database for LocaleKit.
///
/// Contains three tables in schema version 1:
/// - [Projects] — one row per project folder
/// - [LocaleStrings] — extracted source strings
/// - [Translations] — translated values per locale
///
/// `translation_memory` is deferred to the AI milestone.
@DriftDatabase(
  tables: [Projects, LocaleStrings, Translations],
  daos: [ProjectsDao, StringsDao, TranslationsDao],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase], optionally with a custom [executor] for testing.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations will be added here.
        },
      );

  static QueryExecutor _openConnection() => driftDatabase(
        name: 'localekit',
        native: DriftNativeOptions(
          databasePath: () async {
            final dir = await getApplicationSupportDirectory();
            return p.join(dir.path, 'localekit.db');
          },
        ),
      );
}
