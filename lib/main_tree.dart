import 'dart:async';
import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_controller/flutter_keyboard_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/database.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/pages/editor.dart';
import 'package:journal/pages/home.dart';
import 'package:journal/providers/entry_list.dart';
import 'package:journal/worker.dart';
import 'package:share_handler/share_handler.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey _providerScopeKey = GlobalKey();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(path: "/", builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: "/entry/:datetime",
      builder: (context, state) =>
          EntryEditor(entryDateString: state.pathParameters["datetime"]!),
    ),
  ],
);

class MainTree extends StatefulWidget {
  final Uri folderUri;
  final AppDatabase database;
  final WorkerManager workerManager;
  const MainTree({
    super.key,
    required this.folderUri,
    required this.database,
    required this.workerManager,
  });

  @override
  State<MainTree> createState() => _MainTreeState();
}

class _MainTreeState extends State<MainTree> {
  late final ProviderContainer _providerContainer;

  @override
  void initState() {
    super.initState();
    _initSharingIntent();
    _initProviderContainer();
  }

  @override
  void dispose() {
    _providerContainer.dispose();
    super.dispose();
  }

  Future<void> _initSharingIntent() async {
    final handler = ShareHandlerPlatform.instance;
    final media = await handler.getInitialSharedMedia();
    if (media != null) _onMediaShared(media);

    handler.sharedMediaStream.listen(_onMediaShared);
  }

  void _initProviderContainer() {
    _providerContainer = ProviderContainer(
      overrides: [
        folderUriProvider.overrideWithValue(widget.folderUri),
        appDatabaseProvider.overrideWithValue(widget.database),
        workerManagerProvider.overrideWithValue(widget.workerManager),
      ],
      retry: (_, _) => null,
    );
  }

  Future<void> _onMediaShared(SharedMedia media) async {
    if (media.attachments?.isNotEmpty ?? false) {
      final file = media.attachments![0]!;

      try {
        final entryList = _providerContainer.read(entryListProvider.notifier);
        logger.i("1: ${file.path}");
        final entryDt = await entryList.createEntryWithImage(File(file.path));
        logger.i("Going to $entryDt");
        _router.go("/entry/$entryDt");
      } catch (err, stackTrace) {
        logger.e("$err: $stackTrace", stackTrace: stackTrace);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: _providerContainer,
      key: _providerScopeKey,
      child: DynamicColorBuilder(
        builder: (light, dark) => KeyboardProvider(
          child: MaterialApp.router(
            routerConfig: _router,
            theme: ThemeData(
              colorScheme:
                  light ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            darkTheme: ThemeData(
              colorScheme:
                  dark ??
                  ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.dark,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
