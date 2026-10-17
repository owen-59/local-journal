import 'package:collection/collection.dart';
import 'package:journal/providers/cache_entries.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "tags_list.g.dart";

@riverpod
Future<List<String>> tags(Ref ref) async {
  final entries = await ref.watch(cacheEntriesProvider.future);
  final tags = entries.map((entry) => entry.tags).flattenedToList;

  return tags;
}
