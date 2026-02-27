import 'package:localekit/core/export/export_writer.dart';

/// Writes a flat YAML file (EXP-05).
///
/// Values containing special YAML characters are wrapped in double quotes.
class YamlWriter implements ExportWriter {
  const YamlWriter();

  @override
  String get extension => 'yaml';

  @override
  String write(String locale, List<ExportEntry> entries) {
    final buffer = StringBuffer()..writeln('# locale: $locale');

    for (final entry in entries) {
      buffer
        ..write('${entry.key}: ')
        ..writeln(_quoteIfNeeded(entry.value));
    }

    return buffer.toString();
  }

  /// Wraps the value in double quotes if it contains YAML special characters.
  String _quoteIfNeeded(String value) {
    // Characters that require quoting in YAML.
    const special = [
      ':',
      '#',
      '{',
      '}',
      '[',
      ']',
      ',',
      '&',
      '*',
      '?',
      '|',
      '-',
      '<',
      '>',
      '=',
      '!',
      '%',
      '@',
      '`',
    ];
    final needsQuoting = value.isEmpty ||
        special.any((c) => value.contains(c)) ||
        value.startsWith("'") ||
        value.startsWith('"');

    if (!needsQuoting) return value;

    // Escape existing double quotes.
    final escaped = value.replaceAll('"', r'\"');
    return '"$escaped"';
  }
}
