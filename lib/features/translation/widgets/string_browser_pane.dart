import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/theme/app_colors.dart';
import 'package:localekit/features/translation/providers/string_browser_provider.dart';
import 'package:localekit/features/translation/widgets/string_filter_bar.dart';
import 'package:path/path.dart' as p;

/// Left pane — file tree of extracted strings (SB-01).
///
/// Groups strings by source file; each file node is collapsible. Selecting
/// a string highlights it and updates [SelectedStringNotifier].
class StringBrowserPane extends ConsumerWidget {
  const StringBrowserPane({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync =
        ref.watch(groupedStringsProvider(projectId));

    return Column(
      children: [
        const StringFilterBar(),
        const Divider(height: 1),
        Expanded(
          child: groupedAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (e, _) => Center(
              child: Text(
                'Error loading strings',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            data: (grouped) {
              if (grouped.isEmpty) {
                return Center(
                  child: Text(
                    'No strings found.\nRun a scan to extract strings.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final paths = grouped.keys.toList()..sort();
              return ListView.builder(
                itemCount: paths.length,
                itemBuilder: (context, index) {
                  final path = paths[index];
                  final strings = grouped[path]!;
                  return _FileTreeNode(
                    filePath: path,
                    strings: strings,
                    projectId: projectId,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// File tree node
// ---------------------------------------------------------------------------

class _FileTreeNode extends ConsumerStatefulWidget {
  const _FileTreeNode({
    required this.filePath,
    required this.strings,
    required this.projectId,
  });

  final String filePath;
  final List<LocaleString> strings;
  final String projectId;

  @override
  ConsumerState<_FileTreeNode> createState() => _FileTreeNodeState();
}

class _FileTreeNodeState extends ConsumerState<_FileTreeNode> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final fileName = p.basename(widget.filePath);
    final selectedId = ref.watch(selectedStringNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Row(
              children: [
                Icon(
                  _expanded
                      ? Icons.expand_more
                      : Icons.chevron_right,
                  size: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(160),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(120),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    fileName,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${widget.strings.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(100),
                      ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.strings.map(
            (s) => _StringBrowserItem(
              string: s,
              selected: s.id == selectedId,
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual string row
// ---------------------------------------------------------------------------

class _StringBrowserItem extends ConsumerWidget {
  const _StringBrowserItem({
    required this.string,
    required this.selected,
  });

  final LocaleString string;
  final bool selected;

  Color _statusColor(String status) => switch (status) {
        'approved' => AppColors.statusTranslated,
        'modified' => AppColors.statusModified,
        'ignored' => AppColors.statusIgnored,
        _ => AppColors.statusMissing,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => ref
          .read(selectedStringNotifierProvider.notifier)
          .selectString(string.id),
      child: Container(
        color: selected
            ? AppColors.brand.withAlpha(25)
            : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(24, 3, 8, 3),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _statusColor(string.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                string.key ?? string.sourceValue,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected
                          ? AppColors.brand
                          : null,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
