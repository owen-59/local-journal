import 'package:flutter/services.dart';
import 'package:journal/providers/entry.dart';
import 'package:journal/providers/image.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entry_main_image.g.dart';

@riverpod
Future<Uint8List?> entryMainImage(
  Ref ref,
  DateTime dt,
  QualityLevel quality,
) async {
  final entry = await ref.watch(entryProvider(dt.toString()).future);
  final firstImage = entry.images.elementAtOrNull(0);
  if (firstImage == null) return null;

  return ref.watch(imageProvider(dt, firstImage, quality).future);
}
