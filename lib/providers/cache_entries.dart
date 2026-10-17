import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/database.dart';
import 'package:journal/main.dart';

final cacheEntriesProvider = FutureProvider<List<EntriesCacheData>>((
  ref,
) async {
  final database = ref.watch(appDatabaseProvider);

  final entries = await database.managers.entriesCache.get();

  return entries;
});
