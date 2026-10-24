import 'package:flutter/material.dart';
import 'package:journal/utils/location.dart';

enum PrimaryDisplay { name, displayName, coordinates }

class LocationCard extends StatefulWidget {
  final Location location;
  const LocationCard({super.key, required this.location});

  PrimaryDisplay getPrimaryType() {
    if (location.name?.isNotEmpty == true) {
      return PrimaryDisplay.name;
    }
    if (location.displayName?.isNotEmpty == true) {
      return PrimaryDisplay.displayName;
    }
    return PrimaryDisplay.coordinates;
  }

  String getPrimaryString() {
    switch (getPrimaryType()) {
      case PrimaryDisplay.name:
        return location.name!;
      case PrimaryDisplay.displayName:
        return location.displayName!;
      case PrimaryDisplay.coordinates:
        return "${location.latitude}, ${location.longitude}";
    }
  }

  String getSecondaryString() {
    switch (getPrimaryType()) {
      case PrimaryDisplay.name:
        return location.displayName?.isNotEmpty == true
            ? location.displayName!
            : "${location.latitude}, ${location.longitude}";
      case PrimaryDisplay.displayName:
        return "${location.latitude}, ${location.longitude}";
      case PrimaryDisplay.coordinates:
        return "";
    }
  }

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  final controller = ExpansibleController();
  @override
  Widget build(BuildContext context) {
    return Expansible(
      controller: controller,
      headerBuilder: (_, _) => Row(
        children: [
          ?widget.getPrimaryType() != PrimaryDisplay.coordinates
              ? ExpandIcon(
                  isExpanded: controller.isExpanded,
                  onPressed: (expand) =>
                      !expand ? controller.expand() : controller.collapse(),
                )
              : null,
          Expanded(child: Text(widget.getPrimaryString())),
        ],
      ),
      bodyBuilder: (_, _) => Text(widget.getSecondaryString()),
    );
  }
}
