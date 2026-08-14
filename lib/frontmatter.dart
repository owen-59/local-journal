import 'package:journal/logger.dart';

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

(String, Map<String,String>) parseMdFrontmatter(String text) {
  final lineStream = _getLinesSync(text);
  final lineRegex = RegExp(r'^(?<key>[a-zA-Z0-9_\-]+)\s*:\s*(?<value>.+)$');

  final iterator = lineStream.iterator;

  bool isFirst = true;
  Map<String, String> yamlData = {};
  while (iterator.moveNext()) {
    final line = iterator.current;
    if (isFirst) {
      if (!line.startsWith("---")) {
        return (text, {}); 
      }
      isFirst = false;
    } else {
      if (line.startsWith("---")) {
        break;
      }
      final match = lineRegex.firstMatch(line);
      if (match == null) {
        logger.w("Encountered incorrect yaml line: $line");
      } else {
        final key = match.namedGroup("key")!;
        final value = match.namedGroup("value")!;

        yamlData[key] = value;
        match.namedGroup("key");
      }
    }
  }
  
  var remainingLines = [];
  while (iterator.moveNext()) {
    remainingLines.add(iterator.current);
  }

  final body = remainingLines.join("\n");
  return (body, yamlData); 
}

String addMdFrontmatter(String body, Map<String, String> frontmatter) {
  var output = "---\n";

  for (var MapEntry(:key, :value) in frontmatter.entries) {
    output += "$key: $value\n";  
  }
  output += "---\n$body";
  return output;
}
