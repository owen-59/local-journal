import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final provider = Provider((_) => "Hello world.");

class HomeScreen extends ConsumerWidget {
    const HomeScreen({super.key});

    @override
        Widget build(BuildContext context, WidgetRef ref) {
            final String text = ref.watch(provider);

            return Scaffold(
                appBar: AppBar(title: Text("Bar Title")),
                body: Center(
                    child: Text(text),
                ),
            );
        }
}
