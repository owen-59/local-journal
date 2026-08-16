import 'package:journal/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:journal/providers/entry_list.dart';

part "tags_list.g.dart";

@riverpod
Future<List<String>> tags(Ref ref) async {
  final entriesAsyncVal = ref.watch(entryListProvider);
  final entries = entriesAsyncVal.value;
  if (entries == null) {
    logger.i("entries");
    return [];
  }
  var foundTags = <String>{};
  for (var entry in entries) {
    logger.i(entry.tags);
    foundTags.addAll(entry.tags);
  }
  return foundTags.toList();
}
