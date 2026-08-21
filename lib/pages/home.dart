import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/logger.dart';
import 'package:journal/providers/entry_list.dart';
import 'package:journal/widgets/entry_list.dart' as wid;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Journal")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createEntry(context, ref),
        child: const Icon(Icons.create),
      ),
      body: wid.EntryList(),
    );
  }

  Future<void> createEntry(BuildContext context, WidgetRef ref) async {
    final entryDatetime = await ref.read(entryListProvider.notifier).newEntry();

    if (context.mounted) {
      context.push("/entry/$entryDatetime");
    } else {
      logger.w("Created an entry, but the context was no longer valid.");
    }
  }
}
