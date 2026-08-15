import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_keyboard_controller/flutter_keyboard_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/db/entry.dart';
import 'package:journal/db/entry_list.dart';
import 'package:journal/logger.dart';
import 'package:journal/types.dart';
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
          onPopInvokedWithResult: (didPop, _) => onGoBack(didPop, context),
          child: KeyboardAvoidingView(
            child: Column(
              children: [
                Expanded(
                  child: MarkdownEditor(
                    initialValue: value.body,
                    onChanged: (text) => setState(() => body = text),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.all(8.0),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.label_outline),
                        onPressed: () => {},
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        onPressed: () => {},
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.schedule),
                        onPressed: () => onSetTimeClicked(context, value),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () => onSetDateClicked(context, value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AsyncError(:final error) => Center(child: Text(error.toString())),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Future<void> onGoBack(bool didPop, BuildContext context) async {
    if (didPop) return;
    await ref
        .read(entryProvider(widget.entryDateString).notifier)
        .updateEntry(body);
    ref.invalidate(entryListProvider);
    if (context.mounted) {
      context.pop();
    }
  }

  Future<void> setDatetime(
    DateTime datetime,
    Entry entry,
    BuildContext context,
  ) async {
    final newEntry = await ref
        .read(entryProvider(widget.entryDateString).notifier)
        .updateDatetime(datetime, body);

    if (newEntry == null) {
      logger.w("updatedEntry from time change did not have a data state.");
      return;
    }
    if (context.mounted) {
      context.replace("/entry/${newEntry.datetime}");
    } else {
      logger.w("Updating time took too long, context unmounted.");
    }
  }

  Future<void> onSetDateClicked(BuildContext context, Entry entry) async {
    final DateTime? datetime = await showDatePicker(
      context: context,
      initialDate: entry.datetime,
      firstDate: DateTime.now().subtract(Duration(days: 365000)),
      lastDate: DateTime.now().add(Duration(days: 365000)),
    );
    if (datetime == null) return;
    await setDatetime(
      datetime.copyWith(
        hour: entry.datetime.hour,
        minute: entry.datetime.minute,
        // ignore: use_build_context_synchronously - because it's checked in setDatetime
      ),
      entry,
      context,
    );
  }

  Future<void> onSetTimeClicked(BuildContext context, Entry entry) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(entry.datetime),
    );

    if (time == null) return;
    await setDatetime(
      entry.datetime.copyWith(
        hour: time.hour,
        minute: time.minute,
        // ignore: use_build_context_synchronously - because it's checked in setDatetime
      ),
      entry,
      context,
    );
  }
}
