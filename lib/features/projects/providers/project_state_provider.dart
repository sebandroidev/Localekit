import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/database_provider.dart';
import 'package:localekit/core/extraction/models/scan_settings.dart';
import 'package:localekit/features/projects/models/project_state.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yaml/yaml.dart';

part 'project_state_provider.g.dart';

/// Manages the currently open project state.
///
/// - `openProject`: detect framework, read l10n.yaml, upsert DB row.
/// - `closeProject`: clear in-memory state (row stays in DB for recent list).
/// - `updateLocales`: add or remove a target locale for the active project.
@Riverpod(keepAlive: true)
class ProjectStateNotifier extends _$ProjectStateNotifier {
  static final _rng = Random.secure();

  @override
  Future<ProjectState?> build() async => null;

  /// Opens the project at [folderPath], detects its framework and
  /// reads `l10n.yaml` to populate export defaults.
  Future<void> openProject(String folderPath) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dao = ref.read(projectsDaoProvider);

      final framework = _detectFramework(folderPath);
      final l10nConfig = _readL10nYaml(folderPath);

      final existing = await dao.getProjectByPath(folderPath);
      final projectId = existing?.id ?? _generateId();
      final name = p.basename(folderPath);

      final settingsJson = existing?.settingsJson;
      final scanSettings = settingsJson != null
          ? ScanSettings.fromJson(
              jsonDecode(settingsJson) as Map<String, dynamic>,
            )
          : const ScanSettings();

      await dao.upsertProject(
        ProjectsCompanion(
          id: Value(projectId),
          name: Value(name),
          path: Value(folderPath),
          framework: Value(framework.name),
        ),
      );

      final project = (await dao.getProjectById(projectId))!;

      return ProjectState(
        project: project,
        framework: framework,
        arbDirectory: l10nConfig['arb-dir'] as String? ?? 'lib/l10n',
        templateArbFile: l10nConfig['template-arb-file'] as String?,
        scanSettings: scanSettings,
      );
    });
  }

  /// Clears the active project from memory (does not delete from DB).
  void closeProject() => state = const AsyncValue.data(null);

  /// Replaces the locale list for the active project.
  Future<void> updateLocales(List<String> locales) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(locales: locales));
  }

  // ---------------------------------------------------------------------------

  String _generateId() {
    final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  DetectedFramework _detectFramework(String folderPath) {
    if (File(p.join(folderPath, 'pubspec.yaml')).existsSync()) {
      return DetectedFramework.flutter;
    }
    if (File(p.join(folderPath, 'package.json')).existsSync()) {
      return DetectedFramework.reactNative;
    }
    return DetectedFramework.unknown;
  }

  /// Reads `l10n.yaml` from [folderPath] and returns its top-level map.
  Map<Object?, Object?> _readL10nYaml(String folderPath) {
    final file = File(p.join(folderPath, 'l10n.yaml'));
    if (!file.existsSync()) return {};
    try {
      final doc = loadYaml(file.readAsStringSync());
      return doc is Map ? doc : {};
    } on Exception catch (_) {
      return {};
    }
  }
}
