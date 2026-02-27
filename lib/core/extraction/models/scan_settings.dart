import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_settings.freezed.dart';
part 'scan_settings.g.dart';

/// Naming convention used when generating i18n keys from string values.
enum KeyConvention {
  /// `signInButton` — default; matches Flutter/intl convention.
  camelCase,

  /// `sign_in_button` — common in Python/Rails ecosystems.
  snakeCase,

  /// `auth.signIn.button` — used in i18next / Vue i18n.
  dotNotation,
}

/// Per-project extraction configuration stored in `projects.settings_json`.
@freezed
class ScanSettings with _$ScanSettings {
  const factory ScanSettings({
    /// Strings shorter than this are excluded (default 3 characters).
    @Default(3) int minStringLength,

    /// Glob patterns for files to exclude (e.g. `['**/*.g.dart', 'test/**']`).
    @Default([]) List<String> ignoreGlobs,

    /// Additional regex patterns — matched strings are excluded.
    @Default([]) List<String> customExcludePatterns,

    /// Key naming convention applied by the auto-key generator.
    @Default(KeyConvention.camelCase) KeyConvention keyConvention,
  }) = _ScanSettings;

  factory ScanSettings.fromJson(Map<String, dynamic> json) =>
      _$ScanSettingsFromJson(json);
}

/// Progress event emitted by the isolate scanner as it runs.
@freezed
class ScanProgress with _$ScanProgress {
  const factory ScanProgress({
    /// Completion fraction in range 0.0 – 1.0.
    required double fraction,

    /// Currently-scanned file path (relative to project root).
    @Default('') String currentFile,

    /// Running total of strings found so far.
    @Default(0) int stringsFound,

    /// True when the scan has finished.
    @Default(false) bool done,

    /// Non-null if the scan ended with an error.
    String? error,

    /// Final extracted strings (JSON maps). Only set when [done] is true.
    @Default([]) List<Map<String, dynamic>> results,
  }) = _ScanProgress;

  factory ScanProgress.fromJson(Map<String, dynamic> json) =>
      _$ScanProgressFromJson(json);
}
