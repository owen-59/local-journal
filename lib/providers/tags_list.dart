import "package:collection/collection.dart";
import "package:journal/providers/cache_entries.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

part "tags_list.g.dart";

class TagEntry {
  final int frequency;
  final String name;

  const TagEntry({required this.frequency, required this.name});
}

@riverpod
Future<List<TagEntry>> tags(Ref ref) async {
  final entries = await ref.watch(cacheEntriesProvider.future);
  final tags = entries.map((entry) => entry.tags).flattenedToList;

  final frequencies = <String, int>{};
  for (final tag in tags) {
    frequencies[tag] = (frequencies[tag] ?? 0) + 1;
  }

  return frequencies.entries
      .sorted((a, b) => a.value - b.value)
      .map((entry) => TagEntry(name: entry.key, frequency: entry.value))
      .toList();
}
