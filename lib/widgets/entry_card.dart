import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:journal/providers/entry.dart';
import 'package:journal/providers/entry_main_image.dart';
import 'package:journal/providers/image.dart';
import 'package:journal/widgets/entry_card_template.dart';
import 'package:journal/widgets/error_card.dart';
import 'package:substring_highlight/substring_highlight.dart';

class EntryCard extends ConsumerWidget {
  final DateTime entryDt;
  final String? searchText;

  const EntryCard({super.key, required this.entryDt, this.searchText});

  void _redirectToEntry(BuildContext context) {
    context.push("/entry/$entryDt");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(entryProvider(entryDt.toString()));
    final image = ref.watch(
      entryMainImageProvider(entryDt, QualityLevel.thumbnail),
    );

    return GestureDetector(
      onTap: () => _redirectToEntry(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
        padding: const EdgeInsets.only(bottom: 5),
        child: IntrinsicHeight(
          child: Stack(
            alignment: Alignment.center,
            children: [
              EntryCardTemplate(),
              switch (entry) {
                AsyncError(:final error, :final stackTrace) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (_) =>
                        ErrorCard(error: error, stackTrace: stackTrace),
                  ),
                  child: Text("Error"),
                ),
                AsyncData(:final value) => Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SubstringHighlight(
                                  text: value.body,
                                  term: searchText ?? "",
                                  textStyle:
                                      Theme.of(context).textTheme.bodyLarge ??
                                      DefaultTextStyle.of(context).style,
                                  textStyleHighlight:
                                      (Theme.of(context).textTheme.bodyLarge ??
                                              DefaultTextStyle.of(
                                                context,
                                              ).style)
                                          .copyWith(
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.primaryContainer,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer,
                                          ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Spacer(),
                                Text(
                                  "${DateFormat("HH:mm dd MMMM").format(entryDt)}${value.tags.isNotEmpty ? " - " : ""}${value.tags.join(", ")}",
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          switch (image) {
                            AsyncData(value: final imageBytes)
                                when imageBytes != null =>
                              SizedBox.square(
                                dimension: 80,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0),
                                  ),
                                  child: Image.memory(
                                    imageBytes,
                                    fit: BoxFit.cover,
                                    frameBuilder: (context, child, frame, _) =>
                                        frame == null
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : child,
                                  ),
                                ),
                              ),
                            _ => SizedBox.shrink(),
                          },
                        ],
                      ),
                    ),
                  ],
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ],
          ),
        ),
      ),
    );
  }
}
