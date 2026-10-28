import 'dart:async';

import 'package:journal/models/image.dart';
import 'package:journal/logger.dart';
import 'package:journal/providers/entry.dart';
import 'package:journal/providers/image.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'images.g.dart';

@riverpod
Future<List<ImageData>> images(Ref ref, DateTime entryDt) async {
  final asyncValue = ref.watch(entryProvider(entryDt.toString()));
  final entry = asyncValue.asData?.value;
  if (entry == null) {
    return [];
  }

  var imageList = <ImageData>[];

  for (final imageName in entry.images) {
    final imageBytes = await ref.watch(
      imageProvider(entry.datetime, imageName, QualityLevel.full).future,
    );
    final imageData = ImageData(name: imageName, bytes: imageBytes);
    logger.d("Read image $imageName for ${entry.datetime}");
    imageList.add(imageData);
    imageList = [...imageList];
  }
  return imageList;
}
