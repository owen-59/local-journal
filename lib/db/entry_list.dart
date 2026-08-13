import 'dart:convert';
import 'dart:async';

import 'package:journal/db/get_relative_path.dart';
import 'package:journal/db/get_time_from_path.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saf/saf.dart';
import 'package:saf_stream/saf_stream.dart';

part "entry_list.g.dart";

@riverpod
class EntryList extends _$EntryList {
  final _controller = StreamController<List<Entry>>.broadcast();

  @override
  Stream<List<Entry>> build() async* {
    ref.onDispose(() => _controller.close());

    logger.i("Loading entries.");
    final folderUri = ref.watch(folderUriProvider);
    final saf = Saf();
    final dirContents = saf
        .walk(ref.watch(folderUriProvider).toString())
        .map((walkEntry) => walkEntry.file)
        .where((file) => !file.isDir);

    final safStream = SafStream();

    var readEntries = const <Entry>[];

    await for (var file in dirContents) {
      final path = getRelativePath(folderUri, Uri.parse(file.uri));
      final time = getTimeFromPath(path);
      if (time == null) continue;
      final fileBytes = await safStream.readFileBytes(file.uri);
      final fileContent = utf8.decode(fileBytes);
      final entry = Entry(body: fileContent, datetime: time);
      readEntries = [...readEntries, entry];
      yield readEntries;
    }

    yield* _controller.stream;
  }
}
