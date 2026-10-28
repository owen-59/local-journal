import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/providers/search.dart';
import 'package:journal/widgets/error_card.dart';
import 'package:journal/widgets/sliver_entry_list.dart';
import 'package:journal/widgets/measure/entry_card.dart';
import 'package:journal/widgets/measure/entry_separator_with_text.dart';
import 'package:journal/widgets/measure/entry_separator_without_text.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  double _entryCardTemplateHeight = 0;
  double _entrySeparatorWithTextHeight = 0;
  double _entrySeparatorWithoutTextHeight = 0;

  var slowQuery = "";
  var query = "";
  var timer = Timer(const Duration(), () {});
  var isReversed = true;

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchProvider(slowQuery));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.swap_vert),
            onPressed: () => setState(() => isReversed = !isReversed),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(horizontal: 0),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(
                    bottom: 16.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search your entries",
                      ),
                      onChanged: (text) => setState(() {
                        query = text;
                        timer.cancel();
                        timer = Timer(Duration(milliseconds: 500), () {
                          setState(() => slowQuery = query);
                        });
                      }),
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ),
                SliverPadding(padding: const EdgeInsets.only(bottom: 16.0)),
                switch (searchResults) {
                  AsyncData(value: final items) => SliverEntryList(
                    entries:
                        ((List<DateTime> items) =>
                            isReversed ? items.reversed.toList() : items)(
                          items.map((entry) => entry.createdDate).toList(),
                        ),
                    searchText: query,
                    entryCardTemplateHeight: _entryCardTemplateHeight,
                    entrySeparatorWithTextHeight: _entrySeparatorWithTextHeight,
                    entrySeparatorWithoutTextHeight:
                        _entrySeparatorWithoutTextHeight,
                  ),

                  AsyncError(:final error, :final stackTrace) =>
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsetsGeometry.symmetric(
                          vertical: 32.0,
                        ),
                        child: ErrorCard(error: error, stackTrace: stackTrace),
                      ),
                    ),

                  AsyncLoading() => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsGeometry.symmetric(
                        vertical: 32.0,
                      ),
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                },

                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom,
                  ),
                ),
              ],
            ),
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
      ),
    );
  }
}
