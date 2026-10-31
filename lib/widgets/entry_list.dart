import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/providers/entry_list.dart';
import 'package:journal/widgets/error_card.dart';
import 'package:journal/widgets/measure/entry_card.dart';
import 'package:journal/widgets/measure/entry_separator_with_text.dart';
import 'package:journal/widgets/measure/entry_separator_without_text.dart';
import 'package:journal/widgets/sliver_entry_list.dart';

class EntryList extends ConsumerStatefulWidget {
  const EntryList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => EntryListState();
}

class EntryListState extends ConsumerState<EntryList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _scrollController = ScrollController();

  double _entryCardTemplateHeight = 0;
  double _entrySeparatorWithTextHeight = 0;
  double _entrySeparatorWithoutTextHeight = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final entries = ref.watch(entryListProvider);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async =>
              ref.read(entryListProvider.notifier).fullReload(),
          child: switch (entries) {
            AsyncData(:final value) => CustomScrollView(
              controller: _scrollController,
              scrollCacheExtent: ScrollCacheExtent.viewport(2),
              slivers: [
                SliverEntryList(
                  entries: value,
                  entryCardTemplateHeight: _entryCardTemplateHeight,
                  entrySeparatorWithTextHeight: _entrySeparatorWithTextHeight,
                  entrySeparatorWithoutTextHeight:
                      _entrySeparatorWithoutTextHeight,
                ),
              ],
            ),
            AsyncError(:final error, :final stackTrace) => Center(
              child: ErrorCard(error: error, stackTrace: stackTrace),
            ),
            _ => Center(child: const CircularProgressIndicator()),
          },
        ),
        EntryCardMeasurer(
          onChanged: (height) =>
              setState(() => _entryCardTemplateHeight = height),
        ),
        EntrySeparatorWithoutTextMeasurer(
          onChanged: (height) =>
              setState(() => _entrySeparatorWithoutTextHeight = height),
        ),
        EntrySeparatorWithTextMeasurer(
          onChanged: (height) =>
              setState(() => _entrySeparatorWithTextHeight = height),
        ),
      ],
    );
  }

  double? calculateItemHeight(int index, List<DateTime> entries) {
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
        ? _entrySeparatorWithTextHeight
        : _entrySeparatorWithoutTextHeight;

    return separatorHeight + _entryCardTemplateHeight;
  }

  Future<void> jumpToDate(DateTime target) async {
    ref.read(entryListProvider).whenData((entries) async {
      final entriesOnDay = max(
        entries
            .where(
              (dt) =>
                  dt.year == target.year &&
                  dt.month == target.month &&
                  dt.day == target.day,
            )
            .length,
        1,
      );

      final index =
          lowerBound(entries, target, compare: (a, b) => -a.compareTo(b)) -
          entriesOnDay +
          1;

      final textSeperatorCount =
          entries.whereIndexed((index, element) {
            if (index == 0 || element.isBefore(target)) return false;
            final prev = entries[index - 1];
            return element.year != prev.year || element.month != prev.month;
          }).length +
          1;
      final separatorCount = (index - 1 - textSeperatorCount);

      final totalTextSeparatorHeight =
          textSeperatorCount * _entrySeparatorWithTextHeight;
      final totalSeparatorHeight =
          separatorCount * _entrySeparatorWithoutTextHeight;
      final totalEntryHeight = (index - 1) * _entryCardTemplateHeight;

      final scrollPixels =
          totalTextSeparatorHeight + totalSeparatorHeight + totalEntryHeight;

      _scrollController.jumpTo(scrollPixels);
    });
  }
}
