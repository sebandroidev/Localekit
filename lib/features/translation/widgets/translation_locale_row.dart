import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/ai/translation_memory_service.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/database_provider.dart';
import 'package:localekit/core/theme/app_colors.dart';

/// One row in the translation editor — shows the locale code and a text
/// field to enter/edit the translated value (TE-03).
class TranslationLocaleRow extends ConsumerStatefulWidget {
  const TranslationLocaleRow({
    required this.locale,
    required this.stringId,
    required this.sourceValue,
    required this.sourceLang,
    required this.existing,
    super.key,
  });

  /// BCP-47 locale code for this translation (e.g. `fr`, `zh_TW`).
  final String locale;

  /// The source [LocaleString] ID.
  final String stringId;

  /// The original source string value (used for AI translation).
  final String sourceValue;

  /// The BCP-47 locale of the source string (e.g. `en`).
  final String sourceLang;

  /// The existing [Translation] row, or null if not yet translated.
  final Translation? existing;

  @override
  ConsumerState<TranslationLocaleRow> createState() =>
      _TranslationLocaleRowState();
}

class _TranslationLocaleRowState
    extends ConsumerState<TranslationLocaleRow> {
  late final TextEditingController _ctrl;
  bool _dirty = false;
  bool _translating = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.existing?.value ?? '');
  }

  @override
  void didUpdateWidget(TranslationLocaleRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh text when the underlying row changes externally (e.g. AI fill).
    if (oldWidget.existing?.value != widget.existing?.value && !_dirty) {
      _ctrl.text = widget.existing?.value ?? '';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save({required bool approve}) async {
    final dao = ref.read(translationsDaoProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    final status = approve ? 'approved' : 'manual';
    if (widget.existing != null) {
      await dao.upsertTranslation(
        TranslationsCompanion(
          id: Value(widget.existing!.id),
          stringId: Value(widget.stringId),
          locale: Value(widget.locale),
          value: Value(_ctrl.text),
          status: Value(status),
          updatedAt: Value(now),
        ),
      );
    } else {
      final id = '${widget.stringId}_${widget.locale}_$now';
      await dao.upsertTranslation(
        TranslationsCompanion.insert(
          id: id,
          stringId: widget.stringId,
          locale: widget.locale,
          value: Value(_ctrl.text),
          status: Value(status),
          updatedAt: Value(now),
        ),
      );
    }
    if (mounted) {
      setState(() => _dirty = false);
    }
  }

  Future<void> _aiTranslate() async {
    setState(() => _translating = true);
    try {
      final service = ref.read(translationMemoryServiceProvider);
      final translated = await service.translate(
        text: widget.sourceValue,
        sourceLang: widget.sourceLang,
        targetLang: widget.locale,
      );
      if (mounted) {
        _ctrl.text = translated;
        setState(() {
          _dirty = true;
          _translating = false;
        });
        // Auto-save as 'auto' status.
        final dao = ref.read(translationsDaoProvider);
        final now = DateTime.now().millisecondsSinceEpoch;
        if (widget.existing != null) {
          await dao.upsertTranslation(
            TranslationsCompanion(
              id: Value(widget.existing!.id),
              stringId: Value(widget.stringId),
              locale: Value(widget.locale),
              value: Value(translated),
              status: const Value('auto'),
              provider: const Value('gemini'),
              updatedAt: Value(now),
            ),
          );
        } else {
          final id = '${widget.stringId}_${widget.locale}_$now';
          await dao.upsertTranslation(
            TranslationsCompanion.insert(
              id: id,
              stringId: widget.stringId,
              locale: widget.locale,
              value: Value(translated),
              status: const Value('auto'),
              provider: const Value('gemini'),
              updatedAt: Value(now),
            ),
          );
        }
        if (mounted) setState(() => _dirty = false);
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _translating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = widget.existing?.status ?? 'pending';
    final statusColor = switch (statusText) {
      'approved' => AppColors.statusTranslated,
      'manual' => AppColors.statusModified,
      'auto' => AppColors.statusAuto,
      _ => AppColors.statusMissing,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brand.withAlpha(20),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  widget.locale.toUpperCase(),
                  style:
                      Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w700,
                          ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                    ),
              ),
              const Spacer(),
              // AI translate button
              if (_translating)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                )
              else
                InkWell(
                  onTap: _aiTranslate,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: AppColors.brand,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'AI',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.brand),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _ctrl,
            onChanged: (_) => setState(() => _dirty = true),
            maxLines: null,
            minLines: 2,
            style: Theme.of(context).textTheme.bodySmall,
            decoration: InputDecoration(
              hintText: 'Enter translation…',
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(80),
                  ),
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.darkBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.darkBorder),
              ),
            ),
          ),
          if (_dirty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _save(approve: false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      foregroundColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(180),
                    ),
                    child: Text(
                      'Save',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => _save(approve: true),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      foregroundColor: AppColors.statusTranslated,
                    ),
                    child: Text(
                      'Approve',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
