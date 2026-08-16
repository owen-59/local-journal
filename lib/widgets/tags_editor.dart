import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_controller/flutter_keyboard_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/providers/tags_list.dart';

class TagsEditor extends ConsumerStatefulWidget {
  const TagsEditor({super.key, required this.initialTags});

  final List<String> initialTags;

  @override
  ConsumerState<TagsEditor> createState() => _TagsEditorState();
}

class _TagsEditorState extends ConsumerState<TagsEditor> {
  late final List<String> tags = [...widget.initialTags];
  String searchInput = "";

  void toggleTag(String tag) {
    setState(() {
      if (tags.contains(tag)) {
        tags.remove(tag);
      } else {
        tags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allTags = ref.watch(tagsProvider);

    return SafeArea(
      child: KeyboardAvoidingView(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              Navigator.pop(context, tags);
            }
          },
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: switch (allTags) {
                AsyncData(:final value) => StatefulBuilder(
                  builder: (context, setState) {
                    var filteredTags =
                        <String>{
                          ...value.where(
                            (tag) =>
                                searchInput.trim().isEmpty ||
                                tag.toLowerCase().contains(
                                  searchInput.toLowerCase(),
                                ),
                          ),
                          ...tags,
                        }.toList().sorted((a, b) {
                          final aMatchs = tags.contains(a);
                          final bMatchs = tags.contains(b);

                          if (aMatchs && !bMatchs) return -1;
                          if (bMatchs && !aMatchs) return 1;
                          return 0;
                        });

                    return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 500),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tags',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),

                          const SizedBox(height: 16),

                          TextField(
                            onChanged: (input) => setState(() {
                              searchInput = input;
                            }),
                            decoration: InputDecoration(
                              hintText: "Search tags",
                            ),
                          ),

                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: ListView.builder(
                              itemCount: filteredTags.length + 1,
                              itemBuilder: (context, index) => index == 0
                                  ? (searchInput.trim().isNotEmpty &&
                                            !tags
                                                .map(
                                                  (tag) =>
                                                      tag.trim().toLowerCase(),
                                                )
                                                .contains(
                                                  searchInput
                                                      .trim()
                                                      .toLowerCase(),
                                                )
                                        ? ListTile(
                                            leading: Checkbox(
                                              onChanged: (_) =>
                                                  toggleTag(searchInput),
                                              value: false,
                                            ),
                                            title: Text(searchInput),
                                          )
                                        : const SizedBox.shrink())
                                  : ListTile(
                                      leading: Checkbox(
                                        onChanged: (checked) =>
                                            toggleTag(filteredTags[index - 1]),
                                        value: tags.contains(
                                          filteredTags[index - 1],
                                        ),
                                      ),
                                      title: Text(filteredTags[index - 1]),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () => Navigator.pop(context, tags),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                AsyncError(:final error) => Center(
                  child: Column(
                    children: [Text("Something went wrong."), Text("$error")],
                  ),
                ),
                _ => Center(child: const CircularProgressIndicator()),
              },
            ),
          ),
        ),
      ),
    );
  }
}
