import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/database.dart';
import 'package:journal/main.dart';

final searchProvider = FutureProvider.autoDispose
    .family<List<EntriesCacheData>, String>((ref, String query) async {
      if (query.trim().isEmpty) return [];
      final db = ref.watch(appDatabaseProvider);

      final results = await (db.select(
        db.entriesCache,
      )..where((u) => u.body.like("%$query%"))).get();
      return results;
    });
