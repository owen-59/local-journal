import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/providers/entry_list.dart';
import 'package:journal/widgets/entry_card.dart';
import 'package:journal/widgets/entry_card_seperator.dart';
import 'package:journal/widgets/error_card.dart';

class EntryList extends ConsumerWidget {
  const EntryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entryListProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.read(entryListProvider.notifier).fullReload(),
      child: switch (entries) {
        AsyncData(:final value) => ListView.separated(
          itemCount: value.length,
          addAutomaticKeepAlives: true,
          itemBuilder: (context, index) => index == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EntryCardSeperator(
                      aboveEntryDt: DateTime.fromMillisecondsSinceEpoch(0),
                      belowEntryDt: value[index],
                    ),
                    EntryCard(entryDt: value[index]),
                  ],
                )
              : EntryCard(entryDt: value[index]),
          separatorBuilder: (context, index) => EntryCardSeperator(
            aboveEntryDt: value[index],
            belowEntryDt: value[index + 1],
          ),
        ),
        AsyncError(:final error, :final stackTrace) => Center(
          child: ErrorCard(error: error, stackTrace: stackTrace),
        ),
        _ => Center(child: const CircularProgressIndicator()),
      },
    );
  }
}
