import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:journal/database.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/utils/file.dart';
import 'package:journal/utils/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image.g.dart';

enum QualityLevel { full, thumbnail }

@riverpod
Future<Uint8List?> image(
  Ref ref,
  DateTime dt,
  String name,
  QualityLevel quality,
) async {
  final rootFolder = ref.watch(folderUriProvider).toString();
  final database = ref.watch(appDatabaseProvider);

  final imagePath = getImagePath(dt, name);

  final cachedImage = await (database.select(
    database.imageCache,
  )..where((a) => a.sourcePath.equalsValue(imagePath))).getSingleOrNull();
  if (cachedImage != null) {
    final destinationPath = cachedImage.destinationPath;
    final cacheFile = File(destinationPath);

    if (await cacheFile.exists()) {
      try {
        final bytes = await cacheFile.readAsBytes();
        return bytes;
      } catch (err) {
        logger.e("Error when reading cached image at $destinationPath: $err");
      }
    } else {
      logger.w(
        "Cached file at $destinationPath did not exist. Removing from database.",
      );
    }
  }

  var bytes = await readFileBytes(rootFolder, imagePath);
  if (bytes == null) return null;

  () async {
    final keepAliveLink = ref.keepAlive();
    try {
      final cacheFile = await ref
          .read(workerManagerProvider)
          .runCacheImageTask(bytes, quality);
      if (cacheFile != null) {
        final database = ref.read(appDatabaseProvider);
        database
            .into(database.imageCache)
            .insertOnConflictUpdate(
              ImageCacheCompanion.insert(
                sourcePath: imagePath,
                destinationPath: cacheFile.path,
                qualityLevel: quality,
              ),
            );
      }
    } catch (err) {
      logger.e("Error when updating image cache from image provider: $err");
    } finally {
      keepAliveLink.close();
    }
  }();

  return bytes;
}
