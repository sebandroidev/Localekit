import 'dart:convert';

import 'package:localekit/core/export/export_writer.dart';

/// Writes Flutter ARB (Application Resource Bundle) files (EXP-02).
///
/// Format: https://github.com/google/app-resource-bundle
///
/// Each entry produces:
///   "key": "value",
///   "@key": { "description": "...", "placeholders": { ... } }
class ArbWriter implements ExportWriter {
  const ArbWriter();

  @override
  String get extension => 'arb';

  @override
  String write(String locale, List<ExportEntry> entries) {
    final map = <String, dynamic>{
      '@@locale': locale,
    };

    for (final entry in entries) {
      map[entry.key] = entry.value;
      final meta = <String, dynamic>{};
      if (entry.description != null && entry.description!.isNotEmpty) {
        meta['description'] = entry.description;
      }
      if (entry.placeholders.isNotEmpty) {
        final ph = <String, dynamic>{};
        for (final name in entry.placeholders) {
          ph[name] = <String, dynamic>{'type': 'String'};
        }
        meta['placeholders'] = ph;
      }
      if (meta.isNotEmpty) {
        map['@${entry.key}'] = meta;
      }
    }

    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
