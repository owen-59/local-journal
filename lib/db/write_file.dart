import 'dart:convert';

import 'package:saf/saf.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_stream/saf_stream_platform_interface.dart';

List<String> pathFromDatetime(DateTime datetime) {
    return [
      datetime.year.toString().padLeft(4, "0"),
      datetime.month.toString().padLeft(2, "0"),
      datetime.day.toString().padLeft(2,"0"),
      datetime.hour.toString().padLeft(2, "0") +
          // ignore: prefer_interpolation_to_compose_strings
          datetime.minute.toString().padLeft(2, "0") + ".md",
    ];
}

Future<SafNewFile> writeFile(
  String rootFolder,
  List<String> path,
  String content,
) async {
  final saf = Saf();
  final safStream = SafStream();

  final deepestDir = await saf.mkdirp(
    rootFolder,
    path.sublist(0, path.length - 1),
  );

  final currentFile = await saf.child(deepestDir.uri, [path.last]);
  if (currentFile != null) {
    await saf.delete(currentFile.uri);
  } 

  return await safStream.writeFileBytes(
    deepestDir.uri,
    path.last,
    "text/markdown",
    utf8.encode(content),
    overwrite: true,
    append: false,
  );
}
