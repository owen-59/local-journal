import 'dart:async';

import 'package:journal/image.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/providers/entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'images.g.dart';

@riverpod
class Images extends _$Images {
  @override
  Future<List<ImageData>> build(String datetimeString) async {
    logger.i("Doing full reload of images.");
    final asyncValue = ref.watch(entryProvider(datetimeString));
    final entry = asyncValue.asData?.value;
    if (entry == null) {
      return [];
    }

    final rootFolder = ref.watch(folderUriProvider);

    var imageList = <ImageData>[];

    for (final imageName in entry.images) {
      logger.d("Reading image $imageName for entry ${entry.datetime}");
      final imageData = await entry.readImage(rootFolder.toString(), imageName);
      logger.d("Read image $imageName");
      imageList.add(imageData);
      imageList = [...imageList];
    }
    return imageList;
  }
}
