import "dart:typed_data";

import "package:journal/database.dart";
import "package:journal/models/entry.dart";
import "package:journal/logger.dart";
import "package:journal/main.dart";
import "package:journal/providers/entry_list.dart";
import "package:journal/utils/file.dart";
import "package:journal/utils/location.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:path/path.dart" as path;

part "entry.g.dart";

@riverpod
class EntryNotifier extends _$EntryNotifier {
  Future<DateTime> getDatetime() async {
    final datetime = DateTime.tryParse(datetimeString);
    if (datetime == null) {
      logger.w(
        "Tried to load an entry with an invalid datetime: $datetimeString",
      );
      throw Exception("\"$datetimeString\" is not a valid entry identifier.");
    }
    return datetime;
  }

  @override
  Future<Entry> build(String datetimeString) async {
    logger.d("Loading entry $datetimeString");
    final rootFolder = ref.watch(folderUriProvider);
    final database = ref.watch(appDatabaseProvider);
    final saf = ref.watch(safProvider);
    final safStream = ref.watch(safStreamProvider);
    final datetime = await getDatetime();

    final path = pathFromDatetime(datetime);
    final content = await readFile(rootFolder.toString(), path, saf, safStream);

    if (content == null) {
      logger.w("Couldn't load the requested entry.");
      throw Exception("Couldn't find the entry.");
    }

    final entry = await Entry.read(
      datetimeString,
      rootFolder.toString(),
      saf,
      safStream,
    );
    if (entry != null) {
      database
          .into(database.entriesCache)
          .insertOnConflictUpdate(cacheEntryFromEntry(entry));
      return entry;
    }

    throw Exception("Entry not found.");
  }

  Future<Entry> writeWith({
    String? body,
    DateTime? datetime,
    List<String>? tags,
    Location? location,
  }) async {
    final current = state.asData?.value;
    final rootFolder = ref.watch(folderUriProvider).toString();
    final saf = ref.watch(safProvider);
    final safStream = ref.watch(safStreamProvider);
    final database = ref.watch(appDatabaseProvider);
    if (current == null) {
      logger.w("Tried to update entry when the entry provider was busy.");
      throw Exception("Tried to update entry when the provider was busy.");
    }

    final keepAliveLink = ref.keepAlive();

    try {
      final newEntry = await current.copyWith(
        rootFolder,
        saf,
        safStream,
        body: body,
        datetime: datetime,
        tags: tags,
        location: location,
      );

      if (newEntry.datetime != current.datetime) {
        await current.delete(rootFolder, saf, safStream);
        ref.read(entryListProvider.notifier).removeEntry(current.datetime);
      }
      await newEntry.write(rootFolder, saf, safStream);
      ref.read(entryListProvider.notifier).addEntry(newEntry.datetime);
      database
          .into(database.entriesCache)
          .insertOnConflictUpdate(cacheEntryFromEntry(newEntry));
      state = AsyncData(newEntry);
      return newEntry;
    } finally {
      keepAliveLink.close();
    }
  }

  Future<void> delete() async {
    final current = state.asData?.value;
    final rootFolder = ref.watch(folderUriProvider).toString();
    final saf = ref.watch(safProvider);
    final safStream = ref.watch(safStreamProvider);
    if (current == null) {
      logger.w("Tried to update entry when the entry provider was busy.");
      throw Exception("Tried to update entry when the provider was busy.");
    }
    await current.delete(rootFolder, saf, safStream);
    ref.read(entryListProvider.notifier).removeEntry(current.datetime);
  }

  Future<void> addImage(Uint8List bytes, String name, String sourcePath) async {
    final saf = ref.watch(safProvider);
    final safStream = ref.watch(safStreamProvider);
    final keepAliveLink = ref.keepAlive();
    try {
      final rootFolder = ref.watch(folderUriProvider).toString();
      final current = await future;

      final newEntry = await current.addImage(
        rootFolder,
        bytes,
        name,
        path.extension(sourcePath),
        saf,
        safStream,
      );
      state = AsyncData(newEntry);
    } finally {
      keepAliveLink.close();
    }
  }

  Future<void> removeImage(String name) async {
    final saf = ref.watch(safProvider);
    final safStream = ref.watch(safStreamProvider);
    final current = state.asData?.value;
    final rootFolder = ref.watch(folderUriProvider).toString();
    if (current == null) {
      logger.w("Tried to add image when the entry provider was busy.");
      throw Exception("Tried to update entry when the provider was busy.");
    }

    final newEntry = await current.removeImage(
      rootFolder,
      name,
      saf,
      safStream,
    );
    state = AsyncData(newEntry);
  }
}
