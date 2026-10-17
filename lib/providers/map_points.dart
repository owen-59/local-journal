import 'package:journal/providers/cache_entries.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "map_points.g.dart";

@riverpod
Future<List<Object>> mapPoints(Ref ref) async {
  final entries = await ref.watch(cacheEntriesProvider.future);
  final points = entries
      .where((entry) => entry.latitude != null && entry.longitude != null)
      .map(
        (entry) => {
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [entry.longitude, entry.latitude],
          },
        },
      )
      .toList();

  return points;
}
