import 'package:journal/utils/file.dart';
import 'package:journal/utils/frontmatter.dart';

class Entry implements Comparable<Entry> {
  final String body;
  final DateTime datetime;
  final List<String> tags;

  Entry({required this.body, required this.datetime, required this.tags});

  @override
  int compareTo(Entry other) {
    return datetime.compareTo(other.datetime);
  }

  Entry copyWith({String? body, DateTime? datetime, List<String>? tags}) {
    return Entry(
      body: body ?? this.body,
      datetime: datetime ?? this.datetime,
      tags: tags ?? this.tags,
    );
  }

  Future<void> write(String rootFolder) async {
    final path = pathFromDatetime(datetime);
    final content = addMdFrontmatter(body, {"tags": tags.join(",")});

    await writeFile(rootFolder, path, content);
  }

  Future<void> delete(String rootFolder) async {
    final path = pathFromDatetime(datetime);
    await deleteFile(rootFolder, path);
  }

  static Future<Entry?> read(String datetimeString, String rootFolder) async {
    final datetime = DateTime.tryParse(datetimeString);
    if (datetime == null) return null;

    final path = pathFromDatetime(datetime);
    final content = await readFile(rootFolder.toString(), path);
    if (content == null) return null;

    return Entry.fromContent(content, datetime);
  }

  static Entry fromContent(String fileContent, DateTime datetime) {
    final (body, frontmatter) = parseMdFrontmatter(fileContent);
    final tagsString = frontmatter["tags"] ?? "";
    final tags = tagsString
        .split(",")
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    return Entry(body: body, datetime: datetime, tags: tags);
  }
}
