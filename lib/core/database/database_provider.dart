import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/daos/projects_dao.dart';
import 'package:localekit/core/database/daos/strings_dao.dart';
import 'package:localekit/core/database/daos/translation_memory_dao.dart';
import 'package:localekit/core/database/daos/translations_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

/// Provides the singleton [AppDatabase] instance.
///
/// Closes the database when the provider is disposed.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

/// Provides the [ProjectsDao] for the current [AppDatabase].
@Riverpod(keepAlive: true)
ProjectsDao projectsDao(Ref ref) =>
    ref.watch(appDatabaseProvider).projectsDao;

/// Provides the [StringsDao] for the current [AppDatabase].
@Riverpod(keepAlive: true)
StringsDao stringsDao(Ref ref) => ref.watch(appDatabaseProvider).stringsDao;

/// Provides the [TranslationsDao] for the current [AppDatabase].
@Riverpod(keepAlive: true)
TranslationsDao translationsDao(Ref ref) =>
    ref.watch(appDatabaseProvider).translationsDao;

/// Provides the [TranslationMemoryDao] for the current [AppDatabase].
@Riverpod(keepAlive: true)
TranslationMemoryDao translationMemoryDao(Ref ref) =>
    ref.watch(appDatabaseProvider).translationMemoryDao;
