import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:isolate_kit/isolate_kit.dart';
import 'package:journal/logger.dart';
import 'package:journal/providers/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';

class CacheImagePayload {
  final Uint8List bytes;
  final QualityLevel quality;
  final RootIsolateToken token;

  CacheImagePayload({
    required this.bytes,
    required this.quality,
    required this.token,
  });
}

class CacheImageTask extends IsolateTask<CacheImagePayload, File?> {
  final CacheImagePayload data;
  CacheImageTask(this.data);

  @override
  get command => (data);

  @override
  get payload => {"data": data};

  @override
  get priority => TaskPriority.low;

  @override
  Future<File?> execute({
    void Function(TaskProgress)? sendProgress,
    CancellationToken? cancellationToken,
  }) async {
    try {
      BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);
      final uuid = Uuid();
      final fileName = uuid.v4();
      final cacheDirectory = await getApplicationCacheDirectory();
      final cacheFile = File(join(cacheDirectory.path, "images", fileName));

      final bytes = data.quality == QualityLevel.full
          ? data.bytes
          : await FlutterImageCompress.compressWithList(
              data.bytes,
              minWidth: 200,
              minHeight: 200,
              quality: 85,
              format: CompressFormat.jpeg,
            );
      await cacheFile.create(recursive: true);
      return await cacheFile.writeAsBytes(bytes);
    } catch (err, stacktrace) {
      logger.e("Error when caching an image: $err", stackTrace: stacktrace);
      return null;
    }
  }
}
