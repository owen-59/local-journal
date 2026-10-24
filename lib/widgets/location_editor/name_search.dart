import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/providers/osm_search.dart';
import 'package:journal/utils/location.dart';

class NameSearch extends ConsumerStatefulWidget {
  final void Function(Location) onLocationPicked;
  const NameSearch({super.key, required this.onLocationPicked});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NameSearchState();
}

class _NameSearchState extends ConsumerState<NameSearch> {
  String searchInput = "";

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(osmSearchProvider(searchInput));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: "Search for a place"),
            onSubmitted: (text) => setState(() => searchInput = text),
            autofocus: true,
            textInputAction: TextInputAction.search,
          ),
          const SizedBox(height: 10.0),
          switch (searchResults) {
            AsyncData(:final value) => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => widget.onLocationPicked(value[index]),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  value[index].displayName ?? "No name found.",
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              separatorBuilder: (context, index) => const Divider(),
            ),

            AsyncError(:final error) => Center(
              child: Text("There was an error: $error"),
            ),

            _ => Center(
              heightFactor: 2.0,
              child: const CircularProgressIndicator(),
            ),
          },
        ],
      ),
    );
  }
}
