import 'package:journal/utils/location.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:nominatim_flutter/model/request/reverse_request.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "osm_reverse_geocode.g.dart";

@riverpod
Future<Location?> osmReverseGeocode(Ref ref, LatLng? latlng) async {
  if (latlng == null) return null;
  final reverseRequest = ReverseRequest(
    lat: latlng.latitude,
    lon: latlng.longitude,
  );

  final reverseResult = await NominatimFlutter.instance.reverse(
    reverseRequest: reverseRequest,
  );

  return Location(
    latitude: latlng.latitude,
    longitude: latlng.longitude,
    name: reverseResult.name?.isNotEmpty ?? false ? reverseResult.name : null,
    displayName: reverseResult.displayName?.isNotEmpty ?? false
        ? reverseResult.displayName
        : null,
  );
}
