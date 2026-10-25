import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_controller/flutter_keyboard_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/database.dart';
import 'package:journal/logger.dart';
import 'package:journal/pages/editor.dart';
import 'package:journal/pages/home.dart';
import 'package:journal/widgets/folder_selection_page.dart';
import 'package:journal/worker.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saf/saf.dart';
import 'package:shared_preferences/shared_preferences.dart';

part "main.g.dart";

void main() async {
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message?.contains("IsolateController") ?? false) return;
    debugPrintThrottled(message, wrapWidth: wrapWidth);
  };

  logger.i("Starting main()");
  WidgetsFlutterBinding.ensureInitialized();
  MapLibreMap.preWarm();
  final saf = Saf();
  final prefs = SharedPreferencesAsync();
  final database = AppDatabase();
  final workerManager = WorkerManager();

  final String? cachedUri = await prefs.getString("saf_authorised_uri");

  NominatimFlutter.instance.configureNominatim(
    useCacheInterceptor: true,
    maxStale: Duration(days: 14),
    userAgent: "LocalJournal/1.3.0 (owen00064@gmail.com)",
    convertFormData: true,
  );

  runApp(
    App(
      saf: saf,
      cachedUri: cachedUri,
      prefs: prefs,
      database: database,
      workerManager: workerManager,
    ),
  );
}

// initialise this in overrides
@riverpod
Uri folderUri(Ref ref) {
  logger.e("Accessed folderUriProvider before overriding!");
  throw UnimplementedError();
}

@riverpod
AppDatabase appDatabase(Ref ref) {
  logger.e("Accessed appDatabaseProvider before overriding!");
  throw UnimplementedError();
}

@riverpod
WorkerManager workerManager(Ref ref) {
  logger.e("Accessed workerManagerProvider before overriding!");
  throw UnimplementedError();
}

@riverpod
Saf saf(Ref ref) {
  return Saf();
}

final _router = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: "/entry/:datetime",
      builder: (context, state) =>
          EntryEditor(entryDateString: state.pathParameters["datetime"]!),
    ),
  ],
);

class App extends StatefulWidget {
  final Saf saf;
  final SharedPreferencesAsync prefs;
  final String? cachedUri;
  final AppDatabase database;
  final WorkerManager workerManager;

  const App({
    super.key,
    required this.saf,
    required this.prefs,
    required this.cachedUri,
    required this.database,
    required this.workerManager,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Uri _folderUri;
  bool _authorised = false;

  @override
  initState() {
    super.initState();
    _initSaf();
  }

  Future<void> _initSaf() async {
    final cachedUri = widget.cachedUri;
    if (cachedUri != null) {
      onPermissionsGranted(Uri.parse(cachedUri));
    } else {
      logger.i("Didn't use cached uri.");
      final grants = await widget.saf.persistedPermissions();
      if (grants.isNotEmpty) {
        onPermissionsGranted(Uri.parse(grants[0].uri));
      }
    }
  }

  void onPermissionsGranted(Uri dirUri) {
    widget.prefs.setString("saf_authorised_uri", dirUri.toString());
    setState(() {
      _authorised = true;
      _folderUri = dirUri;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _authorised
        ? ProviderScope(
            overrides: [
              folderUriProvider.overrideWithValue(_folderUri),
              appDatabaseProvider.overrideWithValue(widget.database),
              workerManagerProvider.overrideWithValue(widget.workerManager),
            ],
            retry: (_, _) => null,
            child: DynamicColorBuilder(
              builder: (light, dark) => KeyboardProvider(
                child: MaterialApp.router(
                  routerConfig: _router,
                  theme: ThemeData(
                    colorScheme:
                        light ??
                        ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
          )
        : FolderSelectionPage(saf: widget.saf, onGranted: onPermissionsGranted);
  }
}
