import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/providers/entry_list.dart';
import 'package:journal/widgets/entry_card.dart';
import 'package:journal/widgets/error_card.dart';

class EntryList extends ConsumerWidget {
  const EntryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entryListProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.read(entryListProvider.notifier).fullReload(),
      child: switch (entries) {
        AsyncData(:final value) => ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) => EntryCard(entry: value[index]),
        ),
        AsyncError(:final error, :final stackTrace) => Center(
          child: ErrorCard(error: error, stackTrace: stackTrace),
        ),
        _ => Center(child: const CircularProgressIndicator()),
      },
    );
  }
}
