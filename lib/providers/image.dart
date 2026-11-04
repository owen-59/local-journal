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
class ImageNotifier extends _$ImageNotifier {
  @override
  Future<Uint8List?> build(
    DateTime dt,
    String name,
    QualityLevel quality,
  ) async {
    if (quality != QualityLevel.full) {
      final cachedBytes = await loadCache();
      if (cachedBytes != null) return cachedBytes;
    }

    final bytes = await loadOriginal();
    return bytes;
  }

  Future<Uint8List?> loadOriginal() async {
    final rootFolder = ref.watch(folderUriProvider).toString();
    final saf = ref.watch(safProvider);
    final safStream = ref.watch(safStreamProvider);
    final imagePath = getImagePath(dt, name);

    final bytes = await readFileBytes(rootFolder, imagePath, saf, safStream);
    if (bytes == null || quality == QualityLevel.full) return bytes;

    createCache(bytes);
    return bytes;
  }

  Future<Uint8List?> loadCache() async {
    final cacheFileName = "$dt-$name-$quality.jpg";
    final cacheDirectory = await getApplicationCacheDirectory();
    final cacheFile = File(
      path.join(cacheDirectory.path, "images", cacheFileName),
    );

    try {
      return await cacheFile.readAsBytes();
    } on PathNotFoundException catch (_) {
    } catch (err) {
      logger.e("Error when reading cached file at $cacheFile: $err");
    }
    return null;
  }

  Future<void> createCache(Uint8List bytes) async {
    if (quality != QualityLevel.full) {
      final keepAliveLink = ref.keepAlive();
      try {
        final compressedBytes = await ref
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
        if (compressedBytes != null) {
          state = AsyncData(compressedBytes);
        }
      } catch (err) {
        logger.e("Error when updating image cache from image provider: $err");
      } finally {
        keepAliveLink.close();
      }
    } else {
      logger.w(
        "Tried to create cache of $dt/$name, but quality was full quality.",
      );
    }
  }
}
