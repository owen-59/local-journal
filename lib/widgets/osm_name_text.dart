import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/providers/osm_id_search.dart';
import 'package:nominatim_flutter/model/response/response.dart';

class OsmNameText extends ConsumerWidget {
  final String osmId;
  const OsmNameText({super.key, required this.osmId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nominatimResponse = ref.watch(osmIdSearchProvider(osmId));

    return switch (nominatimResponse) {
      AsyncData(:final value) => switch (value) {
        null => Text("Could not find the osm entry for $osmId."),
        NominatimResponse(:final displayName) => Text(
          displayName ?? "No display name found for $osmId.",
        ),
      },
      AsyncError(:final error) => Text(
        "There was an error loading $osmId: $error",
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
