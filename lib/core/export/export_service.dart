import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/database/daos/strings_dao.dart';
import 'package:localekit/core/database/daos/translations_dao.dart';
import 'package:localekit/core/database/database_provider.dart';
import 'package:localekit/core/export/export_writer.dart';
import 'package:localekit/core/export/writers/arb_writer.dart';
import 'package:localekit/core/export/writers/flat_json_writer.dart';
import 'package:localekit/core/export/writers/nested_json_writer.dart';
import 'package:localekit/core/export/writers/properties_writer.dart';
import 'package:localekit/core/export/writers/yaml_writer.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_service.g.dart';

/// Supported export formats (EXP-01).
enum ExportFormat {
  arb('ARB (Flutter)', 'arb'),
  flatJson('Flat JSON', 'json'),
  nestedJson('Nested JSON', 'json'),
  yaml('YAML', 'yaml'),
  javaProperties('Java Properties', 'properties');

  const ExportFormat(this.label, this.extension);

  final String label;
  final String extension;
}

/// Result of a single export operation.
class ExportResult {
  const ExportResult({
    required this.format,
    required this.locale,
    required this.filePath,
  });

  final ExportFormat format;
  final String locale;
  final String filePath;
}

/// Service that loads translated strings from the DB and writes export files.
class ExportService {
  ExportService({required this.stringsDao, required this.translationsDao});

  final StringsDao stringsDao;
  final TranslationsDao translationsDao;

  ExportWriter _writerFor(ExportFormat format) => switch (format) {
        ExportFormat.arb => const ArbWriter(),
        ExportFormat.flatJson => const FlatJsonWriter(),
        ExportFormat.nestedJson => const NestedJsonWriter(),
        ExportFormat.yaml => const YamlWriter(),
        ExportFormat.javaProperties => const PropertiesWriter(),
      };

  /// Exports all approved/manual/auto translations for [projectId] to
  /// [outputDir] in the given [format].
  ///
  /// One file is written per locale. Returns a list of [ExportResult]s.
  Future<List<ExportResult>> export({
    required String projectId,
    required String outputDir,
    required ExportFormat format,
    required List<String> locales,
  }) async {
    final strings = await stringsDao.getStringsForProject(projectId);
    final results = <ExportResult>[];

    for (final locale in locales) {
      final entries = <ExportEntry>[];

      for (final s in strings) {
        if (s.key == null || s.key!.isEmpty) continue;
        final translation = await translationsDao.getTranslation(s.id, locale);
        if (translation == null ||
            translation.value == null ||
            translation.value!.isEmpty) {
          continue;
        }

        // Extract placeholder names from {name} patterns.
        final placeholders = RegExp(r'\{(\w+)\}')
            .allMatches(s.sourceValue)
            .map((m) => m.group(1)!)
            .toList();

        entries.add(
          ExportEntry(
            key: s.key!,
            value: translation.value!,
            description: s.contextSnippet,
            placeholders: placeholders,
          ),
        );
      }

      if (entries.isEmpty) continue;

      final writer = _writerFor(format);
      final content = writer.write(locale, entries);

      final fileName = switch (format) {
        ExportFormat.arb => 'intl_$locale.${writer.extension}',
        _ => '$locale.${writer.extension}',
      };

      final file = File(p.join(outputDir, fileName));
      await file.parent.create(recursive: true);
      await file.writeAsString(content, flush: true);

      results.add(
        ExportResult(
          format: format,
          locale: locale,
          filePath: file.path,
        ),
      );
    }

    return results;
  }
}

/// Provides the [ExportService].
@Riverpod(keepAlive: true)
ExportService exportService(Ref ref) => ExportService(
      stringsDao: ref.watch(stringsDaoProvider),
      translationsDao: ref.watch(translationsDaoProvider),
    );
