import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/theme/app_colors.dart';
import 'package:localekit/features/extraction/providers/scan_provider.dart';
import 'package:path/path.dart' as p;

/// Displays scan progress inline in the workspace app bar area.
///
/// Visible only while a scan is running; collapses to zero height otherwise.
class ScanProgressBar extends ConsumerWidget {
  const ScanProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanNotifierProvider);

    return switch (scanState) {
      ScanRunning(:final progress) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress.fraction > 0 ? progress.fraction : null,
              backgroundColor:
                  AppColors.darkBorder.withAlpha(80),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.brand),
              minHeight: 2,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Scanning: ${p.basename(progress.currentFile)}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '${progress.stringsFound} strings',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () =>
                        ref.read(scanNotifierProvider.notifier).cancelScan(),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.statusMissing,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
