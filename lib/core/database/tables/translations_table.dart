import 'package:drift/drift.dart';
import 'package:localekit/core/database/tables/strings_table.dart';

/// Status of a single translation entry.
enum TranslationStatus { pending, auto, manual, approved }

/// One row per (string, locale) pair — holds the translated value.
class Translations extends Table {
  /// Primary key.
  TextColumn get id => text()();

  /// FK to [LocaleStrings.id].
  TextColumn get stringId =>
      text().references(LocaleStrings, #id, onDelete: KeyAction.cascade)();

  /// BCP-47 locale code (e.g. `fr`, `de`, `zh_TW`).
  TextColumn get locale => text()();

  /// The translated text, or null if not yet translated.
  TextColumn get value => text().nullable()();

  /// One of: pending | auto | manual | approved.
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();

  /// Which AI provider produced this translation, or null if manual.
  TextColumn get provider => text().nullable()();

  /// Unix timestamp (ms) of the last update.
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {stringId, locale},
      ];
}
