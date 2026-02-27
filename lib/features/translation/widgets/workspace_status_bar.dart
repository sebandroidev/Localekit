import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/database_provider.dart';
import 'package:localekit/core/theme/app_colors.dart';

/// The fixed-height status bar at the bottom of the workspace.
///
/// Displays string count totals grouped by translation status.
class WorkspaceStatusBar extends ConsumerWidget {
  const WorkspaceStatusBar({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stringsAsync = ref.watch(_stringsForProjectProvider(projectId));
    return stringsAsync.when(
      loading: () => const _StatusBarShell(children: []),
      error: (_, __) => const _StatusBarShell(children: []),
      data: (strings) {
        final counts = _countByStatus(strings);
        return _StatusBarShell(
          children: [
            _StatusChip(
              label: 'Total ${strings.length}',
              color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
            ),
            _StatusChip(
              label: '🔴 ${counts['untranslated'] ?? 0}',
              color: AppColors.statusMissing,
            ),
            _StatusChip(
              label: '🟡 ${counts['modified'] ?? 0}',
              color: AppColors.statusModified,
            ),
            _StatusChip(
              label: '✅ ${counts['approved'] ?? 0}',
              color: AppColors.statusTranslated,
            ),
            _StatusChip(
              label: '⬜ ${counts['ignored'] ?? 0}',
              color: AppColors.statusIgnored,
            ),
          ],
        );
      },
    );
  }

  Map<String, int> _countByStatus(List<LocaleString> strings) {
    final result = <String, int>{};
    for (final s in strings) {
      result[s.status] = (result[s.status] ?? 0) + 1;
    }
    return result;
  }
}

class _StatusBarShell extends StatelessWidget {
  const _StatusBarShell({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: children,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

final _stringsForProjectProvider =
    FutureProvider.autoDispose.family<List<LocaleString>, String>(
  (ref, projectId) => ref.watch(stringsDaoProvider).getStringsForProject(
        projectId,
      ),
);
