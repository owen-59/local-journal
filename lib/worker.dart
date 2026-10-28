import 'dart:io';

import 'package:flutter/services.dart';
import 'package:isolate_kit/isolate_kit.dart';
import 'package:journal/logger.dart';
import 'package:journal/models/entry.dart';
import 'package:journal/providers/image.dart';
import 'package:journal/workers/cache_image_task.dart';
import 'package:journal/workers/update_stale_cache_task.dart';

class WorkerManager {
  final IsolateTaskRegistry _registry = IsolateTaskRegistry()
    ..register<UpdateStaleCacheTask>(
      "UpdateStaleCacheTask",
      (payload, _) => UpdateStaleCacheTask(payload["data"]),
    )
    ..register<CacheImageTask>(
      "CacheImageTask",
      (payload, _) => CacheImageTask(payload["data"]),
    );

  late final IsolateKit _isolateKit = IsolateKit.create(
    usePool: true,
    taskRegistry: _registry,
  );

  Future<Entry?> updateStaleEntry(DateTime dt, String rootFolder) async {
    final rootToken = RootIsolateToken.instance;
    if (rootToken != null) {
      final payload = UpdateStaleCachePayload(
        dt: dt,
        rootFolder: rootFolder,
        token: rootToken,
      );
      final taskHandle = _isolateKit.runTask(UpdateStaleCacheTask(payload));
      final result = await taskHandle.future;
      return result;
    } else {
      logger.w(
        "RootIsolateToken.instance was null, skipped running UpdateStaleCacheTask.",
      );
      return null;
    }
  }

  Future<File?> runCacheImageTask(Uint8List bytes, QualityLevel quality) async {
    final rootToken = RootIsolateToken.instance;
    if (rootToken != null) {
      final payload = CacheImagePayload(
        bytes: bytes,
        quality: quality,
        token: rootToken,
      );
      final taskHandle = _isolateKit.runTask(CacheImageTask(payload));
      final result = await taskHandle.future;
      return result;
    } else {
      logger.w(
        "RootIsolateToken.instance was null, skipped running CacheImageTask.",
      );
      return null;
    }
  }
}
