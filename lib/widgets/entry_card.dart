import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:journal/types.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;

  const EntryCard({super.key, required this.entry});

  void _redirectToEntry(BuildContext context) {
    context.push("/entry/${entry.datetime}");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _redirectToEntry(context),
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.body, style: Theme.of(context).textTheme.bodyLarge),
            Text(
              DateFormat("HH:mm dd MMMM").format(entry.datetime),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
