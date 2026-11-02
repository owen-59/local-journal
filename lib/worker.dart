import "package:flutter/services.dart";
import "package:isolate_kit/isolate_kit.dart";
import "package:journal/models/entry.dart";
import "package:journal/workers/cache_image_task.dart";
import "package:journal/workers/update_stale_cache_task.dart";

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

  Future<Entry?> updateStaleEntry(UpdateStaleCachePayload payload) async {
    final taskHandle = _isolateKit.runTask(UpdateStaleCacheTask(payload));
    final result = await taskHandle.future;
    return result;
  }

  Future<Uint8List?> runCacheImageTask(CacheImagePayload payload) async {
    final taskHandle = _isolateKit.runTask(CacheImageTask(payload));
    final result = await taskHandle.future;
    return result;
  }
}
