import 'package:flutter/material.dart';

class EntryCardTemplate extends StatelessWidget {
  const EntryCardTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("\n\n", style: Theme.of(context).textTheme.bodyLarge),
        Spacer(),
        Text("", style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
