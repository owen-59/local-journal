import 'package:journal/logger.dart';
import 'package:journal/utils/location.dart';
import 'package:yaml/yaml.dart';

List<R> dynamicYamlToList<R>(dynamic obj) {
  if (obj is! YamlList) {
    logger.w(
      "$obj is not YamlList, falling back to empty list, can't parse a List<$R>",
    );
    return [];
  }
  final list = obj.cast();
  return list.whereType<R>().toList();
}

Location? locationFromYaml(YamlMap map) {
  final coordsList = map["location"];
  final name = map["place_name"];

  if (coordsList != null && name != null) {
    if (coordsList is! YamlList) {
      logger.w("Coordinates were not a YamlList, was $coordsList");
      return null;
    }

    if (name is! String) {
      logger.w("Place name was not a String, was $name");
      return null;
    }

    final coords = dynamicYamlToList<num>(coordsList);
    if (coords.length != 2) {
      logger.w("Coordinates did not have a length of 2, was $coords");
      return null;
    }

    final lat = coords[0];
    final lon = coords[1];

    return Location(
      name: name,
      latitude: lat.toDouble(),
      longitude: lon.toDouble(),
    );
  }
  return null;
}
