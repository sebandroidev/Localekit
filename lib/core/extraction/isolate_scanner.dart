import 'dart:isolate';

import 'package:localekit/core/extraction/dart_string_extractor.dart';
import 'package:localekit/core/extraction/models/scan_settings.dart';

/// Message sent to the scanner isolate to begin a scan.
class _ScanRequest {
  const _ScanRequest({
    required this.sendPort,
    required this.projectRoot,
    required this.settings,
  });

  final SendPort sendPort;
  final String projectRoot;
  final ScanSettings settings;
}

/// Runs [DartStringExtractor] in a dedicated [Isolate] so the UI thread
/// stays responsive during long scans.
///
/// Usage:
/// ```dart
/// final scanner = IsolateScanner(projectRoot: path, settings: settings);
/// await for (final progress in scanner.stream) {
///   if (progress.done) handleResults(progress.results);
/// }
/// ```
class IsolateScanner {
  IsolateScanner({required this.projectRoot, required this.settings});

  final String projectRoot;
  final ScanSettings settings;

  Isolate? _isolate;
  ReceivePort? _receivePort;

  /// A stream of [ScanProgress] events ending with a final `done == true`
  /// event that carries all extracted strings in [ScanProgress.results].
  Stream<ScanProgress> get stream => _start();

  Stream<ScanProgress> _start() async* {
    _receivePort = ReceivePort();
    final request = _ScanRequest(
      sendPort: _receivePort!.sendPort,
      projectRoot: projectRoot,
      settings: settings,
    );

    _isolate = await Isolate.spawn(
      _scannerEntryPoint,
      request,
      errorsAreFatal: false,
    );

    await for (final message in _receivePort!) {
      if (message is ScanProgress) {
        yield message;
        if (message.done) break;
      }
    }

    _cleanup();
  }

  /// Cancels an in-progress scan immediately.
  void cancel() {
    _isolate?.kill(priority: Isolate.immediate);
    _cleanup();
  }

  void _cleanup() {
    _receivePort?.close();
    _receivePort = null;
    _isolate = null;
  }
}

// ---------------------------------------------------------------------------
// Isolate entry point — runs in the spawned isolate.
// ---------------------------------------------------------------------------

Future<void> _scannerEntryPoint(_ScanRequest request) async {
  final extractor = DartStringExtractor(
    projectRoot: request.projectRoot,
    settings: request.settings,
  );

  final results = await extractor.extract(
    onProgress: (fraction, currentFile) {
      request.sendPort.send(
        ScanProgress(fraction: fraction, currentFile: currentFile),
      );
    },
  );

  // Final event carries all extracted strings serialised as JSON maps.
  request.sendPort.send(
    ScanProgress(
      fraction: 1,
      done: true,
      stringsFound: results.length,
      results: results.map((s) => s.toJson()).toList(),
    ),
  );
}
