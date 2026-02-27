import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:localekit/features/projects/screens/settings_screen.dart';
import 'package:localekit/features/projects/screens/welcome_screen.dart';
import 'package:localekit/features/projects/screens/workspace_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// Named route paths used throughout the app.
abstract final class AppRoutes {
  /// The welcome / landing screen shown on first launch.
  static const String welcome = '/';

  /// The main split-pane workspace for a specific project.
  static const String workspace = '/workspace/:projectId';

  /// Builds a concrete workspace path for [projectId].
  static String workspaceForProject(String projectId) =>
      '/workspace/$projectId';

  /// The settings panel.
  static const String settings = '/settings';
}

/// Provides the singleton [GoRouter] instance.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => GoRouter(
      initialLocation: AppRoutes.welcome,
      routes: [
        ShellRoute(
          builder: (context, state, child) => _AppShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.welcome,
              name: 'welcome',
              builder: (context, state) => const WelcomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.workspace,
              name: 'workspace',
              builder: (context, state) {
                final projectId =
                    state.pathParameters['projectId'] ?? '';
                return WorkspaceScreen(projectId: projectId);
              },
            ),
            GoRoute(
              path: AppRoutes.settings,
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );

/// Minimal shell that hosts the global menu bar (future milestone).
class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
