import 'package:journal/image.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/providers/entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'images.g.dart';

@riverpod
Stream<List<ImageData>> images(Ref ref, String datetimeString) async* {
  final asyncValue = ref.watch(entryProvider(datetimeString));
  final entry = asyncValue.asData?.value;
  if (entry == null) {
    yield [];
    return;
  }

  final rootFolder = ref.watch(folderUriProvider);

  var imageList = <ImageData>[];

  for (final imageName in entry.images) {
    logger.d("Reading image $imageName for entry ${entry.datetime}");
    final imageData = await entry.readImage(rootFolder.toString(), imageName);
    imageList.add(imageData);
    imageList = [...imageList];
    yield imageList;
  }
}
