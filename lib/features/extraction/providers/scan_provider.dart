import 'package:drift/drift.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/database_provider.dart';
import 'package:localekit/core/extraction/isolate_scanner.dart';
import 'package:localekit/core/extraction/models/extracted_string.dart';
import 'package:localekit/core/extraction/models/scan_settings.dart';
import 'package:localekit/features/projects/providers/project_state_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scan_provider.freezed.dart';
part 'scan_provider.g.dart';

/// The lifecycle states of a project scan.
@freezed
sealed class ScanState with _$ScanState {
  const factory ScanState.idle() = ScanIdle;

  const factory ScanState.running({
    required ScanProgress progress,
  }) = ScanRunning;

  const factory ScanState.done({
    required int newStrings,
    required int modifiedStrings,
    required int unchangedStrings,
  }) = ScanDone;

  const factory ScanState.error(String message) = ScanError;
}

/// Controls and exposes the state of the active project scan.
@riverpod
class ScanNotifier extends _$ScanNotifier {
  IsolateScanner? _scanner;

  @override
  ScanState build() => const ScanState.idle();

  /// Starts scanning the currently open project.
  ///
  /// No-op if no project is open or a scan is already in progress.
  Future<void> startScan() async {
    final projectState =
        ref.read(projectStateNotifierProvider).valueOrNull;
    if (projectState == null) return;
    if (state is ScanRunning) return;

    state = const ScanState.running(
      progress: ScanProgress(fraction: 0),
    );

    _scanner = IsolateScanner(
      projectRoot: projectState.project.path,
      settings: projectState.scanSettings,
    );

    final stringsDao = ref.read(stringsDaoProvider);
    final projectId = projectState.project.id;
    var newCount = 0;
    var modifiedCount = 0;
    var unchangedCount = 0;

    try {
      await for (final event in _scanner!.stream) {
        if (state is! ScanRunning) break;

        if (event.done) {
          final extracted =
              event.results.map(ExtractedString.fromJson).toList();

          for (final s in extracted) {
            final existing = await stringsDao.getByProjectAndPath(
              projectId,
              s.filePath,
              s.lineNumber,
            );

            if (existing == null) {
              newCount++;
              await stringsDao.upsertString(
                LocaleStringsCompanion(
                  id: Value(s.id),
                  projectId: Value(projectId),
                  key: Value(s.suggestedKey),
                  sourceValue: Value(s.value),
                  filePath: Value(s.filePath),
                  lineNumber: Value(s.lineNumber),
                  contextSnippet: Value(s.contextSnippet),
                  status: const Value('untranslated'),
                ),
              );
            } else if (existing.sourceValue != s.value) {
              modifiedCount++;
              await stringsDao.upsertString(
                LocaleStringsCompanion(
                  id: Value(existing.id),
                  projectId: Value(projectId),
                  key: Value(existing.key ?? s.suggestedKey),
                  sourceValue: Value(s.value),
                  filePath: Value(s.filePath),
                  lineNumber: Value(s.lineNumber),
                  contextSnippet: Value(s.contextSnippet),
                  status: const Value('modified'),
                ),
              );
            } else {
              unchangedCount++;
            }
          }
        } else {
          state = ScanState.running(progress: event);
        }
      }

      state = ScanState.done(
        newStrings: newCount,
        modifiedStrings: modifiedCount,
        unchangedStrings: unchangedCount,
      );

      await ref
          .read(projectsDaoProvider)
          .updateLastScanned(
            projectId,
            DateTime.now().millisecondsSinceEpoch,
          );
    } on Exception catch (e) {
      state = ScanState.error(e.toString());
    } finally {
      _scanner = null;
    }
  }

  /// Cancels an in-progress scan immediately.
  void cancelScan() {
    _scanner?.cancel();
    _scanner = null;
    state = const ScanState.idle();
  }
}
