import 'package:collection/collection.dart';
import 'package:journal/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "tags_list.g.dart";

@riverpod
Future<List<String>> tags(Ref ref) async {
  final database = ref.watch(appDatabaseProvider);

  final entries = await database.managers.entriesCache.get();
  final tags = entries.map((entry) => entry.tags).flattenedToList;

  return tags;
}
