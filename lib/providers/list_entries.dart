import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/main.dart';
import 'package:journal/types.dart';

final Provider<List<Entry>> listEntriesProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  db.getItems();
  return [
    Entry(body: "Body 1", date: DateTime(2026, 1, 1)),
    Entry(body: "Body 2", date: DateTime(2026, 6, 1)),
  ];
});
