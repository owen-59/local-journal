import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/providers/entry_list.dart';
import 'package:journal/widgets/entry_card.dart';
import 'package:journal/widgets/entry_card_seperator.dart';
import 'package:journal/widgets/error_card.dart';
import 'package:measured/measured.dart';

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
  double _entrySeparatorHeight = 0;

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
              slivers: [
                SliverVariedExtentList.builder(
                  itemCount: value.length,
                  itemExtentBuilder: (index, dimensions) =>
                      calculateItemHeight(index, value),
                  itemBuilder: (context, index) => index < value.length
                      ? Column(
                          children: [
                            EntryCardSeperator(
                              aboveEntryDt: index == 0
                                  ? DateTime.fromMillisecondsSinceEpoch(0)
                                  : value[index - 1],
                              belowEntryDt: value[index],
                            ),
                            EntryCard(entryDt: value[index]),
                          ],
                        )
                      : null,
                ),
              ],
            ),
            AsyncError(:final error, :final stackTrace) => Center(
              child: ErrorCard(error: error, stackTrace: stackTrace),
            ),
            _ => Center(child: const CircularProgressIndicator()),
          },
        ),
        Offstage(
          child: Measured(
            onChanged: (size) =>
                setState(() => _entryCardTemplateHeight = size.height),
            child: EntryCard(
              entryDt: DateTime.now().copyWith(
                hour: 0,
                minute: 0,
                second: 0,
                millisecond: 0,
                microsecond: 0,
              ),
            ),
          ),
        ),
        Offstage(
          child: Measured(
            onChanged: (size) =>
                setState(() => _entrySeparatorHeight = size.height),
            child: EntryCardSeperator(
              aboveEntryDt: DateTime(1970),
              belowEntryDt: DateTime(1970),
            ),
          ),
        ),
        Offstage(
          child: Measured(
            onChanged: (size) =>
                setState(() => _entrySeparatorWithTextHeight = size.height),
            child: EntryCardSeperator(
              aboveEntryDt: DateTime(1970),
              belowEntryDt: DateTime(1971),
            ),
          ),
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
        : _entrySeparatorHeight;

    return separatorHeight + _entryCardTemplateHeight;
  }

  Future<void> jumpToDate(DateTime target, List<DateTime> entries) async {
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
    final totalSeparatorHeight = separatorCount * _entrySeparatorHeight;
    final totalEntryHeight = (index - 1) * _entryCardTemplateHeight;

    final scrollPixels =
        totalTextSeparatorHeight + totalSeparatorHeight + totalEntryHeight;

    _scrollController.jumpTo(scrollPixels);
  }
}
