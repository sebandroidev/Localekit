import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:localekit/core/database/daos/projects_dao.dart';
import 'package:localekit/core/database/daos/strings_dao.dart';
import 'package:localekit/core/database/daos/translation_memory_dao.dart';
import 'package:localekit/core/database/daos/translations_dao.dart';
import 'package:localekit/core/database/tables/projects_table.dart';
import 'package:localekit/core/database/tables/strings_table.dart';
import 'package:localekit/core/database/tables/translation_memory_table.dart';
import 'package:localekit/core/database/tables/translations_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// The main Drift database for LocaleKit.
///
/// Schema history:
/// - v1: Projects, LocaleStrings, Translations
/// - v2: + TranslationMemory (AI cache)
@DriftDatabase(
  tables: [Projects, LocaleStrings, Translations, TranslationMemory],
  daos: [ProjectsDao, StringsDao, TranslationsDao, TranslationMemoryDao],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase], optionally with a custom [executor] for testing.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(translationMemory);
          }
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
