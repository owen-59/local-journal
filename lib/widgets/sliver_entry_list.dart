import 'package:flutter/material.dart';
import 'package:journal/widgets/entry_card.dart';
import 'package:journal/widgets/entry_card_seperator.dart';

class SliverEntryList extends StatelessWidget {
  final List<DateTime> entries;
  final String? searchText;
  final double entrySeparatorWithTextHeight;
  final double entrySeparatorWithoutTextHeight;
  final double entryCardTemplateHeight;

  const SliverEntryList({
    super.key,
    required this.entries,
    required this.entrySeparatorWithTextHeight,
    required this.entrySeparatorWithoutTextHeight,
    required this.entryCardTemplateHeight,
    this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    return SliverVariedExtentList.builder(
      itemCount: entries.length,
      itemExtentBuilder: (index, dimensions) => calculateItemHeight(index),
      itemBuilder: (context, index) => index < entries.length
          ? Column(
              children: [
                EntryCardSeperator(
                  aboveEntryDt: index == 0
                      ? DateTime.fromMillisecondsSinceEpoch(0)
                      : entries[index - 1],
                  belowEntryDt: entries[index],
                ),
                EntryCard(entryDt: entries[index], searchText: searchText),
              ],
            )
          : null,
    );
  }

  double? calculateItemHeight(int index) {
    var hasTextSeparator = false;
    if (index >= entries.length) return null;
    if (index == 0) hasTextSeparator = true;

    if (!hasTextSeparator) {
      final current = entries[index];
      final prev = entries[index - 1];

      if (prev.year != current.year || prev.month != current.month) {
        hasTextSeparator = true;
      }
    }

    final separatorHeight = hasTextSeparator
        ? entrySeparatorWithTextHeight
        : entrySeparatorWithoutTextHeight;

    return separatorHeight + entryCardTemplateHeight;
  }
}
