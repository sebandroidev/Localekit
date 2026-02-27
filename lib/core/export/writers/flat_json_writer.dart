import 'dart:convert';

import 'package:localekit/core/export/export_writer.dart';

/// Writes a flat JSON file where each key maps directly to its value (EXP-03).
///
/// Example:
/// ```json
/// {
///   "helloWorld": "Hello, World!",
///   "buttonSave": "Save"
/// }
/// ```
class FlatJsonWriter implements ExportWriter {
  const FlatJsonWriter();

  @override
  String get extension => 'json';

  @override
  String write(String locale, List<ExportEntry> entries) {
    final map = <String, String>{
      for (final e in entries) e.key: e.value,
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
