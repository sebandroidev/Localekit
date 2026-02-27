import 'package:freezed_annotation/freezed_annotation.dart';

part 'string_filter.freezed.dart';

/// Filter state for the string browser pane (SB-03).
@freezed
class StringFilter with _$StringFilter {
  const factory StringFilter({
    /// Free-text search — matches source value or key (case-insensitive).
    @Default('') String query,

    /// Status filter — one of: untranslated | translated | approved |
    /// ignored. Null means show all.
    @Default(null) String? statusFilter,
  }) = _StringFilter;
}
