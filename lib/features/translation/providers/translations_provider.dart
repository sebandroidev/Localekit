import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localekit/core/database/app_database.dart';
import 'package:localekit/core/database/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'translations_provider.g.dart';

/// Watches all [Translation] rows for a given [stringId].
@riverpod
Stream<List<Translation>> translationsForString(
  Ref ref,
  String stringId,
) =>
    ref.watch(translationsDaoProvider).watchTranslationsForString(stringId);
