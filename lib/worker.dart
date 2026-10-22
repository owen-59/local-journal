import 'package:flutter/services.dart';
import 'package:isolate_kit/isolate_kit.dart';
import 'package:journal/logger.dart';
import 'package:journal/models/entry.dart';

class UpdateStaleCachePayload {
  final DateTime dt;
  final String rootFolder;
  final RootIsolateToken token;

  UpdateStaleCachePayload({
    required this.dt,
    required this.rootFolder,
    required this.token,
  });
}

class UpdateStaleCacheTask
    extends IsolateTask<UpdateStaleCachePayload, Entry?> {
  final UpdateStaleCachePayload data;
  UpdateStaleCacheTask(this.data);

  @override
  UpdateStaleCachePayload get command => (data);

  @override
  Map<String, dynamic> get payload => {"data": data};

  @override
  int get priority => TaskPriority.low;

  @override
  Future<Entry?> execute({
    void Function(TaskProgress)? sendProgress,
    CancellationToken? cancellationToken,
  }) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);
    final entry = Entry.read(data.dt.toString(), data.rootFolder);
    return entry;
  }
}

class WorkerManager {
  final IsolateTaskRegistry _registry = IsolateTaskRegistry()
    ..register<UpdateStaleCacheTask>(
      "UpdateStaleCacheTask",
      (payload, _) => UpdateStaleCacheTask(payload["data"]),
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
}
