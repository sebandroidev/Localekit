import 'package:drift/drift.dart';

/// Supported project framework types.
enum ProjectFramework { flutter, reactNative, unknown }

/// Stores one row per opened project folder.
class Projects extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Human-readable project name (usually the folder name).
  TextColumn get name => text()();

  /// Absolute path to the project root. Must be unique.
  TextColumn get path => text().unique()();

  /// Detected framework: flutter | reactNative | unknown.
  TextColumn get framework =>
      text().withDefault(const Constant('unknown'))();

  /// Unix timestamp (ms) of the last successful scan, or null if never scanned.
  IntColumn get lastScanned => integer().nullable()();

  /// JSON blob for per-project settings (min length, ignore globs, etc.).
  TextColumn get settingsJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
