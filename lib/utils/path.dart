import "package:journal/utils/file.dart";

/// Matchs [input] with a regexp to extract the
/// year, month, day, hour and minute.
DateTime? getTimeFromPath(String input) {
  final regExp = RegExp(r"^(\d{4})/(\d{2})/(\d{2})/(\d{2})(\d{2})\.md$");
  final match = regExp.firstMatch(input);

  if (match == null) return null;

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final hour = int.parse(match.group(4)!);
  final minute = int.parse(match.group(5)!);

  return DateTime(year, month, day, hour, minute);
}

/// Returns the path of the image with [name] attached to the entry at [dt].
///
/// Equivalent to replacing the last segment of an entry path with [name].
List<String> getImagePath(DateTime dt, String name) {
  final entryPath = pathFromDatetime(dt);
  final imagePath = [...entryPath.sublist(0, entryPath.length - 1), name];
  return imagePath;
}
