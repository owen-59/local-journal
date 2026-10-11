import 'package:dump_yaml/dump_yaml.dart';
import 'package:journal/logger.dart';
import 'package:yaml/yaml.dart';

Iterable<String> _getLinesSync(String text) sync* {
  final RegExp lineRegExp = RegExp(r'(.*)\r?\n|(.+)$');
  final matches = lineRegExp.allMatches(text);

  for (final match in matches) {
    final line = match.group(1) ?? match.group(2);
    if (line != null) {
      yield line;
    }
  }
}


(String, YamlMap?) parseMdFrontmatter(String text) {
  final lineStream = _getLinesSync(text);
  final iterator = lineStream.iterator;

  iterator.moveNext();
  if (iterator.current != "---") {
    logger.w("No YAML frontmatter found.");
    return (text, null);
  }

  String yamlText = "";

  while (iterator.moveNext()) {
    final line = iterator.current;
    if (line == "---") {
      break;
    }
    yamlText += "$line\n";
  }

  var yamlData = loadYaml(yamlText);
  if (yamlData is! YamlMap) {
    logger.w("$yamlText did not load into a YamlMap, loaded as $yamlData.");
    yamlData = YamlMap(sourceUrl: {});
  }

  var remainingLines = [];
  while (iterator.moveNext()) {
    remainingLines.add(iterator.current);
  }

  final body = remainingLines.join("\n");

  return (body, yamlData);
}

String addMdFrontmatter(String body, Map frontmatter) {
  var output = "---\n";

  output += dumpAsYaml(frontmatter);
  output += "\n---\n$body";

  return output;
}

