import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:journal/image.dart';

class ImageView extends StatelessWidget {
  final ImageData imageData;
  const ImageView({super.key, required this.imageData});

  @override
  Widget build(BuildContext context) {
    return switch (imageData.bytes) {
      Uint8List bytes => Image.memory(bytes),
      null => Text("Image not found at ${imageData.name}"),
    };
  }
}
