import 'package:exif_reader/exif_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

Future<DateTime?> datetimeFromExif(Uint8List bytes) async {
  final exif = await readExifFromBytes(bytes);

  final dtFormat = DateFormat("yyyy:MM:dd HH:mm:ss");
  final imageDtString = exif.tags["EXIF DateTimeOriginal"]?.printable;
  final imageDt = imageDtString != null
      ? dtFormat.tryParse(imageDtString)
      : null;

  return imageDt;
}
