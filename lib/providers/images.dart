import 'dart:async';

import 'package:journal/image.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/providers/entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'images.g.dart';

@riverpod
class Images extends _$Images {
  var _state = <ImageData>[];

  @override
  Future<List<ImageData>> build(String datetimeString) async {
    ref.listen(entryProvider(datetimeString), (prev, next) async {
      final current = next.asData?.value;
      if (current == null) return;

      await fullReload();
      _state = _state
          .where((image) => current.images.contains(image.name))
          .toList();
    });

    return [];
  }

  Future<void> fullReload() async {
    logger.i("Doing full reload of images.");
    final asyncValue = ref.watch(entryProvider(datetimeString));
    final entry = asyncValue.asData?.value;
    if (entry == null) {
      _state = [];
      state = AsyncData(_state);
      return;
    }

    final rootFolder = ref.watch(folderUriProvider);

    var imageList = <ImageData>[];

    for (final imageName in entry.images) {
      logger.d("Reading image $imageName for entry ${entry.datetime}");
      final imageData = await entry.readImage(rootFolder.toString(), imageName);
      imageList.add(imageData);
      imageList = [...imageList];
      _state = imageList;
    }
    state = AsyncData(_state);
  }
}
