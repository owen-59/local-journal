import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/logger.dart';
import 'package:journal/providers/osm_reverse_geocode.dart';
import 'package:journal/utils/location.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapSearch extends ConsumerStatefulWidget {
  final void Function(Location) onLocationPicked;
  const MapSearch({super.key, required this.onLocationPicked});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapSearchState();
}

class _MapSearchState extends ConsumerState<MapSearch> {
  LatLng? _lastClicked;

  @override
  Widget build(BuildContext context) {
    final reverseResults = ref.watch(osmReverseGeocodeProvider(_lastClicked));

    return SafeArea(
      child: Stack(
        alignment: AlignmentGeometry.bottomStart,
        children: [
          MapLibreMap(
            styleString: "https://tiles.openfreemap.org/styles/bright",
            onMapClick: (point, latlng) {
              logger.i("$point, $latlng");
              setState(() => _lastClicked = latlng);
            },
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsetsGeometry.symmetric(
              horizontal: 4.0,
              vertical: 6.0,
            ),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: Text(switch (reverseResults) {
                    AsyncData(:final value) =>
                      value != null
                          ? (value.name?.isNotEmpty ?? false
                                    ? value.name
                                    : null) ??
                                (value.displayName?.isNotEmpty ?? false
                                    ? value.displayName
                                    : null) ??
                                "${value.latitude}, ${value.longitude}"
                          : "",
                    _ => "",
                  }, style: Theme.of(context).textTheme.bodyLarge),
                ),
                ?reverseResults.hasValue
                    ? IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () =>
                            widget.onLocationPicked(reverseResults.value!),
                      )
                    : null,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
