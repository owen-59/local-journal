import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/widgets/location_editor/map_search.dart';
import 'package:journal/widgets/location_editor/name_search.dart';

class LocationEditor extends ConsumerStatefulWidget {
  const LocationEditor({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LocationEditorState();
}

class _LocationEditorState extends ConsumerState<LocationEditor> {
  bool _isSearchMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: _isSearchMode,
      appBar: AppBar(
        actions: [
          _isSearchMode
              ? IconButton(
                  icon: Icon(Icons.map),
                  onPressed: () => setState(() => _isSearchMode = false),
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => setState(() => _isSearchMode = true),
                ),
        ],
      ),
      body: PopScope(
        child: _isSearchMode
            ? NameSearch(
                onLocationPicked: (location) =>
                    Navigator.pop(context, location),
              )
            : MapSearch(
                onLocationPicked: (location) =>
                    Navigator.pop(context, location),
              ),
      ),
    );
  }
}
