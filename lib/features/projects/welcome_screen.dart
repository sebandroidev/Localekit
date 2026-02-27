import 'package:flutter/material.dart';

/// Placeholder shown on first launch or when no projects are open.
///
/// Will be replaced by PM-01 (full welcome screen with folder picker).
class WelcomeScreen extends StatelessWidget {
  /// Creates the [WelcomeScreen].
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text('Welcome to LocaleKit'),
        ),
      );
}
