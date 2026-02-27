import 'dart:convert';

import 'package:localekit/core/export/export_writer.dart';

/// Writes a nested JSON file where dot-separated keys become nested objects
/// (EXP-04).
///
/// Example: key `button.save` → `{ "button": { "save": "Save" } }`
class NestedJsonWriter implements ExportWriter {
  const NestedJsonWriter();

  @override
  String get extension => 'json';

  @override
  String write(String locale, List<ExportEntry> entries) {
    final root = <String, dynamic>{};

    for (final entry in entries) {
      final parts = entry.key.split('.');
      var node = root;
      for (var i = 0; i < parts.length - 1; i++) {
        node = (node[parts[i]] ??= <String, dynamic>{}) as Map<String, dynamic>;
      }
      node[parts.last] = entry.value;
    }

    return const JsonEncoder.withIndent('  ').convert(root);
  }
}
