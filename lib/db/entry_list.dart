import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
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
  @override
  Stream<List<Entry>> build() async* {
    logger.i("Loading entries.");
    final folderUri = ref.watch(folderUriProvider);
    final saf = Saf();
    final dirContents = saf
        .walk(ref.watch(folderUriProvider).toString())
        .map((walkEntry) => walkEntry.file)
        .where((file) => !file.isDir);

    final safStream = SafStream();

    var readEntries = <Entry>[];

    await for (var file in dirContents) {
      final path = getRelativePath(folderUri, Uri.parse(file.uri));
      final time = getTimeFromPath(path);
      if (time == null) continue;
      final fileBytes = await safStream.readFileBytes(file.uri);
      final fileContent = utf8.decode(fileBytes);
      final entry = Entry.fromContent(fileContent, time);

      int index = binarySearch(readEntries, entry);
      if (index < 0) index = -index - 1;
      readEntries.insert(index, entry);
      readEntries = [...readEntries];
      yield readEntries;
    }

    yield readEntries;
  }
}
