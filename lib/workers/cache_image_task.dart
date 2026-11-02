import "dart:io";

import "package:flutter/services.dart";
import "package:flutter_image_compress/flutter_image_compress.dart";
import "package:isolate_kit/isolate_kit.dart";
import "package:journal/logger.dart";
import "package:journal/providers/image.dart";
import "package:path_provider/path_provider.dart";
import "package:path/path.dart";

class CacheImagePayload {
  final String name;
  final DateTime entryDt;
  final Uint8List bytes;
  final QualityLevel quality;
  final RootIsolateToken token;

  CacheImagePayload({
    required this.name,
    required this.entryDt,
    required this.bytes,
    required this.quality,
    required this.token,
  });
}

class CacheImageTask extends IsolateTask<CacheImagePayload, Uint8List?> {
  final CacheImagePayload data;
  CacheImageTask(this.data);

  @override
  CacheImagePayload get command => (data);

  @override
  Map<String, CacheImagePayload> get payload => {"data": data};

  @override
  int get priority => TaskPriority.low;

  @override
  Future<Uint8List?> execute({
    void Function(TaskProgress)? sendProgress,
    CancellationToken? cancellationToken,
  }) async {
    try {
      BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);
      final fileName = "${data.entryDt}-${data.name}-${data.quality}.jpg";
      final cacheDirectory = await getApplicationCacheDirectory();
      final cacheFile = File(join(cacheDirectory.path, "images", fileName));

      final bytes = switch (data.quality) {
        QualityLevel.full => data.bytes,
        QualityLevel.thumbnailSmall =>
          await FlutterImageCompress.compressWithList(
            data.bytes,
            minWidth: 200,
            minHeight: 200,
            quality: 85,
            format: CompressFormat.jpeg,
          ),
        QualityLevel.thumbnailLarge =>
          await FlutterImageCompress.compressWithList(
            data.bytes,
            minWidth: 500,
            minHeight: 500,
            quality: 85,
            format: CompressFormat.jpeg,
          ),
      };
      await cacheFile.create(recursive: true);
      await cacheFile.writeAsBytes(bytes);
      return bytes;
    } catch (err, stacktrace) {
      logger.e("Error when caching an image: $err", stackTrace: stacktrace);
      return null;
    }
  }
}
