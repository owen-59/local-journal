import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/utils/file.dart';
import 'package:journal/widgets/entry_list.dart';

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
      body: EntryList(),
    );
  }

  Future<void> createEntry(BuildContext context, WidgetRef ref) async {
    final rootFolder = ref.watch(folderUriProvider);
    final newDatetime = DateTime.now();
    final path = pathFromDatetime(newDatetime);
    await writeFile(rootFolder.toString(), path, "");

    if (context.mounted) {
      context.push("/entry/$newDatetime");
    } else {
      logger.w("Created an entry, but the context was no longer valid.");
    }
  }
}
