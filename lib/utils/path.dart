DateTime? getTimeFromPath(String input) {
  final regExp = RegExp(r'^(\d{4})/(\d{2})/(\d{2})/(\d{2})(\d{2})\.md$');
  final match = regExp.firstMatch(input);

  if (match == null) return null;

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final hour = int.parse(match.group(4)!);
  final minute = int.parse(match.group(5)!);

  return DateTime(year, month, day, hour, minute);
}

String getRelativePath(Uri folderUri, Uri fileUri) {
  final rootId = Uri.decodeComponent(folderUri.pathSegments.last);

  final fileSegments = fileUri.pathSegments;
  final documentIndex = fileSegments.indexOf('document');

  if (documentIndex == -1 || documentIndex + 1 >= fileSegments.length) {
    throw StateError('Invalid SAF document URI: $fileUri');
  }

  final fileId = Uri.decodeComponent(fileSegments[documentIndex + 1]);

  if (!fileId.startsWith('$rootId/')) {
    throw StateError('File is not inside selected folder');
  }

  return fileId.substring(rootId.length + 1);
}
