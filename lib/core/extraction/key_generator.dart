import 'package:localekit/core/extraction/models/scan_settings.dart';

/// Generates i18n keys from extracted string values.
abstract final class KeyGenerator {
  static final _nonWordRe = RegExp(r'[^a-zA-Z0-9\s]');
  static final _whitespaceRe = RegExp(r'\s+');

  /// Generates a key for [value] using [convention], ensuring uniqueness
  /// against [existingKeys].
  static String generate(
    String value,
    KeyConvention convention,
    Set<String> existingKeys,
  ) {
    final words = _tokenize(value);
    if (words.isEmpty) return _unique('string', existingKeys);
    final base = switch (convention) {
      KeyConvention.camelCase => _toCamelCase(words),
      KeyConvention.snakeCase => _toSnakeCase(words),
      KeyConvention.dotNotation => _toDotNotation(words),
    };
    return _unique(base, existingKeys);
  }

  // ---------------------------------------------------------------------------

  static List<String> _tokenize(String value) {
    final cleaned = value
        .trim()
        .replaceAll(_nonWordRe, ' ')
        .toLowerCase()
        .replaceAll(_whitespaceRe, ' ')
        .trim();
    final words = cleaned.split(' ').where((w) => w.isNotEmpty).toList();
    // Limit to first 6 words to keep keys readable.
    return words.take(6).toList();
  }

  static String _toCamelCase(List<String> words) {
    if (words.isEmpty) return 'string';
    final buffer = StringBuffer(words.first);
    for (final word in words.skip(1)) {
      if (word.isEmpty) continue;
      buffer
        ..write(word[0].toUpperCase())
        ..write(word.substring(1));
    }
    return _truncate(buffer.toString(), 40);
  }

  static String _toSnakeCase(List<String> words) =>
      _truncate(words.join('_'), 40);

  static String _toDotNotation(List<String> words) {
    // First word is namespace, rest is the key.
    if (words.length == 1) return words.first;
    return '${words.first}.${_toCamelCase(words.skip(1).toList())}';
  }

  static String _truncate(String s, int maxLength) {
    if (s.length <= maxLength) return s;
    // Truncate at a word boundary (underscore / dot / camelCase boundary).
    return s.substring(0, maxLength).replaceAll(RegExp(r'[_.\s][^_.]*$'), '');
  }

  static String _unique(String base, Set<String> existingKeys) {
    if (!existingKeys.contains(base)) return base;
    for (var i = 2; i <= 999; i++) {
      final candidate = '$base$i';
      if (!existingKeys.contains(candidate)) return candidate;
    }
    return '${base}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
