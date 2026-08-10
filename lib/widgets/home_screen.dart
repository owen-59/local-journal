import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/db.dart';
import 'package:journal/widgets/entry_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(itemsProvider);

    return switch (entries) {
      AsyncData(:final value) => Scaffold(
        appBar: AppBar(title: Text("Bar Title")),
        body: ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) => EntryCard(entry: value[index]),
        ),
      ),
      AsyncError(:final error) => Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Text(error.toString()),
      ),
      _ => const CircularProgressIndicator(),
    };
  }
}
