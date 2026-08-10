import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/main.dart';
import 'package:journal/types.dart';
import 'package:saf/saf.dart';
import 'package:saf_stream/saf_stream.dart';

class Database {
  final Uri _folderUri;
  final Saf _saf;

  Database({required Uri folderUri, required Saf saf})
    : _folderUri = folderUri,
      _saf = saf;

  String _relativePath(Uri fileUri) {
    final rootId = Uri.decodeComponent(_folderUri.pathSegments.last);

    final fileSegments = fileUri.pathSegments;
    final documentIndex = fileSegments.indexOf('document');

    if (documentIndex == -1 || documentIndex + 1 >= fileSegments.length) {
      throw StateError('Invalid SAF document URI: $fileUri');
    }

    final fileId = Uri.decodeComponent(fileSegments[documentIndex + 1]);

    if (!fileId.startsWith('$rootId/')) {
      throw StateError('File is not inside selected folder');
    }

    return fileId.substring(rootId.length + 1);
  }

  Stream<List<Entry>> getItems() async* {
    final dirContents = _saf
        .walk(_folderUri.toString())
        .map((walkEntry) => walkEntry.file)
        .where((file) => !file.isDir);

    final safStream = SafStream();

    var readEntries = const <Entry>[];

    await for (var file in dirContents) {
      final fileBytes = await safStream.readFileBytes(file.uri);
      final fileContent = utf8.decode(fileBytes);
      final entry = Entry(
        body: fileContent,
        filePath: _relativePath(Uri.parse(file.uri)),
        date: DateTime.fromMillisecondsSinceEpoch(file.lastModified),
      );
      readEntries = [...readEntries, entry];
      yield readEntries;
    }
  }
}

final itemsProvider = StreamProvider<List<Entry>>((ref) async* {
  yield* ref.watch(databaseProvider).getItems();
});
