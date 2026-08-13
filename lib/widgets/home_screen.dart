import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/db/create.dart';
import 'package:journal/logger.dart';
import 'package:journal/widgets/entry_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Journal")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final redirect = await ref.read(createControllerProvider.notifier).createEntry();
          if (context.mounted) {
            context.push(redirect);
          } else {
            logger.w("Created an entry, but context was no longer valid.");
          }
        },
        child: const Icon(Icons.create)
      ),
      body: EntryList(),
    );
  }
}
