import 'package:freezed_annotation/freezed_annotation.dart';

part 'extracted_string.freezed.dart';
part 'extracted_string.g.dart';

/// Identifies the Flutter API from which a string was extracted.
enum ExtractionSource {
  textWidget,
  tooltipWidget,
  hintText,
  labelText,
  helperText,
  errorText,
  titleParam,
  semanticsLabel,
  buttonText,
  other,
}

/// A single string literal found during AST-based extraction.
@freezed
class ExtractedString with _$ExtractedString {
  const factory ExtractedString({
    /// UUID — stable across re-scans when filePath + lineNumber unchanged.
    required String id,

    /// The raw string literal value as it appears in source.
    required String value,

    /// Path relative to the project root (e.g. `lib/screens/home.dart`).
    required String filePath,

    /// 1-based line number of the string in [filePath].
    required int lineNumber,

    /// 1-based column number of the string in [filePath].
    required int columnNumber,

    /// A few lines of surrounding source code for translator context.
    required String contextSnippet,

    /// Which Flutter API produced this string.
    required ExtractionSource source,

    /// Variable names detected in string interpolation (`$var` / `{var}`).
    @Default([]) List<String> interpolationVars,

    /// camelCase key suggested for this string (may be null before EX-03 runs).
    String? suggestedKey,
  }) = _ExtractedString;

  factory ExtractedString.fromJson(Map<String, dynamic> json) =>
      _$ExtractedStringFromJson(json);
}
