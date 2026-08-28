import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/image.dart';
import 'package:journal/providers/images.dart';
import 'package:journal/widgets/image_view.dart';

class ImagesList extends ConsumerWidget {
  final String entryDateString;
  final void Function(ImageData) removeCallback;

  const ImagesList({
    super.key,
    required this.entryDateString,
    required this.removeCallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryImages = ref.watch(imagesProvider(entryDateString));
    return switch (entryImages) {
      AsyncData(value: final images) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: images.length,
        itemBuilder: (context, index) => ImageView(
          imageData: images[index],
          removeCallback: () => removeCallback(images[index]),
        ),
      ),
      AsyncError(:final error) => Center(child: Text(error.toString())),
      _ => Center(child: const CircularProgressIndicator()),
    };
  }
}
