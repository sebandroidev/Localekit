import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:localekit/core/router.dart';
import 'package:localekit/core/theme/app_colors.dart';
import 'package:localekit/features/export/widgets/export_dialog.dart';
import 'package:localekit/features/extraction/providers/scan_provider.dart';
import 'package:localekit/features/extraction/widgets/scan_progress_bar.dart';
import 'package:localekit/features/projects/providers/project_state_provider.dart';
import 'package:localekit/features/translation/widgets/string_browser_pane.dart';
import 'package:localekit/features/translation/widgets/translation_editor_pane.dart';
import 'package:localekit/features/translation/widgets/workspace_status_bar.dart';
import 'package:localekit/shared/widgets/drag_divider.dart';

/// Left-pane width limits (logical pixels).
const _kMinLeftPane = 200.0;
const _kMaxLeftPane = 500.0;
const _kDefaultLeftPane = 280.0;

/// The main split-pane workspace screen.
///
/// Layout (top-to-bottom):
/// 1. `_WorkspaceAppBar` (48 px)
/// 2. `ScanProgressBar` (visible while scanning)
/// 3. `Row` — left pane + drag divider + right pane
/// 4. `WorkspaceStatusBar` (28 px)
class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  double _leftPaneWidth = _kDefaultLeftPane;

  @override
  Widget build(BuildContext context) {
    final projectState =
        ref.watch(projectStateNotifierProvider).valueOrNull;

    if (projectState == null) {
      // Project not loaded — redirect to welcome.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go(AppRoutes.welcome),
      );
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      body: Column(
        children: [
          _WorkspaceAppBar(
            projectName: projectState.project.name,
            framework: projectState.framework.name,
            projectId: widget.projectId,
          ),
          const ScanProgressBar(),
          Expanded(
            child: Row(
              children: [
                // Left pane — string browser / file tree (SB-01)
                SizedBox(
                  width: _leftPaneWidth,
                  child: StringBrowserPane(
                    projectId: widget.projectId,
                  ),
                ),
                DragDivider(
                  onDelta: (delta) => setState(() {
                    _leftPaneWidth = (_leftPaneWidth + delta)
                        .clamp(_kMinLeftPane, _kMaxLeftPane);
                  }),
                ),
                // Right pane — translation editor (TE-01)
                Expanded(
                  child: TranslationEditorPane(
                    projectId: widget.projectId,
                  ),
                ),
              ],
            ),
          ),
          WorkspaceStatusBar(projectId: widget.projectId),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _WorkspaceAppBar extends ConsumerWidget {
  const _WorkspaceAppBar({
    required this.projectName,
    required this.framework,
    required this.projectId,
  });

  final String projectName;
  final String framework;
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanNotifierProvider);
    final isScanning = scanState is ScanRunning;

    return Container(
      height: 48,
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Project name + framework badge
          Text(
            projectName,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.brand.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              framework,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.brand,
                  ),
            ),
          ),
          const Spacer(),
          // Scan button
          TextButton.icon(
            onPressed: isScanning
                ? null
                : () => ref
                    .read(scanNotifierProvider.notifier)
                    .startScan(),
            icon: const Icon(Icons.search, size: 16),
            label: Text(isScanning ? 'Scanning…' : 'Scan'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brand,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
          const SizedBox(width: 4),
          // Export button
          TextButton.icon(
            onPressed: () =>
                ExportDialog.show(context, ref, projectId),
            icon: const Icon(Icons.upload_outlined, size: 16),
            label: const Text('Export'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brand,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
          const SizedBox(width: 4),
          // Settings icon
          IconButton(
            onPressed: () => context.go(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined, size: 18),
            tooltip: 'Settings',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
