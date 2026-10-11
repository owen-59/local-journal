import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:journal/providers/entry.dart';
import 'package:journal/widgets/error_card.dart';

class EntryCard extends ConsumerWidget {
  final DateTime entryDt;

  const EntryCard({super.key, required this.entryDt});

  void _redirectToEntry(BuildContext context) {
    context.push("/entry/$entryDt");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(entryProvider(entryDt.toString()));

    return GestureDetector(
      onTap: () => _redirectToEntry(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
        padding: const EdgeInsets.only(bottom: 5),
        child: switch (entry) {
          AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value.body, style: Theme.of(context).textTheme.bodyLarge),
              Text(
                "${DateFormat("HH:mm dd MMMM").format(entryDt)}${value.tags.isNotEmpty ? " - " : ""}${value.tags.join(", ")}",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(),
            ],
          ),
          AsyncError(:final error, :final stackTrace) => ErrorCard(
            error: error,
            stackTrace: stackTrace,
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
