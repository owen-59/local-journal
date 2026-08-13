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
