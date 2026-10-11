import 'package:journal/logger.dart';
import 'package:yaml/yaml.dart';

List<R> dynamicYamlToList<R>(dynamic obj) {
  if (obj is! YamlList) {
    logger.w("$obj is not YamlList, falling back to empty list, can't parse a List<$R>");
    return [];
  }
  final list = obj.cast();
  return list
    .whereType<R>()
    .toList();
}
