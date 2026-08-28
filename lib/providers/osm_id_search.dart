import 'package:nominatim_flutter/model/request/request.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "osm_id_search.g.dart";

@riverpod
Future<NominatimResponse?> osmIdSearch(Ref ref, String osmId) async {
  final lookupRequest = LookupRequest(
    osmIds: osmId,
    addressDetails: true,
    nameDetails: true,
  );

  final lookupResult = await NominatimFlutter.instance.lookup(
    lookupRequest: lookupRequest,
  );

  return lookupResult.elementAtOrNull(0);
}
