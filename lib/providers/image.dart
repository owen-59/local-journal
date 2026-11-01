import "dart:io";

import "package:flutter/services.dart";
import "package:journal/logger.dart";
import "package:journal/main.dart";
import "package:journal/utils/file.dart";
import "package:journal/utils/path.dart";
import "package:journal/workers/cache_image_task.dart";
import "package:path_provider/path_provider.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:path/path.dart" as path;

part "image.g.dart";

enum QualityLevel { full, thumbnailSmall, thumbnailLarge }

@riverpod
Future<Uint8List?> image(
  Ref ref,
  DateTime dt,
  String name,
  QualityLevel quality,
) async {
  final rootFolder = ref.watch(folderUriProvider).toString();
  final imagePath = getImagePath(dt, name);

  final cacheFileName = "$dt-$name-$quality.jpg";
  final cacheDirectory = await getApplicationCacheDirectory();
  final cacheFile = File(
    path.join(cacheDirectory.path, "images", cacheFileName),
  );

  try {
    final bytes = await cacheFile.readAsBytes();
    logger.i("Read cache for $cacheFile");
    return bytes;
  } on PathNotFoundException catch (_) {
  } catch (err) {
    logger.e("Error when reading cached file at $cacheFile: $err");
  }

  final bytes = await readFileBytes(rootFolder, imagePath);
  if (bytes == null) return null;

  () async {
    final keepAliveLink = ref.keepAlive();
    try {
      await ref
          .read(workerManagerProvider)
          .runCacheImageTask(
            CacheImagePayload(
              name: name,
              entryDt: dt,
              bytes: bytes,
              quality: quality,
              token: RootIsolateToken.instance!,
            ),
          );
      ref.invalidateSelf();
    } catch (err) {
      logger.e("Error when updating image cache from image provider: $err");
    } finally {
      keepAliveLink.close();
    }
  }();

  return bytes;
}
