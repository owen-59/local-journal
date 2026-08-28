import 'package:nominatim_flutter/model/request/request.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "osm_search.g.dart";

@riverpod
Future<List<NominatimResponse>> osmSearch(Ref ref, String name) async {
  if (name == "") return [];
  final searchRequest = SearchRequest(
    query: name,
    limit: 3,
    addressDetails: true,
  );

  return await NominatimFlutter.instance.search(searchRequest: searchRequest);
}
