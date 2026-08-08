import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/providers/list_entries.dart';
import 'package:journal/widgets/entry_card.dart';

class HomeScreen extends ConsumerWidget {
    const HomeScreen({super.key});

    @override
        Widget build(BuildContext context, WidgetRef ref) {
            final entries = ref.watch(listEntriesProvider);

            return Scaffold(
                appBar: AppBar(title: Text("Bar Title")),
                body: Column(
                        children: [...entries.map((entry) {
                            return EntryCard(entry: entry);
                        })]
                ),
            );
        }
}
