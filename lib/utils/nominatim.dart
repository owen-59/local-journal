import 'package:nominatim_flutter/model/response/response.dart';

String? osmIdFromNomatinimObj(NominatimResponse obj) {
  final typeCode = switch (obj.osmType) {
    "relation" => "R",
    "way" => "W",
    _ => "N",
  };

  return "$typeCode${obj.osmId}";
}
