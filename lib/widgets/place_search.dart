import 'package:flutter/material.dart';
import 'package:flutter_keyboard_controller/flutter_keyboard_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/providers/osm_search.dart';
import 'package:journal/utils/nominatim.dart';
import 'package:nominatim_flutter/model/response/response.dart';

class PlaceSearch extends ConsumerStatefulWidget {
  const PlaceSearch({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaceSearchState();
}

class _PlaceSearchState extends ConsumerState<PlaceSearch> {
  String searchInput = "";
  late List<NominatimResponse> currentResults = [];

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(osmSearchProvider(searchInput));

    return SafeArea(
      child: KeyboardAvoidingView(
        child: PopScope(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                        onTap: () => Navigator.pop(
                          context,
                          osmIdFromNomatinimObj(value[index]),
                        ),
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
            ),
          ),
        ),
      ),
    );
  }
}
