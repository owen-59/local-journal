import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:flutter_keyboard_controller/flutter_keyboard_controller.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:journal/providers/tags_list.dart";

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
                    final allTags =
                        [
                              ...tags.map((tag) {
                                final matchingExistingTag = value
                                    .firstWhereOrNull(
                                      (tagEntry) => tagEntry.name == tag,
                                    );
                                if (matchingExistingTag == null) {
                                  return TagEntry(name: tag, frequency: 1);
                                }
                                return TagEntry(
                                  name: tag,
                                  frequency: matchingExistingTag.frequency + 1,
                                );
                              }),
                              ...value
                                  .map(
                                    (tag) =>
                                        tags.contains(tag.name) ? null : tag,
                                  )
                                  .nonNulls
                                  .sorted(
                                    (a, b) =>
                                        b.frequency.compareTo(a.frequency),
                                  ),
                            ]
                            .where(
                              (tag) =>
                                  searchInput.trim().isEmpty ||
                                  tag.name.toLowerCase().contains(
                                    searchInput.trim().toLowerCase(),
                                  ),
                            )
                            .toList();
                    return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 500),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Tags",
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
                              itemCount: allTags.length + 1,
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
                                            toggleTag(allTags[index - 1].name),
                                        value: tags.contains(
                                          allTags[index - 1].name,
                                        ),
                                      ),
                                      title: Text(allTags[index - 1].name),
                                      trailing: Text(
                                        allTags[index - 1].frequency.toString(),
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () => Navigator.pop(context, tags),
                            child: const Text("Done"),
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
