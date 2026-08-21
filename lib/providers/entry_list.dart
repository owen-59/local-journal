import 'dart:convert';
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:journal/entry.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/utils/file.dart';
import 'package:journal/utils/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saf/saf.dart';
import 'package:saf_stream/saf_stream.dart';

part "entry_list.g.dart";

@Riverpod(keepAlive: true)
class EntryList extends _$EntryList {
  final _controller = StreamController<List<Entry>>.broadcast();
  var _state = <Entry>[];

  @override
  Stream<List<Entry>> build() async* {
    ref.onDispose(() {
      logger.w("Closing controller.");
      _controller.close();
    });

    fullReload();

    yield* _controller.stream;
  }

  bool _isSameDatetime(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  void addEntry(Entry entry, {bool shouldYield = true}) {
    removeEntry(entry);
    logger.d("Adding entry at ${entry.datetime} to list.");
    final index = lowerBound(_state, entry, compare: (a, b) => -a.compareTo(b));
    _state.insert(index, entry);
    if (shouldYield) _controller.add(_state);
  }

  void removeEntry(Entry entry) {
    final initialLength = _state.length;
    _state = _state
        .where(
          (stateEntry) => !_isSameDatetime(entry.datetime, stateEntry.datetime),
        )
        .toList();
    _controller.add(_state);
    logger.d(
      "Removing entry at ${entry.datetime} from list, deleted ${_state.length - initialLength}",
    );
  }

  Future<DateTime> newEntry() async {
    var dt = DateTime.now().copyWith(second: 0, millisecond: 0, microsecond: 0);

    while (_state.any((entry) => entry.datetime.isAtSameMomentAs(dt))) {
      dt = dt.copyWith(minute: dt.minute + 1);
    }

    final rootFolder = ref.read(folderUriProvider);
    final path = pathFromDatetime(dt);
    await writeFileString(rootFolder.toString(), path, "", "text/markdown");

    return dt;
  }

  Future<void> fullReload() async {
    logger.i("Doing expensive full entry reload.");
    final folderUri = ref.watch(folderUriProvider);
    final saf = Saf();
    final dirContents = saf
        .walk(ref.watch(folderUriProvider).toString())
        .map((walkEntry) => walkEntry.file)
        .where((file) => !file.isDir);

    final safStream = SafStream();

    await for (var file in dirContents) {
      final path = getRelativePath(folderUri, Uri.parse(file.uri));
      final time = getTimeFromPath(path);
      if (time == null) continue;
      final fileBytes = await safStream.readFileBytes(file.uri);
      final fileContent = utf8.decode(fileBytes);
      final entry = Entry.fromContent(fileContent, time);

      addEntry(entry, shouldYield: false);
      _controller.add(_state);
    }
    _controller.add(_state);
  }
}
