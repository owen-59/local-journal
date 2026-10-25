import 'dart:async';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:journal/database.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/providers/cache_entries.dart';
import 'package:journal/utils/file.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "entry_list.g.dart";

@Riverpod(keepAlive: true)
class EntryList extends _$EntryList {
  var _state = <DateTime>[];
  late AppDatabase database;

  @override
  Future<List<DateTime>> build() async {
    database = ref.watch(appDatabaseProvider);

    fullReload();

    return [];
  }

  bool _isSameDatetime(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  Future<void> addEntry(DateTime entryDt) async {
    removeEntry(entryDt, skipDbDelete: true);
    final index = lowerBound(
      _state,
      entryDt,
      compare: (a, b) => -a.compareTo(b),
    );
    final entriesCache = ref.read(cacheEntriesProvider);
    entriesCache.whenData((cachedEntries) {
      final matching = cachedEntries
          .where((cacheValue) => cacheValue.createdDate == entryDt)
          .toList();
      if (matching.isEmpty) return;
      if (DateTime.now().difference(matching[0].lastCheckedAt) > cacheTtl) {
        (() async {
          final entry = await ref
              .read(workerManagerProvider)
              .updateStaleEntry(
                entryDt,
                ref.read(folderUriProvider).toString(),
              );
          if (entry != null) {
            final database = ref.read(appDatabaseProvider);
            final entryCacheData = cacheEntryFromEntry(entry);
            database
                .into(database.entriesCache)
                .insertOnConflictUpdate(entryCacheData);
          }
        })();
      }
    });
    _state.insert(index, entryDt);
    state = AsyncData(_state);
  }

  void removeEntry(DateTime entryDt, {bool skipDbDelete = false}) {
    _state = _state
        .where((stateEntryDt) => !_isSameDatetime(entryDt, stateEntryDt))
        .toList();
    state = AsyncData(_state);
  }

  Future<DateTime> newEntry() async {
    var dt = DateTime.now().copyWith(second: 0, millisecond: 0, microsecond: 0);

    while (_state.any((entryDt) => entryDt.isAtSameMomentAs(dt))) {
      dt = dt.copyWith(minute: dt.minute + 1);
    }

    final rootFolder = ref.read(folderUriProvider);
    final path = pathFromDatetime(dt);
    await writeFileString(rootFolder.toString(), path, "", "text/markdown");

    return dt;
  }

  Future<void> fullReload() async {
    try {
      logger.i("Doing expensive full entry reload.");
      final rootFolder = ref.read(folderUriProvider).toString();

      final saf = ref.read(safProvider);

      final yearDirs = (await saf.list(rootFolder))
          .where((file) => file.isDir && int.tryParse(file.name) != null)
          .toList()
          .sorted((a, b) => int.parse(b.name) - int.parse(a.name));

      for (final year in yearDirs) {
        final yearDt = DateFormat.y().tryParse(year.name);
        if (yearDt == null) {
          logger.w("Skipping ${year.name} because it is not a year.");
          continue;
        }

        final monthDirs = (await saf.list(year.uri))
            .where((file) => file.isDir && int.tryParse(file.name) != null)
            .toList()
            .sorted((a, b) => int.parse(b.name) - int.parse(a.name));

        for (final month in monthDirs) {
          final monthDt = DateFormat.M().tryParse(month.name);
          if (monthDt == null) continue;

          final dayDirs = (await saf.list(month.uri))
              .where((file) => file.isDir && int.tryParse(file.name) != null)
              .toList()
              .sorted((a, b) => int.parse(b.name) - int.parse(a.name));

          for (final day in dayDirs) {
            final dayDt = DateFormat.d().tryParse(day.name);
            if (dayDt == null) continue;

            final files = await saf.list(day.uri);
            for (final file in files) {
              if (file.name.length != 7) continue;

              final timeString = file.name.substring(0, 4);
              final time = DateFormat("HH:mm").tryParse(
                "${timeString.substring(0, 2)}:${timeString.substring(2)}",
              );
              if (time == null) continue;

              final datetime = yearDt.copyWith(
                month: monthDt.month,
                day: dayDt.day,
                hour: time.hour,
                minute: time.minute,
              );

              addEntry(datetime);
            }
          }
        }
      }
      state = AsyncData(_state);
    } catch (err, trace) {
      state = AsyncError(err, trace);
    }
  }
}
