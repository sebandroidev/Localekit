import 'package:drift/drift.dart';
import 'package:localekit/core/database/tables/projects_table.dart';

/// Status of an extracted string.
enum StringStatus { untranslated, translated, approved, ignored }

/// One row per extracted string found in a project's source files.
///
/// Named `LocaleStrings` (not `Strings`) to avoid conflicting with Dart's
/// built-in `String` type, which Drift would generate for a table
/// named `Strings`.
class LocaleStrings extends Table {
  TextColumn get id => text()();
  TextColumn get projectId =>
      text().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text().nullable()();
  TextColumn get sourceValue => text()();
  TextColumn get filePath => text()();
  IntColumn get lineNumber => integer().nullable()();
  TextColumn get contextSnippet => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('untranslated'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
