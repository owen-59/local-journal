import "dart:convert";
import "dart:typed_data";

import "package:journal/logger.dart";
import "package:saf/saf.dart";
import "package:saf_stream/saf_stream.dart";
import "package:saf_stream/saf_stream_platform_interface.dart";

/// Returns the path of an entry from [datetime] as [List<String>].
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

/// Returns the path of the folder that an entry from [datetime] would
/// be stored as [List<String>].
List<String> parentPathFromDatetime(DateTime datetime) {
  return [
    datetime.year.toString().padLeft(4, "0"),
    datetime.month.toString().padLeft(2, "0"),
    datetime.day.toString().padLeft(2, "0"),
  ];
}

/// Writes a file at [path] inside [rootFolder], with content [content]
/// and mime type [mime].
///
/// Wrapper over [writeFileBytes] that encodes [content] as utf8.
Future<SafNewFile> writeFileString(
  String rootFolder,
  List<String> path,
  String content,
  String mime,
  Saf saf,
  SafStream safStream,
) async {
  return await writeFileBytes(
    rootFolder,
    path,
    utf8.encode(content),
    mime,
    saf,
    safStream,
  );
}

/// Writes a file at [path] inside [rootFolder], with content [bytes]
/// and mime type [mime].
///
/// Creates parent directories as neccessary.
Future<SafNewFile> writeFileBytes(
  String rootFolder,
  List<String> path,
  Uint8List bytes,
  String mime,
  Saf saf,
  SafStream safStream,
) async {
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
      bytes,
      overwrite: true,
      append: false,
    );
  } catch (err) {
    logger.e("While writing file: $err");
    rethrow;
  }
}

/// Reads a file at [path] inside [rootFolder] as a [String].
/// Returns `null` if there was an error reading the file.
///
/// Wrapper around [readFileBytes] that decodes the bytes as utf8.
Future<String?> readFile(
  String rootFolder,
  List<String> path,
  Saf saf,
  SafStream safStream,
) async {
  final fileBytes = await readFileBytes(rootFolder, path, saf, safStream);
  return fileBytes == null ? null : utf8.decode(fileBytes);
}

/// Reads a file at [path] inside [rootFolder] as a [Uint8List].
/// Returns `null` if there was an error reading the file.
Future<Uint8List?> readFileBytes(
  String rootFolder,
  List<String> path,
  Saf saf,
  SafStream safStream,
) async {
  final fileSafDocument = await saf.child(rootFolder, path);
  if (fileSafDocument == null) return null;

  try {
    return await safStream.readFileBytes(fileSafDocument.uri);
  } catch (err) {
    logger.w("Failed reading an entry at ${fileSafDocument.uri}.");
    return null;
  }
}

/// Deletes a file at [path] inside [rootFolder].
/// If the file doesn't exist, no error is thrown, but is logged.
Future<void> deleteFile(String rootFolder, List<String> path, Saf saf) async {
  final fileDoc = await saf.child(rootFolder, path);
  if (fileDoc == null) {
    logger.w("Tried to delete a non existent file at $path");
    return;
  }
  await saf.delete(fileDoc.uri);
}

/// Copies a local file at [srcPath] to [destPath] inside [rootFolder]
/// with mime type [mime].
/// Creates directories if neccessary.
Future<SafDocumentFile> copyLocalFile(
  String rootFolder,
  String srcPath,
  List<String> destPath,
  String mime,
  Saf saf,
) async {
  final deepestDir = await saf.mkdirp(
    rootFolder,
    destPath.sublist(0, destPath.length - 1),
  );
  return await saf.pasteLocalFile(
    srcPath,
    deepestDir.uri,
    destPath.last,
    mime,
    overwrite: true,
  );
}

/// Moves a file from [srcPath] to [destDirPath] within [rootFolder].
/// If [srcPath] does not exist, `null` is returned.
Future<SafDocumentFile?> moveFile(
  String rootFolder,
  List<String> srcPath,
  List<String> destDirPath,
  Saf saf,
) async {
  final deepestDir = await saf.mkdirp(rootFolder, destDirPath);

  final srcUri = await saf.child(rootFolder, srcPath);
  if (srcUri == null) return null;

  return await saf.moveTo(srcUri.uri, deepestDir.uri);
}
