import 'package:flutter/material.dart';
import 'package:flutter_keyboard_controller/flutter_keyboard_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal/entry.dart';
import 'package:journal/image.dart';
import 'package:journal/logger.dart';
import 'package:journal/providers/entry.dart';
import 'package:journal/widgets/images_list.dart';
import 'package:journal/widgets/osm_name_text.dart';
import 'package:journal/widgets/place_search.dart';
import 'package:journal/widgets/tags_editor.dart';
import 'package:journal/widgets/text_input.dialogue.dart';
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

    return switch (entry) {
      AsyncData(:final value) => Scaffold(
        appBar: AppBar(),
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (innerContext) => PopScope(
            onPopInvokedWithResult: (didPop, object) =>
                onGoBack(didPop, context, object),
            child: SafeArea(
              child: KeyboardAvoidingView(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MarkdownEditor(
                              initialValue: value.body,
                              onChanged: (text) => setState(() => body = text),
                            ),

                            if (value.locationId != null)
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ) +
                                    EdgeInsets.only(top: 4),
                                child: OsmNameText(osmId: value.locationId!),
                              ),

                            Padding(
                              padding: EdgeInsetsGeometry.all(8),
                              child: Wrap(
                                spacing: 8,
                                children: [
                                  for (final tag in value.tags)
                                    Chip(label: Text(tag)),
                                ],
                              ),
                            ),
                            ImagesList(
                              entryDateString: widget.entryDateString,
                              removeCallback: (imageData) =>
                                  onRemoveImageLink(value, imageData),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(8.0),
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.label_outline),
                            onPressed: () => onAddTagsClicked(context, value),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            onPressed: () => onAddImageClicked(context, value),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.schedule),
                            onPressed: () => onSetTimeClicked(context, value),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () => onSetDateClicked(context, value),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.edit_location_outlined),
                            onPressed: () =>
                                onSetLocationClicked(context, value),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => onDeleteClicked(context, value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      AsyncError(:final error) => Center(child: Text(error.toString())),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  void onGoBack(bool didPop, BuildContext context, Object? popObject) {
    if (!didPop || popObject == "DO_NOT_WRITE") return;
    ref
        .read(entryProvider(widget.entryDateString).notifier)
        .writeWith(body: body);
  }

  Future<void> setDatetime(
    DateTime datetime,
    Entry entry,
    BuildContext context,
  ) async {
    final newEntry = await ref
        .read(entryProvider(widget.entryDateString).notifier)
        .writeWith(body: body, datetime: datetime);

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
      ),
      entry,
      // ignore: use_build_context_synchronously - because it's checked in setDatetime
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
      entry.datetime.copyWith(hour: time.hour, minute: time.minute),
      entry,
      // ignore: use_build_context_synchronously - because it's checked in setDatetime
      context,
    );
  }

  Future<void> onAddTagsClicked(BuildContext context, Entry entry) async {
    final tags = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TagsEditor(initialTags: entry.tags),
    );
    if (tags == null) {
      logger.w("Tags editor did not return a list?");
      return;
    }
    await ref
        .read(entryProvider(widget.entryDateString).notifier)
        .writeWith(body: body, tags: tags);
  }

  Future<void> onDeleteClicked(BuildContext context, Entry entry) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete?"),
        content: const Text("Are you sure you want to delete this entry?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (result == true) {
      ref.read(entryProvider(widget.entryDateString).notifier).delete();
      if (context.mounted) context.pop("DO_NOT_WRITE");
    }
  }

  Future<void> onAddImageClicked(BuildContext context, Entry entry) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    if (context.mounted) {
      final name = await showDialog<String>(
        context: context,
        builder: (context) => TextInputDialog(),
      );
      if (name == null) return;
      logger.i("fileUri: ${image.path} $name");
      ref
          .read(entryProvider(widget.entryDateString).notifier)
          .addImage(image, name);
    } else {
      logger.w(
        "Received image, but context became unmounted before showing name chooser.",
      );
      return;
    }
  }

  Future<void> onRemoveImageLink(Entry entry, ImageData imageData) async {
    logger.i("Removing ${imageData.name}");
    await ref
        .read(entryProvider(widget.entryDateString).notifier)
        .removeImage(imageData.name);
  }

  Future<void> onSetLocationClicked(BuildContext context, Entry entry) async {
    final locationId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PlaceSearch(),
    );

    if (locationId == null) return;

    logger.i("location: $locationId");

    await ref
        .read(entryProvider(widget.entryDateString).notifier)
        .writeWith(body: body, locationId: locationId);
  }
}
