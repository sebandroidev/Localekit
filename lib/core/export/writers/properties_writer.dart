import 'package:localekit/core/export/export_writer.dart';

/// Writes a Java `.properties` file (EXP-06).
///
/// Keys and values are separated by `=`. Non-ASCII characters are kept as-is
/// (UTF-8 properties files are now standard in modern Java tooling).
class PropertiesWriter implements ExportWriter {
  const PropertiesWriter();

  @override
  String get extension => 'properties';

  @override
  String write(String locale, List<ExportEntry> entries) {
    final buffer = StringBuffer()
      ..writeln('# locale: $locale')
      ..writeln();

    for (final entry in entries) {
      if (entry.description != null && entry.description!.isNotEmpty) {
        buffer.writeln('# ${entry.description}');
      }
      buffer.writeln('${entry.key}=${_escape(entry.value)}');
    }

    return buffer.toString();
  }

  /// Escapes characters that have special meaning in .properties files.
  String _escape(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r')
      .replaceAll('\t', r'\t')
      // Escape leading whitespace (properties parser strips it).
      .replaceAll(RegExp(r'^(\s)'), r'\$1');
}
