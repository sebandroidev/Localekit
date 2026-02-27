import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:localekit/core/theme/app_colors.dart';
import 'package:localekit/features/projects/providers/project_state_provider.dart';

/// The tabbed settings screen (SET-01).
///
/// Tabs:
/// 1. General — project name, root path, locales
/// 2. Extraction — min length, ignore globs, key convention
/// 3. AI — provider toggle, API key input
/// 4. Export — ARB dir, template file, output class
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 18),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
        titleTextStyle: Theme.of(context).textTheme.labelLarge,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.brand,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withAlpha(140),
          indicatorColor: AppColors.brand,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Extraction'),
            Tab(text: 'AI'),
            Tab(text: 'Export'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GeneralTab(),
          _ExtractionTab(),
          _AiTab(),
          _ExportTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// General tab
// ---------------------------------------------------------------------------

class _GeneralTab extends ConsumerWidget {
  const _GeneralTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStateNotifierProvider).valueOrNull;

    if (projectState == null) {
      return const Center(child: Text('No project open.'));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _SectionHeader('Project'),
        _ReadOnlyField(
          label: 'Name',
          value: projectState.project.name,
        ),
        const SizedBox(height: 8),
        _ReadOnlyField(
          label: 'Root path',
          value: projectState.project.path,
        ),
        const SizedBox(height: 8),
        _ReadOnlyField(
          label: 'Framework',
          value: projectState.framework.name,
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Locales'),
        _ReadOnlyField(
          label: 'Configured locales',
          value: projectState.locales.isEmpty
              ? 'None — add locales to enable translation'
              : projectState.locales.join(', '),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Extraction tab
// ---------------------------------------------------------------------------

class _ExtractionTab extends ConsumerWidget {
  const _ExtractionTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStateNotifierProvider).valueOrNull;

    if (projectState == null) {
      return const Center(child: Text('No project open.'));
    }

    final settings = projectState.scanSettings;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _SectionHeader('Filter'),
        _ReadOnlyField(
          label: 'Minimum string length',
          value: settings.minStringLength.toString(),
        ),
        const SizedBox(height: 8),
        _ReadOnlyField(
          label: 'Ignore globs',
          value: settings.ignoreGlobs.isEmpty
              ? 'None'
              : settings.ignoreGlobs.join(', '),
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Key generation'),
        _ReadOnlyField(
          label: 'Convention',
          value: settings.keyConvention.name,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// AI tab
// ---------------------------------------------------------------------------

class _AiTab extends StatelessWidget {
  const _AiTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        _SectionHeader('Provider'),
        _ReadOnlyField(label: 'Active provider', value: 'Gemini (Google)'),
        SizedBox(height: 24),
        _SectionHeader('API Key'),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'AI provider configuration coming in Phase 7.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Export tab
// ---------------------------------------------------------------------------

class _ExportTab extends ConsumerWidget {
  const _ExportTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStateNotifierProvider).valueOrNull;

    if (projectState == null) {
      return const Center(child: Text('No project open.'));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _SectionHeader('ARB output'),
        _ReadOnlyField(
          label: 'ARB directory',
          value: projectState.arbDirectory,
        ),
        const SizedBox(height: 8),
        _ReadOnlyField(
          label: 'Template ARB file',
          value: projectState.templateArbFile ?? 'Not detected',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.brand,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withAlpha(160),
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
