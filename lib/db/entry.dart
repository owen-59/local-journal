import 'dart:convert';

import 'package:journal/db/resolve_path.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saf_stream/saf_stream.dart';

part "entry.g.dart";

@riverpod
Future<Entry> entry(Ref ref, String datetimeString) async {
  logger.i("Loading entry $datetimeString");
  final datetime = DateTime.tryParse(datetimeString);
  if (datetime == null) {
    logger.w("Tried to load an entry with an invalid datetime.");
    throw Exception("Not a valid entry identifier.");
  }
  final path =
      "${datetime.year.toString().padLeft(4, "0")}/${datetime.month.toString().padLeft(2, "0")}/${datetime.day.toString().padLeft(2, "0")}/${datetime.hour.toString().padLeft(2, "0")}${datetime.minute.toString().padLeft(2, "0")}.md";
  final fullUri = await resolvePath(ref.watch(folderUriProvider).toString(), path);
  if (fullUri == null) {
    logger.w("Couldn't parse the entry file path from the datetime. (Entry file may not exist.)");
    throw Exception("Couldn't find the entry.");
  }

  final safStream = SafStream();
  try {
    final fileBytes = await safStream.readFileBytes(fullUri.toString());
    final fileContent = utf8.decode(fileBytes);
    final entry = Entry(
      body: fileContent,
      filePath: path,
      datetime: datetime,
    );

    return entry;
  } catch (err) {
    logger.w("Couldn't load the entry from the entry file.");
    throw Exception("Couldn't find the entry.");
  }
}
