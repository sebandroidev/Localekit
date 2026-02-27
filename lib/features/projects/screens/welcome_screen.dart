import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:localekit/core/router.dart';
import 'package:localekit/core/theme/app_colors.dart';
import 'package:localekit/features/projects/models/project_state.dart';
import 'package:localekit/features/projects/providers/project_state_provider.dart';
import 'package:localekit/features/projects/widgets/recent_projects_list.dart';

/// The landing screen shown on first launch and when no project is open.
///
/// Provides:
/// - "Open Project Folder" button (`Cmd/Ctrl+O`)
/// - Recent projects list loaded from SQLite
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _isOpening = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Listen for errors from the project state provider.
    ref.listen<AsyncValue<ProjectState?>>(
      projectStateNotifierProvider,
      (_, next) {
        if (next is AsyncError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to open project: ${next.error}')),
          );
          setState(() => _isOpening = false);
        } else if (next is AsyncData && next.value != null) {
          context.go(
            AppRoutes.workspaceForProject(next.value!.project.id),
          );
        }
      },
    );

    return Scaffold(
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyO, meta: true):
              _openFolder,
          const SingleActivator(LogicalKeyboardKey.keyO, control: true):
              _openFolder,
        },
        child: Focus(
          autofocus: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo / icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.brand.withAlpha(30),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.language,
                        size: 36,
                        color: AppColors.brand,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'LocaleKit',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Open a project folder to extract and manage'
                      ' translations.',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isOpening ? null : _openFolder,
                        icon: _isOpening
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.folder_open, size: 18),
                        label: Text(
                          _isOpening
                              ? 'Opening…'
                              : 'Open Project Folder  ⌘O',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    RecentProjectsList(
                      onProjectSelected: (project) =>
                          _openPath(project.path),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFolder() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Project Folder',
    );
    if (result == null) return;
    await _openPath(result);
  }

  Future<void> _openPath(String path) async {
    setState(() => _isOpening = true);
    await ref
        .read(projectStateNotifierProvider.notifier)
        .openProject(path);
    // Navigation is triggered by the listener above.
  }
}
