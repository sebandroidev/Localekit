import 'package:localekit/core/extraction/models/scan_settings.dart';

/// Decides whether an extracted string should be excluded from the results.
///
/// All predicates are pure functions — this class holds no state.
abstract final class ExtractionFilter {
  static final _numericRe = RegExp(r'^\d+\.?\d*$');
  static final _hexColorRe = RegExp(r'^#?[0-9a-fA-F]{3,8}$');
  static final _assetExtRe =
      RegExp(r'\.(png|svg|jpg|jpeg|gif|webp|ttf|otf|woff|ico)$');
  static final _singleLowercaseWordRe = RegExp(r'^[a-z][a-z0-9]*$');
  static final _formatOnlyRe = RegExp(r'^[\s%\$\{\}\.]+$');

  /// Returns `true` if [value] should be excluded based on [settings].
  static bool shouldExclude(String value, ScanSettings settings) {
    if (value.trim().isEmpty) return true;
    if (value.length < settings.minStringLength) return true;
    if (_numericRe.hasMatch(value)) return true;
    if (_hexColorRe.hasMatch(value)) return true;
    if (_assetExtRe.hasMatch(value)) return true;
    if (_formatOnlyRe.hasMatch(value)) return true;
    if (_singleLowercaseWordRe.hasMatch(value)) return true;
    if (_isUrlOrPath(value)) return true;
    for (final pattern in settings.customExcludePatterns) {
      try {
        if (RegExp(pattern).hasMatch(value)) return true;
      } on FormatException catch (_) {
        // Skip malformed patterns silently.
      }
    }
    return false;
  }

  static bool _isUrlOrPath(String value) {
    return value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('assets/') ||
        value.startsWith('./') ||
        (value.startsWith('/') && !value.contains(' '));
  }
}
