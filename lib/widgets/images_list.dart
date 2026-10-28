import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/widgets/image_view.dart';

class ImagesList extends ConsumerWidget {
  final DateTime entryDt;
  final List<String> names;
  final void Function(String) removeCallback;

  const ImagesList({
    super.key,
    required this.entryDt,
    required this.names,
    required this.removeCallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: names.length,
      itemBuilder: (_, index) => ImageView(
        entryDt: entryDt,
        name: names[index],
        removeCallback: () => removeCallback(names[index]),
      ),
    );
  }
}
