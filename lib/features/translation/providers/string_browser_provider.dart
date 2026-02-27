import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/database_provider.dart';
import 'package:localekit/features/translation/models/string_filter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'string_browser_provider.g.dart';

/// Holds the ID of the currently selected [LocaleString], or null.
@riverpod
class SelectedStringNotifier extends _$SelectedStringNotifier {
  @override
  String? build() => null;

  // ignore: use_setters_to_change_properties — Riverpod notifier convention
  void selectString(String id) => state = id;
  void clearSelection() => state = null;
}

/// Holds the active filter for the string browser (SB-03).
@riverpod
class StringFilterNotifier extends _$StringFilterNotifier {
  @override
  StringFilter build() => const StringFilter();

  void setQuery(String query) => state = state.copyWith(query: query);
  void setStatus(String? status) =>
      state = state.copyWith(statusFilter: status);
  void reset() => state = const StringFilter();
}

/// A live stream of strings for [projectId], grouped by file path and
/// filtered by [StringFilterNotifier].
///
/// Map key is the file path; value is the list of matching [LocaleString]s.
@riverpod
Stream<Map<String, List<LocaleString>>> groupedStrings(
  Ref ref,
  String projectId,
) {
  final filter = ref.watch(stringFilterNotifierProvider);
  final query = filter.query.toLowerCase();
  final statusFilter = filter.statusFilter;

  return ref
      .watch(stringsDaoProvider)
      .watchStringsForProject(projectId)
      .map((List<LocaleString> strings) {
    final grouped = <String, List<LocaleString>>{};
    for (final s in strings) {
      if (query.isNotEmpty) {
        final inValue = s.sourceValue.toLowerCase().contains(query);
        final inKey = s.key?.toLowerCase().contains(query) ?? false;
        if (!inValue && !inKey) continue;
      }
      if (statusFilter != null && s.status != statusFilter) continue;
      (grouped[s.filePath] ??= []).add(s);
    }
    return grouped;
  });
}

/// Watches a single [LocaleString] by [id].
@riverpod
Stream<LocaleString?> watchString(Ref ref, String id) =>
    ref.watch(stringsDaoProvider).watchStringById(id);
