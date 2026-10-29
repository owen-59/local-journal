import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/logger.dart';
import 'package:journal/providers/map_points.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/link.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late MapLibreMapController controller;
  bool _isStyleLoaded = false;
  bool _hasLocationPermissions = false;

  @override
  void initState() {
    super.initState();
    () async {
      final locationPermissionGranted =
          await Permission.locationWhenInUse.isGranted;
      setState(() {
        _hasLocationPermissions = locationPermissionGranted;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final geoJsonData = ref.watch(mapPointsProvider);

    ref.listen(mapPointsProvider, (prev, next) {
      if (_isStyleLoaded && next.hasValue) {
        _updateGeoJsonSource(next.value!);
      }
    });

    return Stack(
      alignment: AlignmentGeometry.bottomRight,
      children: [
        MapLibreMap(
          styleString: "https://tiles.openfreemap.org/styles/positron",
          myLocationEnabled: _hasLocationPermissions,
          onMapCreated: (MapLibreMapController controller) => setState(() {
            this.controller = controller;
          }),
          onStyleLoadedCallback: () async {
            setState(() {
              _isStyleLoaded = true;
            });

            geoJsonData.whenData((data) => _updateGeoJsonSource(data));
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsetsGeometry.only(right: 4.0, bottom: 4.0),
              child: IconButton.filled(
                icon: Icon(Icons.location_pin),
                onPressed: () async {
                  final isGranted = await Permission.locationWhenInUse
                      .request()
                      .isGranted;
                  setState(() => _hasLocationPermissions = isGranted);
                  final location = await controller.requestMyLocationLatLng();

                  if (isGranted && location != null) {
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: location, zoom: 12.0),
                      ),
                      duration: const Duration(seconds: 2),
                    );
                    // todo move cam
                    logger.d("Location permission granted");
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.0),
              color: Theme.of(context).colorScheme.inverseSurface,
              child: Link(
                uri: Uri.parse("https://openstreetmap.org/copyright"),
                target: LinkTarget.blank,
                builder: (context, followLink) => Text(
                  "\u2764 © OpenStreetMap contributors",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future _updateGeoJsonSource(List<Object> geoJsonData) async {
    if ((await controller.getSourceIds()).contains("entries")) {
      await controller.setGeoJsonSource("entries", {
        "type": "FeatureCollection",
        "features": geoJsonData,
      });
    } else {
      await controller.addGeoJsonSource("entries", {
        "type": "FeatureCollection",
        "features": geoJsonData,
      });
    }

    await controller.removeLayer("entries-heat");
    await controller.removeLayer("entries-circles");
    await controller.addHeatmapLayer(
      'entries',
      'entries-heat',
      HeatmapLayerProperties(
        heatmapRadius: [
          Expressions.interpolate,
          ['linear'],
          [Expressions.zoom],
          0,
          2,
          9,
          20,
        ],
        heatmapIntensity: [
          Expressions.interpolate,
          ['linear'],
          [Expressions.zoom],
          0,
          1,
          9,
          3,
        ],
        heatmapOpacity: [
          Expressions.interpolate,
          ['linear'],
          [Expressions.zoom],
          10,
          1.0,
          13,
          0.4,
        ],
        heatmapColor: [
          'interpolate',
          ['linear'],
          ['heatmap-density'],
          0,
          'rgba(0, 0, 255, 0)',
          0.2,
          'rgb(198, 219, 239)',
          0.4,
          'rgb(158, 202, 225)',
          0.6,
          'rgb(107, 174, 214)',
          0.8,
          'rgb(49, 130, 189)',
          1.0,
          'rgb(8, 81, 156)',
        ],
      ),
    );

    await controller.addCircleLayer(
      'entries',
      'entries-circles',
      CircleLayerProperties(
        circleOpacity: [
          Expressions.interpolate,
          ['linear'],
          [Expressions.zoom],
          10,
          0.0,
          13,
          1.0,
        ],
        circleRadius: 4,
        circleColor: 'rgb(8,81,156)',
      ),
      minzoom: 7,
    );
  }
}
