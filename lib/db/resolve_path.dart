import 'package:saf/saf.dart';

Future<String?> resolvePath(String folderUri, String relativePath) async {
  var currentUri = folderUri.toString();
  final saf = Saf();

  for (final component in relativePath.split('/')) {
    final children = await saf.list(currentUri);

    final child = children.firstWhere(
      (file) => file.name == component,
      orElse: () => throw Exception('Could not find $component in $currentUri'),
    );

    currentUri = child.uri;
  }

  return currentUri;
}
