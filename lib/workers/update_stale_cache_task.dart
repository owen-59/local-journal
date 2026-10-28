import 'package:flutter/services.dart';
import 'package:isolate_kit/isolate_kit.dart';
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
