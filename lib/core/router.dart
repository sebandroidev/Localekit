import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:localekit/features/projects/settings_screen.dart';
import 'package:localekit/features/projects/welcome_screen.dart';
import 'package:localekit/features/projects/workspace_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// Named route paths used throughout the app.
abstract final class AppRoutes {
  /// The welcome / landing screen shown on first launch.
  static const String welcome = '/';

  /// The main split-pane workspace.
  static const String workspace = '/workspace';

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
              builder: (context, state) => const WorkspaceScreen(),
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

/// Minimal shell scaffold that will host the tab bar in milestone 1.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
