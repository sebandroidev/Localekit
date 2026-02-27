import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/theme/app_colors.dart';
import 'package:localekit/features/translation/providers/string_browser_provider.dart';

/// Search + status-filter bar at the top of the string browser (SB-03).
class StringFilterBar extends ConsumerStatefulWidget {
  const StringFilterBar({super.key});

  @override
  ConsumerState<StringFilterBar> createState() => _StringFilterBarState();
}

class _StringFilterBarState extends ConsumerState<StringFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(stringFilterNotifierProvider);
    final notifier = ref.read(stringFilterNotifierProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: SizedBox(
            height: 28,
            child: TextField(
              controller: _searchController,
              onChanged: notifier.setQuery,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: InputDecoration(
                hintText: 'Search strings…',
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(100),
                    ),
                prefixIcon: const Icon(Icons.search, size: 14),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColors.darkBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColors.darkBorder,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 28,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _StatusChip(
                label: 'All',
                selected: filter.statusFilter == null,
                onTap: () => notifier.setStatus(null),
              ),
              _StatusChip(
                label: 'Untranslated',
                selected: filter.statusFilter == 'untranslated',
                onTap: () => notifier.setStatus('untranslated'),
                dotColor: AppColors.statusMissing,
              ),
              _StatusChip(
                label: 'Modified',
                selected: filter.statusFilter == 'modified',
                onTap: () => notifier.setStatus('modified'),
                dotColor: AppColors.statusModified,
              ),
              _StatusChip(
                label: 'Approved',
                selected: filter.statusFilter == 'approved',
                onTap: () => notifier.setStatus('approved'),
                dotColor: AppColors.statusTranslated,
              ),
              _StatusChip(
                label: 'Ignored',
                selected: filter.statusFilter == 'ignored',
                onTap: () => notifier.setStatus('ignored'),
                dotColor: AppColors.statusIgnored,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dotColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.brand.withAlpha(30)
                : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.brand : AppColors.darkBorder,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected
                          ? AppColors.brand
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(180),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
