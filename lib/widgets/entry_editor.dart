import 'package:flutter/material.dart';
import 'package:flutter_keyboard_controller/flutter_keyboard_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/db/entry.dart';
import 'package:journal/db/entry_list.dart';
import 'package:markdown_editor_live/markdown_editor_live.dart';

class EntryEditor extends ConsumerStatefulWidget {
  final String entryDateString;
  const EntryEditor({super.key, required this.entryDateString});

  @override
  ConsumerState<EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends ConsumerState<EntryEditor> {
  String body = "";

  @override
  Widget build(BuildContext context) {
    final entry = ref.watch(entryProvider(widget.entryDateString));

    ref.listen(entryProvider(widget.entryDateString), (prev, next) {
      next.whenOrNull(data: (data) => body = data.body);
    });

    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: switch (entry) {
        AsyncData(:final value) => PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await ref
                .read(entryProvider(widget.entryDateString).notifier)
                .updateEntry(body);
            ref.invalidate(entryListProvider);
            if (context.mounted) {
              context.pop();
            }
          },
          child: KeyboardAvoidingView(
            child: Column(
              children: [
                Expanded(
                  child: MarkdownEditor(
                    initialValue: value.body,
                    onChanged: (text) => setState(() => body = text),
                  ),
                ),
                Row(children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.label_outline),
                    onPressed: () => {},
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    onPressed: () => {},
                  )
                ],)
              ],
            )
          ),
        ),
        AsyncError(:final error) => Center(child: Text(error.toString())),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
