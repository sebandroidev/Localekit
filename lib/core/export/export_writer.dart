/// A single translated entry ready for export.
class ExportEntry {
  const ExportEntry({
    required this.key,
    required this.value,
    this.description,
    this.placeholders = const [],
  });

  final String key;
  final String value;

  /// Optional description from the ARB @key block.
  final String? description;

  /// Placeholder names extracted from `{name}` patterns.
  final List<String> placeholders;
}

/// Abstract export writer interface.
///
/// Each implementation handles one output format.
abstract interface class ExportWriter {
  /// Returns the file content as a string for the given [locale] and
  /// list of [entries].
  String write(String locale, List<ExportEntry> entries);

  /// Default file extension for this format (without leading dot).
  String get extension;
}
