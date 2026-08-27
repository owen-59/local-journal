import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:journal/image.dart';

class ImageView extends StatefulWidget {
  final ImageData imageData;
  final void Function() removeCallback;

  const ImageView({
    super.key,
    required this.imageData,
    required this.removeCallback,
  });

  @override
  State<StatefulWidget> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return switch (widget.imageData.bytes) {
      Uint8List bytes => Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        // child: Stack(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          child: Image.memory(
            bytes,
            frameBuilder: (context, child, frame, _) {
              if (frame == null) {
                return const Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 5),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return Stack(
                  children: [
                    child,
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, right: 10),
                        child: MenuAnchor(
                          controller: _menuController,
                          menuChildren: [
                            MenuItemButton(
                              leadingIcon: const Icon(Icons.delete),
                              child: const Text("Delete"),
                              onPressed: () => widget.removeCallback(),
                            ),
                          ],
                          builder: (context, controller, _) {
                            return IconButton(
                              icon: Icon(Icons.menu),
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),

      null => Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            border: Border.all(color: Theme.of(context).colorScheme.error),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Image not found at '${widget.imageData.name}'.",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => widget.removeCallback(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            "Remove link.",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    };
  }
}
