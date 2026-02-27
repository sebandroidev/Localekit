import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:localekit/core/extraction/extraction_filter.dart';
import 'package:localekit/core/extraction/key_generator.dart';
import 'package:localekit/core/extraction/models/extracted_string.dart';
import 'package:localekit/core/extraction/models/scan_settings.dart';
import 'package:path/path.dart' as p;

/// Widget constructor names whose first positional argument is translatable.
const _positionalWidgets = {
  'Text',
  'Tooltip',
  'SnackBar',
  'AlertDialog',
  'SimpleDialog',
  'ElevatedButton',
  'TextButton',
  'OutlinedButton',
  'IconButton',
  'FloatingActionButton',
  'Tab',
  'Chip',
};

/// Named parameter names that hold translatable strings.
const _namedParams = {
  'hintText',
  'labelText',
  'helperText',
  'errorText',
  'counterText',
  'prefixText',
  'suffixText',
  'title',
  'label',
  'tooltip',
  'semanticsLabel',
  'message',
  'buttonText',
};

/// Entry point for extracting hardcoded strings from a Flutter/Dart project.
///
/// Uses the `analyzer` package to parse ASTs — no false positives from
/// commented-out code or non-UI string constants.
class DartStringExtractor {
  const DartStringExtractor({
    required this.projectRoot,
    required this.settings,
  });

  final String projectRoot;
  final ScanSettings settings;

  /// Extracts all translatable strings from [projectRoot].
  ///
  /// Reports progress through [onProgress] (fraction 0.0–1.0).
  Future<List<ExtractedString>> extract({
    void Function(double fraction, String currentFile)? onProgress,
  }) async {
    final dartFiles = _collectDartFiles();
    if (dartFiles.isEmpty) return [];

    final collection = AnalysisContextCollection(includedPaths: [projectRoot]);
    final results = <ExtractedString>[];
    final usedKeys = <String>{};

    for (var i = 0; i < dartFiles.length; i++) {
      final filePath = dartFiles[i];
      onProgress?.call(i / dartFiles.length, filePath);

      try {
        final context = collection.contextFor(filePath);
        final result = await context.currentSession
            .getResolvedUnit(filePath) as ResolvedUnitResult;

        final visitor = _StringVisitor(
          filePath: filePath,
          projectRoot: projectRoot,
          settings: settings,
          usedKeys: usedKeys,
          sourceCode: result.content,
        );
        result.unit.visitChildren(visitor);
        results.addAll(visitor.found);
        usedKeys.addAll(visitor.found.map((s) => s.suggestedKey ?? ''));
      } on Exception catch (_) {
        // Skip files that fail to resolve (generated, malformed, etc.)
      }
    }

    onProgress?.call(1, '');
    return results;
  }

  List<String> _collectDartFiles() {
    final all = <String>[];
    final libDir = Directory(p.join(projectRoot, 'lib'));
    if (!libDir.existsSync()) return all;

    for (final file
        in libDir.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final relative = p.relative(file.path, from: projectRoot);
      // Skip generated files.
      if (relative.endsWith('.g.dart') ||
          relative.endsWith('.freezed.dart') ||
          relative.endsWith('.mocks.dart')) {
        continue;
      }
      // Apply user-defined ignore globs.
      if (settings.ignoreGlobs.any((g) => _matchesGlob(relative, g))) {
        continue;
      }
      all.add(file.path);
    }
    return all;
  }

  /// Minimal glob matcher supporting `**`, `*`, and literal segments.
  static bool _matchesGlob(String path, String pattern) {
    // Convert glob to a regex.
    final regexStr = pattern
        .replaceAll('.', r'\.')
        .replaceAll('**/', '(?:.+/)?')
        .replaceAll('**', '.+')
        .replaceAll('*', '[^/]*');
    return RegExp('^$regexStr\$').hasMatch(path);
  }
}

// ---------------------------------------------------------------------------

class _StringVisitor extends GeneralizingAstVisitor<void> {
  _StringVisitor({
    required this.filePath,
    required this.projectRoot,
    required this.settings,
    required this.usedKeys,
    required this.sourceCode,
  });

  final String filePath;
  final String projectRoot;
  final ScanSettings settings;
  final Set<String> usedKeys;
  final String sourceCode;
  final List<ExtractedString> found = [];

  static final _interpolationVarRe =
      RegExp(r'\$\{?([a-zA-Z_]\w*)\}?');

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final name = node.constructorName.type.name2.lexeme;
    if (_positionalWidgets.contains(name)) {
      final args = node.argumentList.arguments;
      if (args.isNotEmpty && args.first is StringLiteral) {
        _process(args.first as StringLiteral, ExtractionSource.textWidget);
      }
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    final paramName = node.name.label.name;
    if (_namedParams.contains(paramName) &&
        node.expression is StringLiteral) {
      final src = _sourceFromParam(paramName);
      _process(node.expression as StringLiteral, src);
    }
    super.visitNamedExpression(node);
  }

  void _process(StringLiteral node, ExtractionSource source) {
    final value = _valueOf(node);
    if (value == null) return;
    if (ExtractionFilter.shouldExclude(value, settings)) return;

    final offset = node.offset;
    final lineNumber = _lineOf(offset);
    final col = _columnOf(offset);
    final snippet = _snippet(lineNumber);
    final vars = _interpolationVarRe
        .allMatches(value)
        .map((m) => m.group(1)!)
        .toList();

    final relative = p.relative(filePath, from: projectRoot);
    final key = KeyGenerator.generate(
      value,
      settings.keyConvention,
      usedKeys,
    );
    usedKeys.add(key);

    found.add(
      ExtractedString(
        id: _stableId(relative, lineNumber, col),
        value: value,
        filePath: relative,
        lineNumber: lineNumber,
        columnNumber: col,
        contextSnippet: snippet,
        source: source,
        interpolationVars: vars,
        suggestedKey: key,
      ),
    );
  }

  String? _valueOf(StringLiteral node) {
    if (node is SimpleStringLiteral) return node.value;
    if (node is AdjacentStrings) {
      final buf = StringBuffer();
      for (final s in node.strings) {
        final v = _valueOf(s);
        if (v == null) return null;
        buf.write(v);
      }
      return buf.toString();
    }
    // StringInterpolation — extract the template text with placeholders.
    if (node is StringInterpolation) {
      final buf = StringBuffer();
      for (final element in node.elements) {
        if (element is InterpolationString) {
          buf.write(element.value);
        } else if (element is InterpolationExpression) {
          final expr = element.expression;
          buf.write('{${expr.toSource()}}');
        }
      }
      return buf.toString();
    }
    return null;
  }

  int _lineOf(int offset) {
    var line = 1;
    for (var i = 0; i < offset && i < sourceCode.length; i++) {
      if (sourceCode[i] == '\n') line++;
    }
    return line;
  }

  int _columnOf(int offset) {
    var col = 1;
    for (var i = offset - 1; i >= 0; i--) {
      if (sourceCode[i] == '\n') break;
      col++;
    }
    return col;
  }

  String _snippet(int lineNumber) {
    final lines = sourceCode.split('\n');
    final from = (lineNumber - 3).clamp(0, lines.length - 1);
    final to = (lineNumber + 1).clamp(0, lines.length - 1);
    return lines.sublist(from, to + 1).join('\n');
  }

  ExtractionSource _sourceFromParam(String paramName) {
    return switch (paramName) {
      'hintText' => ExtractionSource.hintText,
      'labelText' => ExtractionSource.labelText,
      'helperText' => ExtractionSource.helperText,
      'errorText' => ExtractionSource.errorText,
      'title' || 'label' => ExtractionSource.titleParam,
      'tooltip' || 'semanticsLabel' => ExtractionSource.semanticsLabel,
      'buttonText' => ExtractionSource.buttonText,
      _ => ExtractionSource.other,
    };
  }

  static String _stableId(String filePath, int line, int col) {
    // Simple deterministic ID: hex of path+line+col.
    final raw = '$filePath:$line:$col';
    return raw.codeUnits
        .fold(0, (prev, e) => (prev * 31 + e) & 0xFFFFFFFF)
        .toRadixString(16)
        .padLeft(8, '0');
  }
}
