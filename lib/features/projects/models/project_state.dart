import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/extraction/models/scan_settings.dart';

part 'project_state.freezed.dart';

/// Detected framework for an opened project folder.
enum DetectedFramework {
  /// `pubspec.yaml` found — Flutter project.
  flutter,

  /// `package.json` found (no `pubspec.yaml`) — React Native or plain JS.
  reactNative,

  /// Detection inconclusive; user must select manually.
  unknown,
}

/// Runtime state for the currently-open project.
@freezed
class ProjectState with _$ProjectState {
  const factory ProjectState({
    /// The Drift project row.
    required Project project,

    /// Framework detected (or manually selected) for this project.
    required DetectedFramework framework,

    /// Locales configured for translation (BCP-47 codes, e.g. `['fr', 'de']`).
    @Default([]) List<String> locales,

    /// ARB output directory derived from `l10n.yaml` (default `lib/l10n`).
    @Default('lib/l10n') String arbDirectory,

    /// Template ARB file name from `l10n.yaml` (e.g. `app_en.arb`).
    String? templateArbFile,

    /// Resolved scan settings (from `projects.settingsJson` or defaults).
    @Default(ScanSettings())
    ScanSettings scanSettings,
  }) = _ProjectState;
}
