import 'package:journal/utils/location.dart';
import 'package:nominatim_flutter/model/request/request.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "osm_search.g.dart";

@riverpod
Future<List<Location>> osmSearch(Ref ref, String name) async {
  if (name == "") return [];
  final searchRequest = SearchRequest(query: name, limit: 3);

  final results = await NominatimFlutter.instance.search(
    searchRequest: searchRequest,
  );

  return results
      .map((result) {
        final latStr = result.lat;
        final lonStr = result.lon;

        final lat = latStr is String ? double.tryParse(latStr) : null;
        final lon = lonStr is String ? double.tryParse(lonStr) : null;

        if (lat == null || lon == null) return null;
        return Location(
          latitude: lat,
          longitude: lon,
          name: result.name?.isNotEmpty ?? false ? result.name : null,
          displayName: result.displayName?.isNotEmpty ?? false
              ? result.displayName
              : null,
        );
      })
      .nonNulls
      .toList();
}
