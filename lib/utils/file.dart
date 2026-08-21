import 'dart:convert';
import 'dart:typed_data';

import 'package:journal/logger.dart';
import 'package:saf/saf.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_stream/saf_stream_platform_interface.dart';

List<String> pathFromDatetime(DateTime datetime) {
  return [
    datetime.year.toString().padLeft(4, "0"),
    datetime.month.toString().padLeft(2, "0"),
    datetime.day.toString().padLeft(2, "0"),
    datetime.hour.toString().padLeft(2, "0") +
        // ignore: prefer_interpolation_to_compose_strings
        datetime.minute.toString().padLeft(2, "0") +
        ".md",
  ];
}

List<String> parentPathFromDatetime(DateTime datetime) {
  return [
    datetime.year.toString().padLeft(4, "0"),
    datetime.month.toString().padLeft(2, "0"),
    datetime.day.toString().padLeft(2, "0"),
  ];
}

Future<SafNewFile> writeFileString(
  String rootFolder,
  List<String> path,
  String content,
  String mime,
) async {
  return await writeFileBytes(rootFolder, path, utf8.encode(content), mime);
}

Future<SafNewFile> writeFileBytes(
  String rootFolder,
  List<String> path,
  Uint8List content,
  String mime,
) async {
  final saf = Saf();
  final safStream = SafStream();

  late final SafDocumentFile deepestDir;

  try {
    deepestDir = await saf.mkdirp(rootFolder, path.sublist(0, path.length - 1));
  } catch (err) {
    logger.e("Error while getting the deepest directory: $err");
    rethrow;
  }

  try {
    final currentFile = await saf.child(deepestDir.uri, [path.last]);
    if (currentFile != null) {
      await saf.delete(currentFile.uri);
    }
  } catch (err) {
    logger.e("While running saf.child: $err");
    rethrow;
  }

  try {
    return await safStream.writeFileBytes(
      deepestDir.uri,
      path.last,
      mime,
      content,
      overwrite: true,
      append: false,
    );
  } catch (err) {
    logger.e("While writing file: $err");
    rethrow;
  }
}

Future<String?> readFile(String rootFolder, List<String> path) async {
  final fileBytes = await readFileBytes(rootFolder, path);
  return fileBytes == null ? null : utf8.decode(fileBytes);
}

Future<Uint8List?> readFileBytes(String rootFolder, List<String> path) async {
  final saf = Saf();
  final safStream = SafStream();

  final fileSafDocument = await saf.child(rootFolder, path);
  if (fileSafDocument == null) return null;

  try {
    return await safStream.readFileBytes(fileSafDocument.uri);
  } catch (err) {
    logger.w("Failed reading an entry at ${fileSafDocument.uri}.");
    return null;
  }
}

Future<void> deleteFile(String rootFolder, List<String> path) async {
  final saf = Saf();

  final fileDoc = await saf.child(rootFolder, path);
  if (fileDoc == null) {
    logger.w("Tried to delete a non existent file at $path");
    return;
  }
  await saf.delete(fileDoc.uri);
}

Future<SafDocumentFile> copyLocalFile(
  String rootFolder,
  String srcPath,
  List<String> destPath,
  String mime,
) async {
  final saf = Saf();

  final deepestDir = await saf.mkdirp(
    rootFolder,
    destPath.sublist(0, destPath.length - 1),
  );
  // await saf.child(deepestDir.uri, [destPath.last]);
  return await saf.pasteLocalFile(
    srcPath,
    deepestDir.uri,
    destPath.last,
    mime,
    overwrite: true,
  );
}

Future<SafDocumentFile?> moveFile(
  String rootFolder,
  List<String> srcPath,
  List<String> destDirPath,
) async {
  final saf = Saf();

  final deepestDir = await saf.mkdirp(rootFolder, destDirPath);

  final srcUri = await saf.child(rootFolder, srcPath);
  if (srcUri == null) return null;

  return await saf.moveTo(srcUri.uri, deepestDir.uri);
}
