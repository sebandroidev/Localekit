import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/database_provider.dart';
import 'package:localekit/core/theme/app_colors.dart';
import 'package:localekit/features/projects/providers/project_state_provider.dart';
import 'package:localekit/features/translation/providers/string_browser_provider.dart';
import 'package:localekit/features/translation/providers/translations_provider.dart';
import 'package:localekit/features/translation/widgets/translation_locale_row.dart';
import 'package:path/path.dart' as p;

/// Right pane — translation editor for the selected string (TE-01).
///
/// When no string is selected, shows an empty-state prompt.
class TranslationEditorPane extends ConsumerWidget {
  const TranslationEditorPane({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedStringNotifierProvider);

    if (selectedId == null) {
      return Center(
        child: Text(
          'Select a string to start translating.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha(120),
              ),
        ),
      );
    }

    return _StringEditorView(
      stringId: selectedId,
      projectId: projectId,
    );
  }
}

// ---------------------------------------------------------------------------
// Editor view for a specific string
// ---------------------------------------------------------------------------

class _StringEditorView extends ConsumerWidget {
  const _StringEditorView({
    required this.stringId,
    required this.projectId,
  });

  final String stringId;
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stringAsync = ref.watch(watchStringProvider(stringId));
    final translationsAsync =
        ref.watch(translationsForStringProvider(stringId));
    final projectState =
        ref.watch(projectStateNotifierProvider).valueOrNull;
    final locales = projectState?.locales ?? [];
    // First locale is treated as the source language.
    final sourceLang =
        locales.isNotEmpty ? locales.first : 'en';

    return stringAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const Center(child: Text('Error loading string')),
      data: (localeString) {
        if (localeString == null) {
          return const Center(child: Text('String not found'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StringHeader(string: localeString),
            const Divider(height: 1),
            Expanded(
              child: translationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) =>
                    const Center(child: Text('Error loading translations')),
                data: (translations) => _TranslationList(
                  locales: locales,
                  localeString: localeString,
                  sourceLang: sourceLang,
                  translations: translations,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header — source string info + actions
// ---------------------------------------------------------------------------

class _StringHeader extends ConsumerWidget {
  const _StringHeader({required this.string});

  final LocaleString string;

  Color _statusColor(String status) => switch (status) {
        'approved' => AppColors.statusTranslated,
        'modified' => AppColors.statusModified,
        'ignored' => AppColors.statusIgnored,
        _ => AppColors.statusMissing,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key + status
          Row(
            children: [
              Expanded(
                child: Text(
                  string.key ?? '(no key)',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontFamily: 'monospace',
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(string.status).withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  string.status,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _statusColor(string.status),
                      ),
                ),
              ),
              // Ignore / un-ignore toggle
              const SizedBox(width: 4),
              IconButton(
                onPressed: () async {
                  final newStatus =
                      string.status == 'ignored' ? 'untranslated' : 'ignored';
                  await ref
                      .read(stringsDaoProvider)
                      .updateStatus(string.id, newStatus);
                },
                icon: Icon(
                  string.status == 'ignored'
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 16,
                ),
                tooltip: string.status == 'ignored' ? 'Unignore' : 'Ignore',
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Source value
          Text(
            string.sourceValue,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          // File location
          Text(
            '${p.basename(string.filePath)}'
            '${string.lineNumber != null ? ':${string.lineNumber}' : ''}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(120),
                ),
          ),
          // Context snippet
          if (string.contextSnippet != null &&
              string.contextSnippet!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                string.contextSnippet!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(180),
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Translation list — one row per locale
// ---------------------------------------------------------------------------

class _TranslationList extends StatelessWidget {
  const _TranslationList({
    required this.locales,
    required this.localeString,
    required this.sourceLang,
    required this.translations,
  });

  final List<String> locales;
  final LocaleString localeString;
  final String sourceLang;
  final List<Translation> translations;

  @override
  Widget build(BuildContext context) {
    if (locales.isEmpty) {
      return Center(
        child: Text(
          'No locales configured.\nAdd locales in Settings.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha(120),
              ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final byLocale = {
      for (final t in translations) t.locale: t,
    };

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: locales.length,
      itemBuilder: (context, index) {
        final locale = locales[index];
        return TranslationLocaleRow(
          locale: locale,
          stringId: localeString.id,
          sourceValue: localeString.sourceValue,
          sourceLang: sourceLang,
          existing: byLocale[locale],
          key: ValueKey('$locale-${localeString.id}'),
        );
      },
    );
  }
}
