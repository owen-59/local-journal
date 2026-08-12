import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/db.dart';

class EntryEditor extends ConsumerWidget {
  final String entryDateString;
  const EntryEditor({super.key, required this.entryDateString});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(entryProvider(entryDateString));
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: switch (entry) {
          AsyncData(:final value) => Text(value.body),
          AsyncError(:final error) => Text(error.toString()),
          _ => const CircularProgressIndicator(),
        },
      ),
    );
  }
}
