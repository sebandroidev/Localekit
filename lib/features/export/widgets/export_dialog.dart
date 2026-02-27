import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/export/export_service.dart';
import 'package:localekit/core/theme/app_colors.dart';
import 'package:localekit/features/projects/providers/project_state_provider.dart';

/// Modal dialog for exporting translations (EXP-07).
///
/// Lets the user choose:
/// - Output format (ARB, flat JSON, nested JSON, YAML, Java Properties)
/// - Output directory (via OS folder picker)
///
/// Then writes files and shows a result summary.
class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({required this.projectId, super.key});

  final String projectId;

  /// Shows the dialog and returns when dismissed.
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    String projectId,
  ) =>
      showDialog<void>(
        context: context,
        builder: (_) => ExportDialog(projectId: projectId),
      );

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  ExportFormat _format = ExportFormat.arb;
  String? _outputDir;
  bool _exporting = false;
  List<ExportResult>? _results;
  String? _error;

  Future<void> _pickDir() async {
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select export directory',
    );
    if (dir != null) {
      setState(() => _outputDir = dir);
    }
  }

  Future<void> _export() async {
    final dir = _outputDir;
    if (dir == null) return;

    final locales =
        ref.read(projectStateNotifierProvider).valueOrNull?.locales ?? [];
    if (locales.isEmpty) {
      setState(() => _error = 'No locales configured in this project.');
      return;
    }

    setState(() {
      _exporting = true;
      _error = null;
      _results = null;
    });

    try {
      final service = ref.read(exportServiceProvider);
      final results = await service.export(
        projectId: widget.projectId,
        outputDir: dir,
        format: _format,
        locales: locales,
      );
      if (mounted) {
        setState(() {
          _results = results;
          _exporting = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _exporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export translations'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('Format'),
            const SizedBox(height: 8),
            DropdownButtonFormField<ExportFormat>(
              initialValue: _format,
              isDense: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              items: ExportFormat.values
                  .map(
                    (f) => DropdownMenuItem(
                      value: f,
                      child: Text(
                        f.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _format = v);
              },
            ),
            const SizedBox(height: 16),
            const _SectionLabel('Output directory'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _outputDir ?? 'No folder selected',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _outputDir == null
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(100)
                              : null,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _pickDir,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brand,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Browse…'),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.statusMissing,
                    ),
              ),
            ],
            if (_results != null) ...[
              const SizedBox(height: 12),
              Text(
                'Exported ${_results!.length} file(s):',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.statusTranslated,
                    ),
              ),
              ..._results!.map(
                (r) => Text(
                  r.filePath,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed:
              (_outputDir == null || _exporting) ? null : _export,
          style: TextButton.styleFrom(foregroundColor: AppColors.brand),
          child: _exporting
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                )
              : const Text('Export'),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
              letterSpacing: 0.8,
            ),
      );
}
