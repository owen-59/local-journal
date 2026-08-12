import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/db.dart';
import 'package:journal/widgets/entry_card.dart';

class EntryList extends ConsumerWidget {
  const EntryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entriesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(entriesProvider.future),
      child: switch (entries) {
        AsyncData(:final value) => ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) => EntryCard(entry: value[index]),
        ),
        AsyncError(:final error) => Center(child: Text(error.toString())),
        _ => Center(child: const CircularProgressIndicator()),
      },
    );
  }
}
