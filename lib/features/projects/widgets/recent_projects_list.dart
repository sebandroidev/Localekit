import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/database_provider.dart';
import 'package:localekit/core/theme/app_colors.dart';
import 'package:path/path.dart' as p;

/// Displays the list of recently opened projects loaded from SQLite.
class RecentProjectsList extends ConsumerWidget {
  const RecentProjectsList({
    required this.onProjectSelected,
    super.key,
  });

  final void Function(Project project) onProjectSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(
      _recentProjectsProvider,
    );
    return projectsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (projects) {
        if (projects.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Recent',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(140),
                      letterSpacing: 0.8,
                    ),
              ),
            ),
            ...projects.map(
              (project) => _RecentProjectTile(
                project: project,
                onTap: () => onProjectSelected(project),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecentProjectTile extends StatelessWidget {
  const _RecentProjectTile({
    required this.project,
    required this.onTap,
  });

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(
              Icons.folder_outlined,
              size: 16,
              color: AppColors.brand.withAlpha(200),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    p.dirname(project.path),
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loads the last 10 opened projects ordered by rowid descending.
final _recentProjectsProvider =
    FutureProvider.autoDispose<List<Project>>((ref) async {
  final dao = ref.watch(projectsDaoProvider);
  final all = await dao.getAllProjects();
  // Most recently upserted first; cap at 10.
  return all.reversed.take(10).toList();
});
